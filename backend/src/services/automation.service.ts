import { prisma } from '../config/database';
import { NotificationCategory, AttendanceStatus, SubmissionStatus } from '@prisma/client';

export class AutomationService {
  /**
   * Recalculates learner average, subject statistics, and evaluates achievement rules.
   */
  static async onSubmissionGraded(submissionId: string, actorUserId: string): Promise<void> {
    const submission = await prisma.submission.findUnique({
      where: { id: submissionId },
      include: {
        learner: {
          include: {
            user: true,
            parents: {
              include: { parent: { include: { user: true } } },
            },
          },
        },
        assignment: {
          include: { subject: true, class: true },
        },
      },
    });

    if (!submission || submission.mark === null) return;

    const { learner, assignment, mark } = submission;

    // 1. Recalculate learner overall performance average
    const markedSubmissions = await prisma.submission.findMany({
      where: {
        learnerId: learner.id,
        status: SubmissionStatus.MARKED,
        mark: { not: null },
      },
    });

    if (markedSubmissions.length > 0) {
      const totalMarks = markedSubmissions.reduce((sum, s) => sum + (s.mark ?? 0), 0);
      const newAverage = Number((totalMarks / markedSubmissions.length).toFixed(1));

      await prisma.learner.update({
        where: { id: learner.id },
        data: { overallAverage: newAverage },
      });
    }

    // 2. Evaluate rule-based achievement (e.g., Distinction if mark >= 85%)
    if (mark >= 85) {
      const existingAch = await prisma.achievement.findFirst({
        where: {
          learnerId: learner.id,
          title: `Distinction in ${assignment.subject.name}`,
        },
      });

      if (!existingAch) {
        await prisma.achievement.create({
          data: {
            learnerId: learner.id,
            title: `Distinction in ${assignment.subject.name}`,
            description: `Achieved ${mark}% on "${assignment.title}"`,
            iconName: 'emoji_events',
            category: 'ACADEMIC',
          },
        });

        // Notify learner about achievement
        await prisma.appNotification.create({
          data: {
            recipientUserId: learner.userId,
            title: 'New Achievement Earned!',
            body: `Congratulations! You received a Distinction badge in ${assignment.subject.name}.`,
            category: NotificationCategory.ACHIEVEMENT,
          },
        });
      }
    }

    // 3. Notify Learner
    await prisma.appNotification.create({
      data: {
        recipientUserId: learner.userId,
        title: `Assignment Graded: ${assignment.subject.name}`,
        body: `You scored ${mark}% on "${assignment.title}".`,
        category: NotificationCategory.ACADEMIC,
      },
    });

    // 4. Notify Authorised Parents
    for (const rel of learner.parents) {
      await prisma.appNotification.create({
        data: {
          recipientUserId: rel.parent.userId,
          title: `Result Update: ${learner.fullName}`,
          body: `${learner.fullName} scored ${mark}% for ${assignment.subject.name} (${assignment.title}).`,
          category: NotificationCategory.ACADEMIC,
        },
      });
    }

    // 5. Audit Log
    await prisma.auditLog.create({
      data: {
        userId: actorUserId,
        userName: 'Teacher',
        role: 'TEACHER',
        action: 'MARK_ENTERED',
        entity: `Submission: ${assignment.title}`,
        details: `Entered ${mark}% for ${learner.fullName} ${learner.surname}. Recalculated learner performance.`,
      },
    });
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
    const now = new Date();

    for (const item of records) {
      await prisma.attendanceRecord.create({
        data: {
          date: now,
          classId,
          learnerId: item.learnerId,
          status: item.status,
          reason: item.reason,
        },
      });

      // Recalculate attendance percentage
      const totalCount = await prisma.attendanceRecord.count({ where: { learnerId: item.learnerId } });
      const presentCount = await prisma.attendanceRecord.count({
        where: { learnerId: item.learnerId, status: AttendanceStatus.PRESENT },
      });

      const percentage = totalCount > 0 ? Number(((presentCount / totalCount) * 100).toFixed(1)) : 100.0;

      const updatedLearner = await prisma.learner.update({
        where: { id: item.learnerId },
        data: { attendancePercentage: percentage },
        include: {
          parents: { include: { parent: true } },
        },
      });

      // AUTOMATION: If marked Absent, notify parent immediately
      if (item.status === AttendanceStatus.ABSENT) {
        for (const rel of updatedLearner.parents) {
          await prisma.appNotification.create({
            data: {
              recipientUserId: rel.parent.userId,
              title: 'Attendance Alert: Absence Recorded',
              body: `${updatedLearner.fullName} was marked ABSENT today. Please contact the school if unexcused.`,
              category: NotificationCategory.ATTENDANCE,
            },
          });
        }
      }
    }

    await prisma.auditLog.create({
      data: {
        userId: actorUserId,
        userName: 'Teacher',
        role: 'TEACHER',
        action: 'ATTENDANCE_RECORDED',
        entity: `Class: ${classId}`,
        details: `Logged attendance for ${records.length} learners with automatic absence sentinels.`,
      },
    });
  }
}
