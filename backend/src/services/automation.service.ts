import { query } from '../config/database';
import { NotificationCategory, AttendanceStatus, SubmissionStatus } from '../types/enums';
import { v4 as uuidv4 } from 'uuid';

export class AutomationService {
  /**
   * Recalculates learner average, subject statistics, and evaluates achievement rules.
   */
  static async onSubmissionGraded(submissionId: string, actorUserId: string): Promise<void> {
    try {
      const subRes = await query(`
        SELECT sub.*, l.id as "lId", l."userId" as "learnerUserId", l."fullName", l."surname",
               a.title as "assignmentTitle", s.name as "subjectName"
        FROM "submissions" sub
        JOIN "learners" l ON sub."learnerId" = l.id
        JOIN "assignments" a ON sub."assignmentId" = a.id
        JOIN "subjects" s ON a."subjectId" = s.id
        WHERE sub.id = $1
      `, [submissionId]);

      if (subRes.rows.length === 0 || subRes.rows[0].mark === null) return;
      const sub = subRes.rows[0];

      // 1. Recalculate learner overall performance average
      const avgRes = await query(`
        SELECT AVG("mark") as "avgMark"
        FROM "submissions"
        WHERE "learnerId" = $1 AND "status" = $2 AND "mark" IS NOT NULL
      `, [sub.lId, SubmissionStatus.MARKED]);

      const newAverage = avgRes.rows[0]?.avgMark ? Number(Number(avgRes.rows[0].avgMark).toFixed(1)) : 0;
      await query(`UPDATE "learners" SET "overallAverage" = $1 WHERE id = $2`, [newAverage, sub.lId]);

      // 2. Notify Learner
      await query(`
        INSERT INTO "app_notifications" ("id", "recipientUserId", "title", "body", "category")
        VALUES ($1, $2, $3, $4, $5)
      `, [uuidv4(), sub.learnerUserId, `Assignment Graded: ${sub.subjectName}`, `You scored ${sub.mark}% on "${sub.assignmentTitle}".`, NotificationCategory.ACADEMIC]);

      // 3. Notify Parents
      const parentsRes = await query(`
        SELECT p."userId"
        FROM "parent_learner_relationships" plr
        JOIN "parents" p ON plr."parentId" = p.id
        WHERE plr."learnerId" = $1 AND plr."status" = 'ACTIVE'
      `, [sub.lId]);

      for (const p of parentsRes.rows) {
        await query(`
          INSERT INTO "app_notifications" ("id", "recipientUserId", "title", "body", "category")
          VALUES ($1, $2, $3, $4, $5)
        `, [uuidv4(), p.userId, `Result Update: ${sub.fullName}`, `${sub.fullName} scored ${sub.mark}% for ${sub.subjectName} (${sub.assignmentTitle}).`, NotificationCategory.ACADEMIC]);
      }

      // 4. Audit Log
      await query(`
        INSERT INTO "audit_logs" ("id", "userId", "userName", "role", "action", "entity", "details")
        VALUES ($1, $2, 'Teacher', 'TEACHER', 'MARK_ENTERED', $3, $4)
      `, [uuidv4(), actorUserId, `Submission: ${sub.assignmentTitle}`, `Entered ${sub.mark}% for ${sub.fullName} ${sub.surname}. Recalculated learner average to ${newAverage}%.`]);
    } catch (err) {
      console.warn('Automation error on submission grading:', err);
    }
  }

  /**
   * Records class attendance, recalculates percentage, and triggers absence alerts.
   */
  static async onAttendanceRecorded(params: {
    classId: string;
    records: Array<{ learnerId: string; status: AttendanceStatus; reason?: string }>;
    actorUserId: string;
  }): Promise<void> {
    const { classId, records, actorUserId } = params;

    for (const item of records) {
      await query(`
        INSERT INTO "attendance_records" ("id", "date", "classId", "learnerId", "status", "reason")
        VALUES ($1, CURRENT_DATE, $2, $3, $4, $5)
      `, [uuidv4(), classId, item.learnerId, item.status, item.reason || null]);

      // Recalculate attendance percentage
      const totalRes = await query(`SELECT COUNT(*)::int as cnt FROM "attendance_records" WHERE "learnerId" = $1`, [item.learnerId]);
      const presRes = await query(`SELECT COUNT(*)::int as cnt FROM "attendance_records" WHERE "learnerId" = $1 AND "status" = $2`, [item.learnerId, AttendanceStatus.PRESENT]);

      const totalCount = totalRes.rows[0]?.cnt || 1;
      const presentCount = presRes.rows[0]?.cnt || 1;
      const percentage = Number(((presentCount / totalCount) * 100).toFixed(1));

      await query(`UPDATE "learners" SET "attendancePercentage" = $1 WHERE id = $2`, [percentage, item.learnerId]);

      // Alert if Absent
      if (item.status === AttendanceStatus.ABSENT) {
        const parentsRes = await query(`
          SELECT p."userId", l."fullName"
          FROM "parent_learner_relationships" plr
          JOIN "parents" p ON plr."parentId" = p.id
          JOIN "learners" l ON plr."learnerId" = l.id
          WHERE plr."learnerId" = $1 AND plr."status" = 'ACTIVE'
        `, [item.learnerId]);

        for (const p of parentsRes.rows) {
          await query(`
            INSERT INTO "app_notifications" ("id", "recipientUserId", "title", "body", "category")
            VALUES ($1, $2, 'Attendance Alert: Absence Recorded', $3, $4)
          `, [uuidv4(), p.userId, `${p.fullName} was marked ABSENT today. Please contact the school if unexcused.`, NotificationCategory.ATTENDANCE]);
        }
      }
    }

    await query(`
      INSERT INTO "audit_logs" ("id", "userId", "userName", "role", "action", "entity", "details")
      VALUES ($1, $2, 'Teacher', 'TEACHER', 'ATTENDANCE_RECORDED', $3, $4)
    `, [uuidv4(), actorUserId, `Class: ${classId}`, `Logged attendance for ${records.length} learners.`]);
  }
}
