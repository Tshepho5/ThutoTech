import { Response } from 'express';
import { query } from '../config/database';
import { AuthRequest } from '../middleware/auth.middleware';
import { AutomationService } from '../services/automation.service';
import { AssignmentStatus, SubmissionStatus, AnnouncementPriority } from '../types/enums';
import { v4 as uuidv4 } from 'uuid';

export class AcademicsController {
  // --- LEARNER OPERATIONS ---
  static async getLearnerDashboard(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const learnerRes = await query(`SELECT * FROM "learners" WHERE "userId" = $1 LIMIT 1`, [userId]);

      if (learnerRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Learner profile not found.' });
      }

      const learner = learnerRes.rows[0];
      const activeAssignmentsRes = await query(`
        SELECT a.*, s.name as "subjectName", c.name as "className"
        FROM "assignments" a
        LEFT JOIN "subjects" s ON a."subjectId" = s.id
        LEFT JOIN "school_classes" c ON a."classId" = c.id
        WHERE a.status = $1
        ORDER BY a."dueDate" ASC
      `, [AssignmentStatus.PUBLISHED]);

      return res.json({
        success: true,
        data: {
          learner,
          activeAssignments: activeAssignmentsRes.rows,
        },
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async submitAssignment(req: AuthRequest, res: Response) {
    try {
      const { assignmentId } = req.body;
      const userId = req.user?.id;

      const learnerRes = await query(`SELECT * FROM "learners" WHERE "userId" = $1 LIMIT 1`, [userId]);
      if (learnerRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Learner not found.' });
      }
      const learner = learnerRes.rows[0];

      const assignmentRes = await query(`SELECT * FROM "assignments" WHERE id = $1 LIMIT 1`, [assignmentId]);
      if (assignmentRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Assignment not found.' });
      }
      const assignment = assignmentRes.rows[0];

      const isLate = new Date() > new Date(assignment.dueDate);
      const status = isLate ? SubmissionStatus.LATE : SubmissionStatus.SUBMITTED;

      const subRes = await query(`
        INSERT INTO "submissions" ("id", "assignmentId", "learnerId", "submittedAt", "status")
        VALUES ($1, $2, $3, CURRENT_TIMESTAMP, $4)
        ON CONFLICT ("assignmentId", "learnerId") DO UPDATE SET
          "submittedAt" = CURRENT_TIMESTAMP,
          "status" = $4
        RETURNING *
      `, [uuidv4(), assignmentId, learner.id, status]);

      return res.json({
        success: true,
        message: `Assignment submitted successfully (${isLate ? 'LATE' : 'ON TIME'}).`,
        data: subRes.rows[0],
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  // --- PARENT OPERATIONS ---
  static async getParentChildren(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const parentRes = await query(`SELECT id FROM "parents" WHERE "userId" = $1 LIMIT 1`, [userId]);

      if (parentRes.rows.length === 0) {
        return res.status(404).json({ success: false, message: 'Parent profile not found.' });
      }

      const parentId = parentRes.rows[0].id;
      const childrenRes = await query(`
        SELECT l.*
        FROM "parent_learner_relationships" plr
        JOIN "learners" l ON plr."learnerId" = l.id
        WHERE plr."parentId" = $1 AND plr."status" = 'ACTIVE'
      `, [parentId]);

      return res.json({ success: true, data: childrenRes.rows });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  // --- TEACHER OPERATIONS ---
  static async createAssignment(req: AuthRequest, res: Response) {
    try {
      const { title, description, subjectId, classId, dueDate, maxMarks } = req.body;
      const userId = req.user?.id;

      const teacherRes = await query(`SELECT id FROM "teachers" WHERE "userId" = $1 LIMIT 1`, [userId]);
      const teacherId = teacherRes.rows.length > 0 ? teacherRes.rows[0].id : 'tch_admin';

      const assignmentId = uuidv4();
      const insertRes = await query(`
        INSERT INTO "assignments" ("id", "title", "description", "subjectId", "classId", "teacherId", "dueDate", "maxMarks", "status")
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        RETURNING *
      `, [assignmentId, title.trim(), description?.trim() || '', subjectId, classId, teacherId, new Date(dueDate), Number(maxMarks) || 100, AssignmentStatus.PUBLISHED]);

      return res.status(201).json({
        success: true,
        message: 'Assignment published.',
        data: insertRes.rows[0],
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async gradeSubmission(req: AuthRequest, res: Response) {
    try {
      const { submissionId, mark, feedback } = req.body;
      const userId = req.user?.id || 'usr_teacher';
      const numericMark = Number(mark);

      if (isNaN(numericMark) || numericMark < 0) {
        return res.status(400).json({ success: false, message: 'Valid non-negative mark is required.' });
      }

      const updateRes = await query(`
        UPDATE "submissions"
        SET "mark" = $1, "feedback" = $2, "status" = $3
        WHERE id = $4
        RETURNING *
      `, [numericMark, feedback ? feedback.trim() : null, SubmissionStatus.MARKED, submissionId]);

      await AutomationService.onSubmissionGraded(submissionId, userId);

      return res.json({
        success: true,
        message: 'Mark recorded and learner average recalculated.',
        data: updateRes.rows[0],
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async recordAttendance(req: AuthRequest, res: Response) {
    try {
      const { classId, records } = req.body;
      const userId = req.user?.id || 'usr_teacher';

      await AutomationService.onAttendanceRecorded({
        classId,
        records,
        actorUserId: userId,
      });

      return res.json({
        success: true,
        message: 'Attendance register saved and compliance updated.',
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  // --- PRINCIPAL ANNOUNCEMENTS ---
  static async publishAnnouncement(req: AuthRequest, res: Response) {
    try {
      const { title, content, audience, priority } = req.body;
      const userId = req.user?.id || 'usr_principal';
      const userName = req.user ? 'Principal' : 'School Management';

      const insertRes = await query(`
        INSERT INTO "announcements" ("id", "title", "content", "authorId", "authorName", "audience", "priority")
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *
      `, [uuidv4(), title.trim(), content.trim(), userId, userName, audience || 'ALL', priority || AnnouncementPriority.NORMAL]);

      return res.status(201).json({
        success: true,
        message: 'Announcement published successfully.',
        data: insertRes.rows[0],
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  // --- SUBJECTS & ASSESSMENT LEDGER ---
  static async getSubjects(req: any, res: Response) {
    try {
      const subRes = await query(`SELECT * FROM "subjects" ORDER BY "name" ASC`);
      return res.json({ success: true, data: subRes.rows });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getAssessmentsWithMarks(req: any, res: Response) {
    try {
      const asmtRes = await query(`
        SELECT a.*, s.name as "subjectName", c.name as "className"
        FROM "assignments" a
        LEFT JOIN "subjects" s ON a."subjectId" = s.id
        LEFT JOIN "school_classes" c ON a."classId" = c.id
        ORDER BY a."createdAt" DESC
      `);
      const assignments = asmtRes.rows;

      for (const asmt of assignments) {
        const subsRes = await query(`
          SELECT sub.*, l."fullName", l."surname", l."learnerNumber", l."idNumber"
          FROM "submissions" sub
          JOIN "learners" l ON sub."learnerId" = l.id
          WHERE sub."assignmentId" = $1
        `, [asmt.id]);

        asmt.submissions = subsRes.rows.map((r: any) => ({
          ...r,
          learner: {
            fullName: r.fullName,
            surname: r.surname,
            learnerNumber: r.learnerNumber,
            idNumber: r.idNumber,
          },
        }));
      }

      return res.json({ success: true, data: assignments });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
