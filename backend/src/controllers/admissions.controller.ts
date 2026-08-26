import { Request, Response } from 'express';
import { query } from '../config/database';
import { ApplicationStatus, UserRole, UserStatus } from '../types/enums';
import bcrypt from 'bcryptjs';
import { EmailService } from '../services/email.service';
import { v4 as uuidv4 } from 'uuid';

async function ensureAdmissionTablesExist() {
  try {
    await query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto";`);
    await query(`
      CREATE TABLE IF NOT EXISTS "admission_applications" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "applicationNumber" VARCHAR(50) UNIQUE NOT NULL,
        "primaryParentName" VARCHAR(100) NOT NULL,
        "primaryParentSurname" VARCHAR(100) NOT NULL,
        "primaryParentPhone" VARCHAR(20) NOT NULL,
        "primaryParentEmail" VARCHAR(255) NOT NULL,
        "primaryParentIdNumber" VARCHAR(13) NOT NULL,
        "primaryParentGender" VARCHAR(20),
        "primaryParentDob" DATE,
        "primaryParentAge" INT,
        "primaryParentCitizenship" VARCHAR(50),
        "primaryParentDocumentUrl" TEXT,
        "hasSecondaryParent" BOOLEAN DEFAULT FALSE,
        "secondaryParentName" VARCHAR(100),
        "secondaryParentSurname" VARCHAR(100),
        "secondaryParentPhone" VARCHAR(20),
        "secondaryParentEmail" VARCHAR(255),
        "secondaryParentIdNumber" VARCHAR(13),
        "secondaryParentGender" VARCHAR(20),
        "secondaryParentDob" DATE,
        "secondaryParentAge" INT,
        "secondaryParentCitizenship" VARCHAR(50),
        "secondaryParentDocumentUrl" TEXT,
        "status" VARCHAR(50) DEFAULT 'SUBMITTED',
        "registrationToken" VARCHAR(50) UNIQUE NOT NULL,
        "reviewerNotes" TEXT,
        "reviewedAt" TIMESTAMP WITH TIME ZONE,
        "submittedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS "application_learners" (
        "id" TEXT PRIMARY KEY DEFAULT gen_random_uuid(),
        "applicationId" TEXT NOT NULL REFERENCES "admission_applications"("id") ON DELETE CASCADE,
        "learnerName" VARCHAR(100) NOT NULL,
        "learnerSurname" VARCHAR(100) NOT NULL,
        "learnerIdNumber" VARCHAR(13) NOT NULL,
        "learnerGender" VARCHAR(20),
        "learnerDob" DATE,
        "learnerAge" INT,
        "learnerCitizenship" VARCHAR(50),
        "gradeApplyingFor" VARCHAR(50) NOT NULL,
        "homeLanguage" VARCHAR(50) NOT NULL,
        "firstAdditionalLanguage" VARCHAR(50),
        "stream" VARCHAR(50),
        "previousSchool" VARCHAR(255) NOT NULL,
        "documentUrl" TEXT,
        "documentName" VARCHAR(255),
        "documentVerified" BOOLEAN DEFAULT FALSE,
        "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);
  } catch (err: any) {
    console.warn('⚠️ ensureAdmissionTablesExist warning:', err.message);
  }
}

export class AdmissionsController {
  static async apply(req: Request, res: Response) {
    try {
      await ensureAdmissionTablesExist();
      const {
        primaryParentName,
        primaryParentSurname,
        primaryParentPhone,
        primaryParentEmail,
        primaryParentIdNumber,
        primaryParentGender,
        primaryParentDob,
        primaryParentAge,
        primaryParentCitizenship,
        primaryParentDocumentUrl,
        hasSecondaryParent,
        secondaryParentName,
        secondaryParentSurname,
        secondaryParentPhone,
        secondaryParentEmail,
        secondaryParentIdNumber,
        secondaryParentGender,
        secondaryParentDob,
        secondaryParentAge,
        secondaryParentCitizenship,
        secondaryParentDocumentUrl,
        learners,
        learnerName,
        learnerSurname,
        learnerIdNumber,
        gradeApplyingFor,
        homeLanguage,
        stream,
        previousSchool,
      } = req.body;

      const appId = uuidv4();
      const randomSuffix = Math.floor(1000 + Math.random() * 9000);
      const applicationNumber = `TT-2026-${randomSuffix}`;
      const registrationToken = `REG-TT-${Math.floor(10000 + Math.random() * 90000)}`;

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

      // Insert into admission_applications
      await query(`
        INSERT INTO "admission_applications" (
          "id", "applicationNumber", "primaryParentName", "primaryParentSurname",
          "primaryParentPhone", "primaryParentEmail", "primaryParentIdNumber", "primaryParentGender",
          "primaryParentDob", "primaryParentAge", "primaryParentCitizenship", "primaryParentDocumentUrl",
          "hasSecondaryParent", "secondaryParentName", "secondaryParentSurname", "secondaryParentPhone",
          "secondaryParentEmail", "secondaryParentIdNumber", "secondaryParentGender", "secondaryParentDob",
          "secondaryParentAge", "secondaryParentCitizenship", "secondaryParentDocumentUrl", "status", "registrationToken"
        )
        VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25
        )
      `, [
        appId,
        applicationNumber,
        primaryParentName.trim(),
        primaryParentSurname.trim(),
        primaryParentPhone.trim(),
        primaryParentEmail.trim(),
        primaryParentIdNumber ? primaryParentIdNumber.trim() : null,
        primaryParentGender || null,
        primaryParentDob ? new Date(primaryParentDob) : null,
        primaryParentAge ? Number(primaryParentAge) : null,
        primaryParentCitizenship || 'South African Citizen',
        primaryParentDocumentUrl || null,
        Boolean(hasSecondaryParent),
        secondaryParentName ? secondaryParentName.trim() : null,
        secondaryParentSurname ? secondaryParentSurname.trim() : null,
        secondaryParentPhone ? secondaryParentPhone.trim() : null,
        secondaryParentEmail ? secondaryParentEmail.trim() : null,
        secondaryParentIdNumber ? secondaryParentIdNumber.trim() : null,
        secondaryParentGender || null,
        secondaryParentDob ? new Date(secondaryParentDob) : null,
        secondaryParentAge ? Number(secondaryParentAge) : null,
        secondaryParentCitizenship || 'South African Citizen',
        secondaryParentDocumentUrl || null,
        ApplicationStatus.SUBMITTED,
        registrationToken,
      ]);

      // Insert learners into application_learners
      for (const l of rawLearners) {
        await query(`
          INSERT INTO "application_learners" (
            "id", "applicationId", "learnerName", "learnerSurname", "learnerIdNumber",
            "learnerGender", "learnerDob", "learnerAge", "learnerCitizenship", "gradeApplyingFor", "homeLanguage",
            "firstAdditionalLanguage", "stream", "previousSchool", "documentName", "documentUrl", "documentVerified"
          )
          VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
          )
        `, [
          uuidv4(),
          appId,
          (l.learnerName || '').trim(),
          (l.learnerSurname || '').trim(),
          (l.learnerIdNumber || '').trim(),
          l.learnerGender || null,
          l.learnerDob ? new Date(l.learnerDob) : null,
          l.learnerAge ? Number(l.learnerAge) : null,
          l.learnerCitizenship || 'South African Citizen',
          (l.gradeApplyingFor || 'Grade 8').trim(),
          (l.homeLanguage || 'English').trim(),
          (l.firstAdditionalLanguage || 'Afrikaans').trim(),
          l.stream ? l.stream.trim() : null,
          (l.previousSchool || 'Not Specified').trim(),
          l.documentName || 'Certified_ID.pdf',
          l.documentUrl || null,
          true,
        ]);
      }

      // 1. Establish Parent Profile & User Account
      const { primaryParentPassword, secondaryParentPassword } = req.body;
      const pHash = primaryParentPassword ? await bcrypt.hash(primaryParentPassword, 10) : await bcrypt.hash('#Parent#$2026$', 10);
      
      const parentUserRes = await query(`
        INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "phone", "status")
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT ("email") DO UPDATE SET
          "passwordHash" = $3,
          "name" = $4,
          "surname" = $5,
          "phone" = $7
        RETURNING id
      `, [
        uuidv4(),
        primaryParentEmail.toLowerCase().trim(),
        pHash,
        primaryParentName.trim(),
        primaryParentSurname.trim(),
        UserRole.PARENT,
        primaryParentPhone.trim(),
        UserStatus.ACTIVE,
      ]);
      const parentUserId = parentUserRes.rows[0]?.id;

      const parentRes = await query(`
        INSERT INTO "parents" (
          "id", "userId", "fullName", "surname", "phone", "email", "idNumber",
          "hasSecondaryParent", "secondaryParentFullName", "secondaryParentSurname",
          "secondaryParentPhone", "secondaryParentEmail", "secondaryParentIdNumber"
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
        ON CONFLICT ("userId") DO UPDATE SET
          "fullName" = $3,
          "surname" = $4,
          "phone" = $5,
          "email" = $6,
          "idNumber" = $7
        RETURNING id
      `, [
        uuidv4(),
        parentUserId,
        primaryParentName.trim(),
        primaryParentSurname.trim(),
        primaryParentPhone.trim(),
        primaryParentEmail.toLowerCase().trim(),
        primaryParentIdNumber ? primaryParentIdNumber.trim() : null,
        Boolean(hasSecondaryParent),
        secondaryParentName ? secondaryParentName.trim() : null,
        secondaryParentSurname ? secondaryParentSurname.trim() : null,
        secondaryParentPhone ? secondaryParentPhone.trim() : null,
        secondaryParentEmail ? secondaryParentEmail.toLowerCase().trim() : null,
        secondaryParentIdNumber ? secondaryParentIdNumber.trim() : null,
      ]);
      const parentDbId = parentRes.rows[0]?.id;

      // 2. Establish Learner Profiles & Direct Parent-Learner Relationships
      for (const l of rawLearners) {
        const studentNum = `TT${new Date().getFullYear()}${Math.floor(10000 + Math.random() * 90000)}`;
        const sanitizedLearnerEmail = `${(l.learnerName || 'learner').toLowerCase().replace(/\s+/g, '')}.${(l.learnerSurname || 'makola').toLowerCase().replace(/\s+/g, '')}@thutotech.ac.za`;
        const learnerPassHash = await bcrypt.hash('#Learner#$2026$', 10);

        const learnerUserRes = await query(`
          INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "phone", "status")
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          ON CONFLICT ("email") DO UPDATE SET
            "name" = $4,
            "surname" = $5
          RETURNING id
        `, [
          uuidv4(),
          sanitizedLearnerEmail,
          learnerPassHash,
          (l.learnerName || '').trim(),
          (l.learnerSurname || '').trim(),
          UserRole.LEARNER,
          primaryParentPhone.trim(),
          UserStatus.ACTIVE,
        ]);
        const learnerUserId = learnerUserRes.rows[0]?.id;

        const learnerRes = await query(`
          INSERT INTO "learners" (
            "id", "userId", "learnerNumber", "idNumber", "fullName", "surname",
            "gender", "dateOfBirth", "grade", "homeLanguage", "firstAdditionalLanguage", "stream"
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
          ON CONFLICT ("userId") DO UPDATE SET
            "fullName" = $5,
            "surname" = $6,
            "grade" = $9
          RETURNING id
        `, [
          uuidv4(),
          learnerUserId,
          studentNum,
          (l.learnerIdNumber || '0000000000000').trim(),
          (l.learnerName || '').trim(),
          (l.learnerSurname || '').trim(),
          l.learnerGender || null,
          l.learnerDob ? new Date(l.learnerDob) : null,
          (l.gradeApplyingFor || 'Grade 8').trim(),
          (l.homeLanguage || 'Sepedi').trim(),
          (l.firstAdditionalLanguage || 'English').trim(),
          l.stream ? l.stream.trim() : null,
        ]);
        const learnerDbId = learnerRes.rows[0]?.id;

        // 3. Link Parent and Child in Relational Bridge
        if (parentDbId && learnerDbId) {
          await query(`
            INSERT INTO "parent_learner_relationships" ("id", "parentId", "learnerId", "relationshipType", "status")
            VALUES ($1, $2, $3, 'PARENT', 'ACTIVE')
            ON CONFLICT ("parentId", "learnerId") DO UPDATE SET "status" = 'ACTIVE'
          `, [uuidv4(), parentDbId, learnerDbId]);
        }
      }

      // 4. Secondary Parent Linking (if provided)
      if (hasSecondaryParent && secondaryParentEmail) {
        const secPassHash = secondaryParentPassword ? await bcrypt.hash(secondaryParentPassword, 10) : await bcrypt.hash('#Parent#$2026$', 10);
        const secUserRes = await query(`
          INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "phone", "status")
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          ON CONFLICT ("email") DO UPDATE SET
            "passwordHash" = $3,
            "name" = $4,
            "surname" = $5
          RETURNING id
        `, [
          uuidv4(),
          secondaryParentEmail.toLowerCase().trim(),
          secPassHash,
          (secondaryParentName || '').trim(),
          (secondaryParentSurname || '').trim(),
          UserRole.PARENT,
          secondaryParentPhone ? secondaryParentPhone.trim() : null,
          UserStatus.ACTIVE,
        ]);
        const secUserId = secUserRes.rows[0]?.id;

        if (secUserId) {
          const secParentRes = await query(`
            INSERT INTO "parents" ("id", "userId", "fullName", "surname", "phone", "email", "idNumber")
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            ON CONFLICT ("userId") DO UPDATE SET
              "fullName" = $3,
              "surname" = $4
            RETURNING id
          `, [
            uuidv4(),
            secUserId,
            (secondaryParentName || '').trim(),
            (secondaryParentSurname || '').trim(),
            secondaryParentPhone ? secondaryParentPhone.trim() : '',
            secondaryParentEmail.toLowerCase().trim(),
            secondaryParentIdNumber ? secondaryParentIdNumber.trim() : null,
          ]);
        }
      }

      return res.status(201).json({
        success: true,
        message: `Admission application submitted. Parent and ${rawLearners.length} child profile(s) linked.`,
        application: {
          id: appId,
          applicationNumber,
          registrationToken,
          primaryParentName,
          primaryParentSurname,
          primaryParentEmail,
        },
        data: {
          id: appId,
          applicationNumber,
          registrationToken,
          primaryParentName,
          primaryParentSurname,
          primaryParentEmail,
        },
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getApplications(req: Request, res: Response) {
    try {
      const { status } = req.query;
      let sql = `SELECT * FROM "admission_applications"`;
      const params: any[] = [];

      if (status && typeof status === 'string') {
        sql += ` WHERE "status" = $1`;
        params.push(status);
      }
      sql += ` ORDER BY "submittedAt" DESC`;

      const appRes = await query(sql, params);
      const applications = appRes.rows;

      // Fetch learners for each application
      for (const app of applications) {
        const learnersRes = await query(`SELECT * FROM "application_learners" WHERE "applicationId" = $1`, [app.id]);
        app.learners = learnersRes.rows;
      }

      return res.json({ success: true, data: applications, applications });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async approveApplication(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { notes } = req.body;

      const appRes = await query(`SELECT * FROM "admission_applications" WHERE id = $1 LIMIT 1`, [id]);
      if (appRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Application not found.' });
      }

      const app = appRes.rows[0];

      // Update application status
      await query(`
        UPDATE "admission_applications"
        SET "status" = $1, "reviewedAt" = CURRENT_TIMESTAMP, "reviewerNotes" = $2
        WHERE id = $3
      `, [ApplicationStatus.APPROVED, notes || 'Approved by Administrator.', id]);

      const learnersRes = await query(`SELECT * FROM "application_learners" WHERE "applicationId" = $1`, [id]);
      const learners = learnersRes.rows;
      const firstLearner = learners[0] || {};

      // Dispatch automated admission approval email
      await EmailService.sendAdmissionApprovalEmail({
        recipientEmail: app.primaryParentEmail,
        parentName: app.primaryParentName,
        parentSurname: app.primaryParentSurname,
        learnerName: firstLearner.learnerName || app.primaryParentSurname + ' Child',
        learnerSurname: firstLearner.learnerSurname || app.primaryParentSurname,
        grade: firstLearner.gradeApplyingFor || 'Grade 10',
        homeLanguage: firstLearner.homeLanguage || 'English',
        stream: firstLearner.stream || undefined,
        applicationNumber: app.applicationNumber,
        registrationToken: app.registrationToken,
      });

      return res.json({
        success: true,
        message: 'Admission application approved and registration email sent to parent.',
        data: { ...app, status: ApplicationStatus.APPROVED, learners },
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
        learnerName,
        learnerSurname,
        learnerIdNumber,
      } = req.body;

      const appRes = await query(`SELECT * FROM "admission_applications" WHERE "registrationToken" = $1 LIMIT 1`, [registrationToken]);
      if (appRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Invalid or expired registration token.' });
      }

      const app = appRes.rows[0];
      const learnersRes = await query(`SELECT * FROM "application_learners" WHERE "applicationId" = $1`, [app.id]);
      app.learners = learnersRes.rows;

      // Check or create parent user
      let parentUserRes = await query(`SELECT * FROM "users" WHERE LOWER(email) = LOWER($1) LIMIT 1`, [parentEmail]);
      let parentUserId = '';
      let parentEntityId = '';

      if (parentUserRes.rows.length === 0) {
        parentUserId = uuidv4();
        const passwordHash = await bcrypt.hash(parentPassword || 'Parent@2026!', 10);
        await query(`
          INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "phone", "status")
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        `, [
          parentUserId,
          parentEmail.toLowerCase().trim(),
          passwordHash,
          parentName.trim(),
          parentSurname.trim(),
          UserRole.PARENT,
          app.primaryParentPhone,
          UserStatus.ACTIVE,
        ]);

        parentEntityId = uuidv4();
        await query(`
          INSERT INTO "parents" (
            "id", "userId", "fullName", "surname", "phone", "email", "hasSecondaryParent",
            "secondaryParentFullName", "secondaryParentSurname", "secondaryParentPhone", "secondaryParentEmail"
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        `, [
          parentEntityId,
          parentUserId,
          parentName.trim(),
          parentSurname.trim(),
          app.primaryParentPhone,
          parentEmail.toLowerCase().trim(),
          app.hasSecondaryParent,
          app.secondaryParentName,
          app.secondaryParentSurname,
          app.secondaryParentPhone,
          app.secondaryParentEmail,
        ]);
      } else {
        parentUserId = parentUserRes.rows[0].id;
        const parentEntRes = await query(`SELECT id FROM "parents" WHERE "userId" = $1 LIMIT 1`, [parentUserId]);
        parentEntityId = parentEntRes.rows.length > 0 ? parentEntRes.rows[0].id : uuidv4();
      }

      const learnersToRegister: any[] = Array.isArray(learners) && learners.length > 0
        ? learners
        : [{
            learnerName: learnerName || app.learners[0]?.learnerName,
            learnerSurname: learnerSurname || app.learners[0]?.learnerSurname,
            learnerIdNumber: learnerIdNumber || app.learners[0]?.learnerIdNumber,
          }];

      const createdLearners: any[] = [];

      for (const rawL of learnersToRegister) {
        const lName = (rawL.learnerName || '').trim();
        const lSurname = (rawL.learnerSurname || '').trim();
        const lIdNum = (rawL.learnerIdNumber || '').trim();

        const year = new Date().getFullYear();
        const learnerNumber = `${year}${String(Math.floor(1000 + Math.random() * 9000)).padStart(4, '0')}`;
        const learnerEmail = `${learnerNumber}@thutotech.co.za`;

        let generatedPassword = 'Thuto@2026!';
        if (lIdNum.length >= 13) {
          let extracted = '';
          for (let i = 0; i < lIdNum.length; i += 3) {
            extracted += lIdNum[i];
          }
          generatedPassword = `Thuto@${extracted}`;
        }

        const learnerPassHash = await bcrypt.hash(generatedPassword, 10);
        const learnerUserId = uuidv4();

        await query(`
          INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "status")
          VALUES ($1, $2, $3, $4, $5, $6, $7)
        `, [learnerUserId, learnerEmail, learnerPassHash, lName, lSurname, UserRole.LEARNER, UserStatus.ACTIVE]);

        const appLearner = app.learners.find((al: any) => al.learnerIdNumber === lIdNum) || app.learners[0];
        const learnerEntityId = uuidv4();

        await query(`
          INSERT INTO "learners" (
            "id", "userId", "learnerNumber", "idNumber", "fullName", "surname",
            "grade", "className", "homeLanguage", "firstAdditionalLanguage", "stream", "schoolId"
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, 'sch_thutotech')
        `, [
          learnerEntityId,
          learnerUserId,
          learnerNumber,
          lIdNum,
          lName,
          lSurname,
          appLearner?.gradeApplyingFor || 'Grade 8',
          `${appLearner?.gradeApplyingFor || 'Grade 8'}A`,
          appLearner?.homeLanguage || 'English',
          appLearner?.firstAdditionalLanguage || 'Afrikaans',
          appLearner?.stream || null,
        ]);

        // Link parent-learner
        await query(`
          INSERT INTO "parent_learner_relationships" ("id", "parentId", "learnerId", "relationshipType", "status")
          VALUES ($1, $2, $3, 'PARENT', 'ACTIVE')
          ON CONFLICT ("parentId", "learnerId") DO NOTHING
        `, [uuidv4(), parentEntityId, learnerEntityId]);

        // Send registration welcome email
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
