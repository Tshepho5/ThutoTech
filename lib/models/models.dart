import 'package:flutter/material.dart';

enum UserRole {
  learner,
  parent,
  teacher,
  principal,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.learner:
        return 'Learner';
      case UserRole.parent:
        return 'Parent / Guardian';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.principal:
        return 'Principal';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.learner:
        return Icons.school_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
      case UserRole.teacher:
        return Icons.person_search_rounded;
      case UserRole.principal:
        return Icons.account_balance_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String surname;
  final UserRole role;
  final String phone;
  final String avatarUrl;
  final String schoolId;
  final String status; // ACTIVE, INVITED, DEACTIVATED

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.role,
    required this.phone,
    required this.avatarUrl,
    required this.schoolId,
    this.status = 'ACTIVE',
  });

  String get fullName => '$name $surname';
}

class Learner {
  final String id;
  final String userId;
  final String idNumber;
  final String fullName;
  final String surname;
  final String grade;
  final String className;
  final String schoolId;
  final String parentId;
  final String? secondaryParentId;
  double attendancePercentage;
  double overallAverage;

  Learner({
    required this.id,
    required this.userId,
    required this.idNumber,
    required this.fullName,
    required this.surname,
    required this.grade,
    required this.className,
    required this.schoolId,
    required this.parentId,
    this.secondaryParentId,
    this.attendancePercentage = 95.0,
    this.overallAverage = 78.0,
  });

  String get completeName => '$fullName $surname';
}

class Parent {
  final String id;
  final String userId;
  final String fullName;
  final String surname;
  final String phone;
  final String email;
  final bool hasSecondaryParent;
  final String? secondaryParentFullName;
  final String? secondaryParentSurname;
  final String? secondaryParentPhone;
  final String? secondaryParentEmail;
  final List<String> linkedLearnerIds;

  Parent({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.surname,
    required this.phone,
    required this.email,
    this.hasSecondaryParent = false,
    this.secondaryParentFullName,
    this.secondaryParentSurname,
    this.secondaryParentPhone,
    this.secondaryParentEmail,
    required this.linkedLearnerIds,
  });

  String get completeName => '$fullName $surname';
}

class Teacher {
  final String id;
  final String userId;
  final String fullName;
  final String surname;
  final List<String> assignedSubjectIds;
  final List<String> assignedClassIds;
  final String schoolId;

  Teacher({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.surname,
    required this.assignedSubjectIds,
    required this.assignedClassIds,
    required this.schoolId,
  });

  String get completeName => '$fullName $surname';
}

class SchoolClass {
  final String id;
  final String name; // e.g. "10A"
  final String grade; // e.g. "Grade 10"
  final String teacherId;
  final List<String> learnerIds;

  SchoolClass({
    required this.id,
    required this.name,
    required this.grade,
    required this.teacherId,
    required this.learnerIds,
  });
}

class Subject {
  final String id;
  final String name;
  final String code;
  final String grade;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.grade,
  });
}

enum AssignmentStatus { draft, published, closed }

class Assignment {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final String classId;
  final String className;
  final String teacherId;
  final DateTime dueDate;
  final double maxMarks;
  AssignmentStatus status;
  final DateTime createdDate;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.dueDate,
    this.maxMarks = 100,
    this.status = AssignmentStatus.published,
    required this.createdDate,
  });
}

enum SubmissionStatus { notSubmitted, submitted, late, marked }

class Submission {
  final String id;
  final String assignmentId;
  final String learnerId;
  final String learnerName;
  DateTime? submittedAt;
  SubmissionStatus status;
  double? mark;
  String? feedback;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.learnerId,
    required this.learnerName,
    this.submittedAt,
    this.status = SubmissionStatus.notSubmitted,
    this.mark,
    this.feedback,
  });
}

enum AttendanceStatus { present, absent, late, excused }

class AttendanceRecord {
  final String id;
  final DateTime date;
  final String classId;
  final String learnerId;
  final String learnerName;
  final AttendanceStatus status;
  final String? reason;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.classId,
    required this.learnerId,
    required this.learnerName,
    required this.status,
    this.reason,
  });
}

class Achievement {
  final String id;
  final String learnerId;
  final String title;
  final String description;
  final IconData icon;
  final DateTime awardedAt;
  final String category;

  Achievement({
    required this.id,
    required this.learnerId,
    required this.title,
    required this.description,
    required this.icon,
    required this.awardedAt,
    required this.category,
  });
}

enum NotificationCategory { academic, attendance, announcement, achievement, system }

class AppNotification {
  final String id;
  final String recipientUserId;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final NotificationCategory category;
  final String? actionLink;

  AppNotification({
    required this.id,
    required this.recipientUserId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.category,
    this.actionLink,
  });
}

enum AnnouncementPriority { normal, high, urgent }

class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final String authorName;
  final String audience; // ALL, PARENTS, LEARNERS, TEACHERS, GRADE_10, etc.
  final AnnouncementPriority priority;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.authorName,
    required this.audience,
    this.priority = AnnouncementPriority.normal,
  });
}

class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final String role;
  final String action;
  final String entity;
  final DateTime timestamp;
  final String details;

  AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    required this.action,
    required this.entity,
    required this.timestamp,
    required this.details,
  });
}

enum ApplicationStatus { submitted, underReview, approved, rejected }

class AdmissionApplication {
  final String id;
  final String applicationNumber;
  // Primary Parent
  final String primaryParentName;
  final String primaryParentSurname;
  final String primaryParentPhone;
  final String primaryParentEmail;
  final String primaryParentIdNumber;
  // Optional Secondary Parent
  final bool hasSecondaryParent;
  final String? secondaryParentName;
  final String? secondaryParentSurname;
  final String? secondaryParentPhone;
  final String? secondaryParentEmail;
  // Learner Info
  final String learnerName;
  final String learnerSurname;
  final String learnerIdNumber;
  final String gradeApplyingFor;
  final String previousSchool;
  // Status
  ApplicationStatus status;
  final String registrationToken;
  final DateTime submittedAt;
  DateTime? reviewedAt;
  String? reviewerNotes;

  AdmissionApplication({
    required this.id,
    required this.applicationNumber,
    required this.primaryParentName,
    required this.primaryParentSurname,
    required this.primaryParentPhone,
    required this.primaryParentEmail,
    required this.primaryParentIdNumber,
    this.hasSecondaryParent = false,
    this.secondaryParentName,
    this.secondaryParentSurname,
    this.secondaryParentPhone,
    this.secondaryParentEmail,
    required this.learnerName,
    required this.learnerSurname,
    required this.learnerIdNumber,
    required this.gradeApplyingFor,
    required this.previousSchool,
    this.status = ApplicationStatus.submitted,
    required this.registrationToken,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerNotes,
  });
}

class AutomationRule {
  final String id;
  final String name;
  final String eventName;
  final String conditionDescription;
  final String actionDescription;
  bool isActive;
  DateTime lastRun;
  int runCount;

  AutomationRule({
    required this.id,
    required this.name,
    required this.eventName,
    required this.conditionDescription,
    required this.actionDescription,
    this.isActive = true,
    required this.lastRun,
    this.runCount = 0,
  });
}
