import { Request, Response } from 'express';
import { prisma } from '../config/database';

export class AdminController {
  static async getUsers(req: Request, res: Response) {
    try {
      const users = await prisma.user.findMany({
        select: {
          id: true,
          email: true,
          name: true,
          surname: true,
          role: true,
          phone: true,
          status: true,
          createdAt: true,
        },
        orderBy: { createdAt: 'desc' },
      });
      return res.json({ success: true, data: users });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getAuditLogs(req: Request, res: Response) {
    try {
      const logs = await prisma.auditLog.findMany({
        orderBy: { createdAt: 'desc' },
        take: 100,
      });
      return res.json({ success: true, data: logs });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  static async getSystemHealth(req: Request, res: Response) {
    try {
      const userCount = await prisma.user.count();
      const learnerCount = await prisma.learner.count();
      const teacherCount = await prisma.teacher.count();
      const applicationCount = await prisma.admissionApplication.count();
      const auditCount = await prisma.auditLog.count();

      return res.json({
        success: true,
        data: {
          status: 'OPERATIONAL',
          uptime: process.uptime(),
          database: 'POSTGRESQL_CONNECTED',
          telemetry: {
            userCount,
            learnerCount,
            teacherCount,
            applicationCount,
            auditCount,
          },
        },
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
