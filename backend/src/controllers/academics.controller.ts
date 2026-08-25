import { Response } from 'express';
import { prisma } from '../config/database';
import { AuthRequest } from '../middleware/auth.middleware';
import { AutomationService } from '../services/automation.service';
import { AssignmentStatus, SubmissionStatus, AnnouncementPriority, NotificationCategory } from '@prisma/client';

export class AcademicsController {
  // --- LEARNER OPERATIONS ---
  static async getLearnerDashboard(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const learner = await prisma.learner.findUnique({
        where: { userId },
        include: {
          submissions: { include: { assignment: { include: { subject: true } } } },
          attendanceRecords: { take: 30, orderBy: { date: 'desc' } },
          achievements: { orderBy: { awardedAt: 'desc' } },
        },
      });

      if (!learner) {
        return res.status(404).json({ success: false, message: 'Learner profile not found.' });
      }

      const activeAssignments = await prisma.assignment.findMany({
        where: { status: AssignmentStatus.PUBLISHED },
        include: { subject: true, class: true },
        orderBy: { dueDate: 'asc' },
      });

      return res.json({
        success: true,
        data: {
          learner,
          activeAssignments,
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

      const learner = await prisma.learner.findUnique({ where: { userId } });
      if (!learner) {
        return res.status(404).json({ success: false, message: 'Learner not found.' });
      }

      const assignment = await prisma.assignment.findUnique({ where: { id: assignmentId } });
      if (!assignment) {
        return res.status(404).json({ success: false, message: 'Assignment not found.' });
      }

      const isLate = new Date() > assignment.dueDate;
      const status = isLate ? SubmissionStatus.LATE : SubmissionStatus.SUBMITTED;

      const submission = await prisma.submission.upsert({
        where: {
          assignmentId_learnerId: {
            assignmentId,
            learnerId: learner.id,
          },
        },
        update: {
          submittedAt: new Date(),
          status,
        },
        create: {
          assignmentId,
          learnerId: learner.id,
          submittedAt: new Date(),
          status,
        },
      });

      return res.json({
        success: true,
        message: `Assignment submitted successfully (${isLate ? 'LATE' : 'ON TIME'}).`,
        data: submission,
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  // --- PARENT OPERATIONS ---
  static async getParentChildren(req: AuthRequest, res: Response) {
    try {
      const userId = req.user?.id;
      const parent = await prisma.parent.findUnique({
        where: { userId },
        include: {
          relationships: {
            include: {
              learner: {
                include: {
                  submissions: { include: { assignment: true } },
                  attendanceRecords: { take: 14, orderBy: { date: 'desc' } },
                  achievements: true,
                },
              },
            },
          },
        },
      });

      if (!parent) {
        return res.status(404).json({ success: false, message: 'Parent profile not found.' });
      }

      const children = parent.relationships.map((r) => r.learner);
      return res.json({ success: true, data: children });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  // --- TEACHER OPERATIONS ---
  static async createAssignment(req: AuthRequest, res: Response) {
    try {
      const { title, description, subjectId, classId, dueDate, maxMarks } = req.body;
      const userId = req.user?.id;

      const teacher = await prisma.teacher.findUnique({ where: { userId } });
      if (!teacher) {
        return res.status(403).json({ success: false, message: 'Teacher profile required.' });
      }

      const assignment = await prisma.assignment.create({
        data: {
          title: title.trim(),
          description: description.trim(),
          subjectId,
          classId,
          teacherId: teacher.id,
          dueDate: new Date(dueDate),
          maxMarks: Number(maxMarks) || 100,
          status: AssignmentStatus.PUBLISHED,
        },
        include: { subject: true, class: true },
      });

      // Auto-create blank submission records for enrolled learners
      const enrolments = await prisma.classEnrolment.findMany({
        where: { classId },
        include: { learner: { include: { parents: { include: { parent: true } } } } },
      });

      for (const enr of enrolments) {
        await prisma.submission.create({
          data: {
            assignmentId: assignment.id,
            learnerId: enr.learnerId,
            status: SubmissionStatus.NOT_SUBMITTED,
          },
        });

        // Notify learner
        await prisma.appNotification.create({
          data: {
            recipientUserId: enr.learner.userId,
            title: `New Assignment: ${assignment.subject.name}`,
            body: `${title} has been assigned. Due date: ${new Date(dueDate).toLocaleDateString()}.`,
            category: NotificationCategory.ACADEMIC,
          },
        });

        // Notify parents
        for (const rel of enr.learner.parents) {
          await prisma.appNotification.create({
            data: {
              recipientUserId: rel.parent.userId,
              title: `New Task for ${enr.learner.fullName}`,
              body: `${enr.learner.fullName} has a new ${assignment.subject.name} task due on ${new Date(dueDate).toLocaleDateString()}.`,
              category: NotificationCategory.ACADEMIC,
            },
          });
        }
      }

      return res.status(201).json({
        success: true,
        message: 'Assignment published and notifications dispatched.',
        data: assignment,
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

      const submission = await prisma.submission.update({
        where: { id: submissionId },
        data: {
          mark: numericMark,
          feedback: feedback ? feedback.trim() : null,
          status: SubmissionStatus.MARKED,
        },
      });

      // Trigger automatic recalculations and notifications
      await AutomationService.onSubmissionGraded(submission.id, userId);

      return res.json({
        success: true,
        message: 'Mark recorded, learner average recalculated, and parent notified.',
        data: submission,
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
        message: 'Attendance register saved, compliance updated, and alerts dispatched.',
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

      const announcement = await prisma.announcement.create({
        data: {
          title: title.trim(),
          content: content.trim(),
          authorId: userId,
          authorName: userName,
          audience: audience || 'ALL',
          priority: (priority as AnnouncementPriority) || AnnouncementPriority.NORMAL,
        },
      });

      return res.status(201).json({
        success: true,
        message: 'Announcement published successfully.',
        data: announcement,
      });
    } catch (error: any) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }
}
