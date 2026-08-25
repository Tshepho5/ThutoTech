import { Request, Response } from 'express';
import { prisma } from '../config/database';
import { ApplicationStatus, UserRole, UserStatus } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { EmailService } from '../services/email.service';
import { v4 as uuidv4 } from 'uuid';

export class AdmissionsController {
  static async apply(req: Request, res: Response) {
    try {
      const {
        primaryParentName,
        primaryParentSurname,
        primaryParentPhone,
        primaryParentEmail,
        primaryParentIdNumber,
        hasSecondaryParent,
        secondaryParentName,
        secondaryParentSurname,
        secondaryParentPhone,
        secondaryParentEmail,
        learnerName,
        learnerSurname,
        learnerIdNumber,
        gradeApplyingFor,
        previousSchool,
      } = req.body;

      const randomSuffix = Math.floor(1000 + Math.random() * 9000);
      const applicationNumber = `TT-2026-${randomSuffix}`;
      const registrationToken = `REG-TT-${Math.floor(10000 + Math.random() * 90000)}`;

      const application = await prisma.admissionApplication.create({
        data: {
          applicationNumber,
          primaryParentName: primaryParentName.trim(),
          primaryParentSurname: primaryParentSurname.trim(),
          primaryParentPhone: primaryParentPhone.trim(),
          primaryParentEmail: primaryParentEmail.trim(),
          primaryParentIdNumber: primaryParentIdNumber.trim(),
          hasSecondaryParent: Boolean(hasSecondaryParent),
          secondaryParentName: secondaryParentName ? secondaryParentName.trim() : null,
          secondaryParentSurname: secondaryParentSurname ? secondaryParentSurname.trim() : null,
          secondaryParentPhone: secondaryParentPhone ? secondaryParentPhone.trim() : null,
          secondaryParentEmail: secondaryParentEmail ? secondaryParentEmail.trim() : null,
          learnerName: learnerName.trim(),
          learnerSurname: learnerSurname.trim(),
          learnerIdNumber: learnerIdNumber.trim(),
          gradeApplyingFor: gradeApplyingFor.trim(),
          previousSchool: (previousSchool || 'Not Specified').trim(),
          status: ApplicationStatus.SUBMITTED,
          registrationToken,
        },
      });

      return res.status(201).json({
        success: true,
        message: 'Admission application submitted successfully.',
        data: application,
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getApplications(req: Request, res: Response) {
    try {
      const { status } = req.query;
      const where: any = {};
      if (status && typeof status === 'string') {
        where.status = status as ApplicationStatus;
      }

      const applications = await prisma.admissionApplication.findMany({
        where,
        orderBy: { submittedAt: 'desc' },
      });

      return res.json({ success: true, data: applications });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async approveApplication(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { notes } = req.body;

      const app = await prisma.admissionApplication.findUnique({ where: { id } });
      if (!app) {
        return res.status(404).json({ success: false, message: 'Application not found.' });
      }

      const updated = await prisma.admissionApplication.update({
        where: { id },
        data: {
          status: ApplicationStatus.APPROVED,
          reviewedAt: new Date(),
          reviewerNotes: notes || 'Approved by School Principal.',
        },
      });

      // Dispatch automated admission approval email
      await EmailService.sendAdmissionApprovalEmail({
        recipientEmail: updated.primaryParentEmail,
        parentName: updated.primaryParentName,
        parentSurname: updated.primaryParentSurname,
        learnerName: updated.learnerName,
        learnerSurname: updated.learnerSurname,
        grade: updated.gradeApplyingFor,
        homeLanguage: updated.homeLanguage || 'English',
        stream: updated.stream || undefined,
        applicationNumber: updated.applicationNumber,
        registrationToken: updated.registrationToken,
      });

      return res.json({
        success: true,
        message: 'Admission application approved and registration email sent to parent.',
        data: updated,
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async register(req: Request, res: Response) {
    try {
      const {
        registrationToken,
        parentName,
        parentSurname,
        parentEmail,
        parentPassword,
        learnerName,
        learnerSurname,
        learnerIdNumber,
      } = req.body;

      // 1. Verify Token
      const application = await prisma.admissionApplication.findUnique({
        where: { registrationToken: registrationToken.trim() },
      });

      if (!application || application.status !== ApplicationStatus.APPROVED) {
        return res.status(400).json({
          success: false,
          message: 'Invalid registration token or application has not yet been approved.',
        });
      }

      // Check if user already exists
      const existingUser = await prisma.user.findUnique({ where: { email: parentEmail.trim() } });
      if (existingUser) {
        return res.status(400).json({ success: false, message: 'An account with this email already exists.' });
      }

      const passwordHash = await bcrypt.hash(parentPassword, 10);
      const school = await prisma.school.findFirst();
      const schoolId = school?.id || uuidv4();

      // Transactionally create Parent User, Learner User, and relational entities
      const result = await prisma.$transaction(async (tx) => {
        // Create Parent User
        const parentUser = await tx.user.create({
          data: {
            email: parentEmail.trim(),
            passwordHash,
            name: parentName.trim(),
            surname: parentSurname.trim(),
            role: UserRole.PARENT,
            phone: application.primaryParentPhone,
            status: UserStatus.ACTIVE,
            schoolId,
          },
        });

        // Create Parent Entity
        const parentEntity = await tx.parent.create({
          data: {
            userId: parentUser.id,
            fullName: parentName.trim(),
            surname: parentSurname.trim(),
            phone: application.primaryParentPhone,
            email: parentEmail.trim(),
            hasSecondaryParent: application.hasSecondaryParent,
            secondaryParentFullName: application.secondaryParentName,
            secondaryParentSurname: application.secondaryParentSurname,
            secondaryParentPhone: application.secondaryParentPhone,
            secondaryParentEmail: application.secondaryParentEmail,
          },
        });

        // Create Learner User
        const learnerEmail = `${learnerName.toLowerCase()}.${learnerSurname.toLowerCase()}@learner.thutotech.co.za`;
        const learnerUser = await tx.user.create({
          data: {
            email: learnerEmail,
            passwordHash,
            name: learnerName.trim(),
            surname: learnerSurname.trim(),
            role: UserRole.LEARNER,
            status: UserStatus.ACTIVE,
            schoolId,
          },
        });

        // Create Learner Entity
        const learnerEntity = await tx.learner.create({
          data: {
            userId: learnerUser.id,
            idNumber: learnerIdNumber.trim(),
            fullName: learnerName.trim(),
            surname: learnerSurname.trim(),
            grade: application.gradeApplyingFor,
            className: `${application.gradeApplyingFor}A`,
            schoolId,
            attendancePercentage: 100.0,
            overallAverage: 0.0,
          },
        });

        // Create Parent-Learner Relationship
        await tx.parentLearnerRelationship.create({
          data: {
            parentId: parentEntity.id,
            learnerId: learnerEntity.id,
            status: 'ACTIVE',
          },
        });

        // Log Audit Event
        await tx.auditLog.create({
          data: {
            userId: parentUser.id,
            userName: `${parentName} ${parentSurname}`,
            role: 'PARENT',
            action: 'REGISTRATION_COMPLETED',
            entity: `Parent & Learner Account Activation`,
            details: `Registered parent and linked learner ${learnerName} ${learnerSurname} (ID: ${learnerIdNumber})`,
          },
        });

        return { parentUser, learnerUser, parentEntity, learnerEntity };
      });

      return res.status(201).json({
        success: true,
        message: 'Registration completed successfully. Accounts are active.',
        data: result,
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
