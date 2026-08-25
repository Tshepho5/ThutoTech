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
        primaryParentGender,
        primaryParentDob,
        primaryParentDocumentUrl,
        hasSecondaryParent,
        secondaryParentName,
        secondaryParentSurname,
        secondaryParentPhone,
        secondaryParentEmail,
        secondaryParentIdNumber,
        secondaryParentGender,
        secondaryParentDob,
        secondaryParentDocumentUrl,
        learners, // Array of learners: [{ learnerName, learnerSurname, learnerIdNumber, gradeApplyingFor, homeLanguage, stream, previousSchool, documentName, documentUrl, documentVerified }]
        // Single learner backwards compatibility
        learnerName,
        learnerSurname,
        learnerIdNumber,
        gradeApplyingFor,
        homeLanguage,
        stream,
        previousSchool,
      } = req.body;

      const randomSuffix = Math.floor(1000 + Math.random() * 9000);
      const applicationNumber = `TT-2026-${randomSuffix}`;
      const registrationToken = `REG-TT-${Math.floor(10000 + Math.random() * 90000)}`;

      // Parse learners array or fallback to single learner
      const rawLearners: any[] = Array.isArray(learners) && learners.length > 0
        ? learners
        : [{
            learnerName: learnerName || '',
            learnerSurname: learnerSurname || '',
            learnerIdNumber: learnerIdNumber || '',
            gradeApplyingFor: gradeApplyingFor || 'Grade 8',
            homeLanguage: homeLanguage || 'English',
            stream: stream || null,
            previousSchool: previousSchool || 'Not Specified',
            documentName: 'Learner_ID_Copy.pdf',
            documentVerified: true,
          }];

      const application = await prisma.admissionApplication.create({
        data: {
          applicationNumber,
          primaryParentName: primaryParentName.trim(),
          primaryParentSurname: primaryParentSurname.trim(),
          primaryParentPhone: primaryParentPhone.trim(),
          primaryParentEmail: primaryParentEmail.trim(),
          primaryParentIdNumber: primaryParentIdNumber.trim(),
          primaryParentGender: primaryParentGender || null,
          primaryParentDob: primaryParentDob ? new Date(primaryParentDob) : null,
          primaryParentDocumentUrl: primaryParentDocumentUrl || null,
          hasSecondaryParent: Boolean(hasSecondaryParent),
          secondaryParentName: secondaryParentName ? secondaryParentName.trim() : null,
          secondaryParentSurname: secondaryParentSurname ? secondaryParentSurname.trim() : null,
          secondaryParentPhone: secondaryParentPhone ? secondaryParentPhone.trim() : null,
          secondaryParentEmail: secondaryParentEmail ? secondaryParentEmail.trim() : null,
          secondaryParentIdNumber: secondaryParentIdNumber ? secondaryParentIdNumber.trim() : null,
          secondaryParentGender: secondaryParentGender || null,
          secondaryParentDob: secondaryParentDob ? new Date(secondaryParentDob) : null,
          secondaryParentDocumentUrl: secondaryParentDocumentUrl || null,
          status: ApplicationStatus.SUBMITTED,
          registrationToken,
          learners: {
            create: rawLearners.map((l: any) => ({
              learnerName: (l.learnerName || '').trim(),
              learnerSurname: (l.learnerSurname || '').trim(),
              learnerIdNumber: (l.learnerIdNumber || '').trim(),
              learnerGender: l.learnerGender || null,
              learnerDob: l.learnerDob ? new Date(l.learnerDob) : null,
              learnerAge: l.learnerAge ? Number(l.learnerAge) : null,
              gradeApplyingFor: (l.gradeApplyingFor || 'Grade 8').trim(),
              homeLanguage: (l.homeLanguage || 'English').trim(),
              firstAdditionalLanguage: (l.firstAdditionalLanguage || 'Afrikaans').trim(),
              stream: l.stream ? l.stream.trim() : null,
              previousSchool: (l.previousSchool || 'Not Specified').trim(),
              documentName: l.documentName || null,
              documentUrl: l.documentUrl || null,
              documentVerified: Boolean(l.documentVerified),
            })),
          },
        },
        include: {
          learners: true,
        },
      });

      return res.status(201).json({
        success: true,
        message: `Admission application submitted for ${rawLearners.length} learner(s).`,
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
        include: { learners: true },
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

      const app = await prisma.admissionApplication.findUnique({
        where: { id },
        include: { learners: true },
      });
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
        include: { learners: true },
      });

      const firstLearner = updated.learners[0] || {};

      // Dispatch automated admission approval email
      await EmailService.sendAdmissionApprovalEmail({
        recipientEmail: updated.primaryParentEmail,
        parentName: updated.primaryParentName,
        parentSurname: updated.primaryParentSurname,
        learnerName: firstLearner.learnerName || updated.primaryParentSurname + ' Child',
        learnerSurname: firstLearner.learnerSurname || updated.primaryParentSurname,
        grade: firstLearner.gradeApplyingFor || 'Grade 10',
        homeLanguage: firstLearner.homeLanguage || 'English',
        stream: firstLearner.stream || undefined,
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
        learners,
        // Single learner fallback
        learnerName,
        learnerSurname,
        learnerIdNumber,
      } = req.body;

      const app = await prisma.admissionApplication.findUnique({
        where: { registrationToken },
        include: { learners: true },
      });

      if (!app) {
        return res.status(404).json({ success: false, message: 'Invalid or expired registration token.' });
      }

      if (app.status !== ApplicationStatus.APPROVED) {
        return res.status(400).json({ success: false, message: 'Application has not been approved yet.' });
      }

      // Check if parent user already exists
      let parentUser = await prisma.user.findUnique({ where: { email: parentEmail } });
      let parentEntity: any = null;

      if (!parentUser) {
        const passwordHash = await bcrypt.hash(parentPassword, 10);
        parentUser = await prisma.user.create({
          data: {
            email: parentEmail.toLowerCase().trim(),
            passwordHash,
            name: parentName.trim(),
            surname: parentSurname.trim(),
            role: UserRole.PARENT,
            phone: app.primaryParentPhone,
            status: UserStatus.ACTIVE,
          },
        });

        parentEntity = await prisma.parent.create({
          data: {
            userId: parentUser.id,
            fullName: parentName.trim(),
            surname: parentSurname.trim(),
            phone: app.primaryParentPhone,
            email: parentEmail.toLowerCase().trim(),
            hasSecondaryParent: app.hasSecondaryParent,
            secondaryParentFullName: app.secondaryParentName,
            secondaryParentSurname: app.secondaryParentSurname,
            secondaryParentPhone: app.secondaryParentPhone,
            secondaryParentEmail: app.secondaryParentEmail,
          },
        });
      } else {
        parentEntity = await prisma.parent.findUnique({ where: { userId: parentUser.id } });
      }

      const learnersToRegister: any[] = Array.isArray(learners) && learners.length > 0
        ? learners
        : [{
            learnerName: learnerName || app.learners[0]?.learnerName,
            learnerSurname: learnerSurname || app.learners[0]?.learnerSurname,
            learnerIdNumber: learnerIdNumber || app.learners[0]?.learnerIdNumber,
          }];

      const createdLearners: any[] = [];
      let seq = 1;

      for (const rawL of learnersToRegister) {
        const lName = (rawL.learnerName || '').trim();
        const lSurname = (rawL.learnerSurname || '').trim();
        const lIdNum = (rawL.learnerIdNumber || '').trim();

        const year = new Date().getFullYear();
        const learnerNumber = `${year}${String(Math.floor(1000 + Math.random() * 9000)).padStart(4, '0')}`;
        const learnerEmail = `${learnerNumber}@thutotech.co.za`;

        // Systematic password rule: Thuto@ + id[0] + id[3] + id[6] + id[9] + id[12]
        let generatedPassword = 'Thuto@2026!';
        if (lIdNum.length >= 13) {
          let extracted = '';
          for (let i = 0; i < lIdNum.length; i += 3) {
            extracted += lIdNum[i];
          }
          generatedPassword = `Thuto@${extracted}`;
        }

        const learnerPassHash = await bcrypt.hash(generatedPassword, 10);
        const learnerUser = await prisma.user.create({
          data: {
            email: learnerEmail,
            passwordHash: learnerPassHash,
            name: lName,
            surname: lSurname,
            role: UserRole.LEARNER,
            status: UserStatus.ACTIVE,
          },
        });

        const appLearner = app.learners.find(al => al.learnerIdNumber === lIdNum) || app.learners[0];

        const learnerEntity = await prisma.learner.create({
          data: {
            userId: learnerUser.id,
            learnerNumber,
            idNumber: lIdNum,
            fullName: lName,
            surname: lSurname,
            grade: appLearner?.gradeApplyingFor || 'Grade 8',
            className: `${appLearner?.gradeApplyingFor || 'Grade 8'}A`,
            homeLanguage: appLearner?.homeLanguage || 'English',
            firstAdditionalLanguage: appLearner?.firstAdditionalLanguage || 'Afrikaans',
            stream: appLearner?.stream || null,
            schoolId: 'sch_thutotech',
            parents: {
              create: {
                parentId: parentEntity.id,
              },
            },
          },
        });

        // Send registration welcome email with generated credentials
        await EmailService.sendRegistrationSuccessEmail({
          recipientEmail: parentEmail,
          parentName,
          parentSurname,
          learnerName: lName,
          learnerSurname: lSurname,
          learnerNumber,
          learnerEmail,
          generatedPassword,
        });

        createdLearners.push({
          learnerNumber,
          learnerEmail,
          generatedPassword,
          fullName: `${lName} ${lSurname}`,
        });
      }

      return res.status(201).json({
        success: true,
        message: 'Parent and learner(s) successfully registered. Access credentials dispatched via email.',
        data: {
          parentEmail,
          learners: createdLearners,
        },
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
