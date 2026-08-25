import { Request, Response } from 'express';
import { query } from '../config/database';

export class AdminController {
  static async getUsers(req: Request, res: Response) {
    try {
      const usersRes = await query(`
        SELECT "id", "email", "name", "surname", "role", "phone", "status", "createdAt"
        FROM "users"
        ORDER BY "createdAt" DESC
      `);
      return res.json({ success: true, data: usersRes.rows, users: usersRes.rows });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getAuditLogs(req: Request, res: Response) {
    try {
      const logsRes = await query(`
        SELECT * FROM "audit_logs"
        ORDER BY "timestamp" DESC
        LIMIT 100
      `);
      return res.json({ success: true, data: logsRes.rows, auditLogs: logsRes.rows });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getSystemHealth(req: Request, res: Response) {
    try {
      const [uRes, lRes, tRes, aRes, audRes] = await Promise.all([
        query(`SELECT COUNT(*)::int as count FROM "users"`),
        query(`SELECT COUNT(*)::int as count FROM "learners"`),
        query(`SELECT COUNT(*)::int as count FROM "teachers"`),
        query(`SELECT COUNT(*)::int as count FROM "admission_applications"`),
        query(`SELECT COUNT(*)::int as count FROM "audit_logs"`),
      ]);

      return res.json({
        success: true,
        data: {
          status: 'OPERATIONAL',
          uptime: process.uptime(),
          database: 'POSTGRESQL_CONNECTED (schema.sql single source of truth)',
          telemetry: {
            userCount: uRes.rows[0]?.count || 0,
            learnerCount: lRes.rows[0]?.count || 0,
            teacherCount: tRes.rows[0]?.count || 0,
            applicationCount: aRes.rows[0]?.count || 0,
            auditCount: audRes.rows[0]?.count || 0,
          },
        },
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
