import 'package:flutter/material.dart';
import '../core/utils/sa_id_parser.dart';
import '../models/models.dart';

class MockDatabase extends ChangeNotifier {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;

  MockDatabase._internal() {
    _initData();
  }

  // Current logged in user context
  User? currentUser;

  // Data collections
  List<User> users = [];
  List<Learner> learners = [];
  List<Parent> parents = [];
  List<Teacher> teachers = [];
  List<SchoolClass> classes = [];
  List<Subject> subjects = [];
  List<Assignment> assignments = [];
  List<Submission> submissions = [];
  List<AttendanceRecord> attendanceRecords = [];
  List<Achievement> achievements = [];
  List<AppNotification> notifications = [];
  List<Announcement> announcements = [];
  List<AuditLog> auditLogs = [];
  List<AdmissionApplication> admissions = [];
  List<AutomationRule> automationRules = [];

  // Simulated Email Inbox for parents/applicants
  List<SimulatedEmail> simulatedEmails = [];

  int _learnerSequence = 1;

  void _initData() {
    // Initial Subjects (CAPS Curriculum Standard)
    subjects = [
      Subject(id: 'sub_math', name: 'Mathematics (Pure)', code: 'MATH10', grade: 'Grade 10'),
      Subject(id: 'sub_phys', name: 'Physical Sciences', code: 'PHYS10', grade: 'Grade 10'),
      Subject(id: 'sub_life', name: 'Life Sciences (Biology)', code: 'LIFE10', grade: 'Grade 10'),
      Subject(id: 'sub_eng', name: 'English First Additional', code: 'ENG10', grade: 'Grade 10'),
      Subject(id: 'sub_geo', name: 'Geography', code: 'GEO10', grade: 'Grade 10'),
      Subject(id: 'sub_acc', name: 'Accounting', code: 'ACC10', grade: 'Grade 10'),
      Subject(id: 'sub_bus', name: 'Business Studies', code: 'BUS10', grade: 'Grade 10'),
      Subject(id: 'sub_tour', name: 'Tourism', code: 'TOUR10', grade: 'Grade 10'),
    ];

    // Initial Classes
    classes = [
      SchoolClass(id: 'cls_8a', name: 'Grade 8A', grade: 'Grade 8', teacherId: 'tch_dlamini', learnerIds: []),
      SchoolClass(id: 'cls_9a', name: 'Grade 9A', grade: 'Grade 9', teacherId: 'tch_dlamini', learnerIds: []),
      SchoolClass(id: 'cls_10a', name: 'Grade 10A (Science)', grade: 'Grade 10', teacherId: 'tch_dlamini', learnerIds: []),
      SchoolClass(id: 'cls_10b', name: 'Grade 10B (Commerce)', grade: 'Grade 10', teacherId: 'tch_dlamini', learnerIds: []),
      SchoolClass(id: 'cls_11a', name: 'Grade 11A', grade: 'Grade 11', teacherId: 'tch_dlamini', learnerIds: []),
      SchoolClass(id: 'cls_12a', name: 'Grade 12A', grade: 'Grade 12', teacherId: 'tch_dlamini', learnerIds: []),
    ];

    // Automation Rules
    final now = DateTime.now();
    automationRules = [
      AutomationRule(
        id: 'rule_1',
        name: 'Assignment Publication Dispatcher',
        eventName: 'ASSIGNMENT_PUBLISHED',
        conditionDescription: 'When teacher publishes an assignment to class',
        actionDescription: 'Link assignment to all enrolled learners, update calendars, and notify parents.',
        isActive: true,
        lastRun: now,
        runCount: 0,
      ),
      AutomationRule(
        id: 'rule_2',
        name: 'Automated Mark & Performance Recalculator',
        eventName: 'MARK_RECORDED',
        conditionDescription: 'When teacher submits mark for learner',
        actionDescription: 'Recalculate learner average, subject aggregate, class and school statistics.',
        isActive: true,
        lastRun: now,
        runCount: 0,
      ),
      AutomationRule(
        id: 'rule_3',
        name: 'Attendance Threshold Sentinel',
        eventName: 'ATTENDANCE_RECORDED',
        conditionDescription: 'If learner attendance drops below 85% or absence logged',
        actionDescription: 'Generate automated alert for Parent and flag for Principal review.',
        isActive: true,
        lastRun: now,
        runCount: 0,
      ),
    ];
  }

  // Switch Active User Role
  void switchUser(UserRole role) {
    final user = users.firstWhere((u) => u.role == role, orElse: () => _createDefaultRoleUser(role));
    currentUser = user;
    notifyListeners();
  }

  User _createDefaultRoleUser(UserRole role) {
    final u = User(
      id: 'usr_${role.name}',
      email: '${role.name}@thutotech.co.za',
      name: role.displayName,
      surname: 'User',
      role: role,
      phone: '0810000000',
      avatarUrl: '',
      schoolId: 'sch_thutotech',
    );
    users.add(u);
    return u;
  }

  // --- Admission Application Submission ---

  AdmissionApplication submitAdmissionApplication({
    required String primaryParentName,
    required String primaryParentSurname,
    required String primaryParentPhone,
    required String primaryParentEmail,
    required String primaryParentIdNumber,
    String? primaryParentGender,
    DateTime? primaryParentDob,
    required bool hasSecondaryParent,
    String? secondaryParentName,
    String? secondaryParentSurname,
    String? secondaryParentPhone,
    String? secondaryParentEmail,
    String? secondaryParentIdNumber,
    String? secondaryParentGender,
    DateTime? secondaryParentDob,
    required String learnerName,
    required String learnerSurname,
    required String learnerIdNumber,
    String? learnerGender,
    DateTime? learnerDob,
    int? learnerAge,
    required String gradeApplyingFor,
    required String homeLanguage,
    String? firstAdditionalLanguage,
    String? stream,
    required String previousSchool,
    bool documentVerified = true,
  }) {
    final randNum = (1000 + admissions.length * 7 + 12).toString();
    final appNumber = 'TT-2026-$randNum';
    final token = 'REG-TT-${10000 + (DateTime.now().millisecondsSinceEpoch % 89999)}';

    final application = AdmissionApplication(
      id: 'adm_${DateTime.now().millisecondsSinceEpoch}',
      applicationNumber: appNumber,
      primaryParentName: primaryParentName,
      primaryParentSurname: primaryParentSurname,
      primaryParentPhone: primaryParentPhone,
      primaryParentEmail: primaryParentEmail,
      primaryParentIdNumber: primaryParentIdNumber,
      primaryParentGender: primaryParentGender,
      primaryParentDob: primaryParentDob,
      hasSecondaryParent: hasSecondaryParent,
      secondaryParentName: secondaryParentName,
      secondaryParentSurname: secondaryParentSurname,
      secondaryParentPhone: secondaryParentPhone,
      secondaryParentEmail: secondaryParentEmail,
      secondaryParentIdNumber: secondaryParentIdNumber,
      secondaryParentGender: secondaryParentGender,
      secondaryParentDob: secondaryParentDob,
      learnerName: learnerName,
      learnerSurname: learnerSurname,
      learnerIdNumber: learnerIdNumber,
      learnerGender: learnerGender,
      learnerDob: learnerDob,
      learnerAge: learnerAge,
      gradeApplyingFor: gradeApplyingFor,
      homeLanguage: homeLanguage,
      firstAdditionalLanguage: firstAdditionalLanguage ?? 'English',
      stream: stream,
      previousSchool: previousSchool,
      documentVerified: documentVerified,
      status: ApplicationStatus.submitted,
      registrationToken: token,
      submittedAt: DateTime.now(),
    );

    admissions.insert(0, application);

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'applicant',
        userName: '$primaryParentName $primaryParentSurname',
        role: 'APPLICANT',
        action: 'ADMISSION_SUBMITTED',
        entity: 'Application: $appNumber',
        timestamp: DateTime.now(),
        details: 'Submitted admission for $learnerName $learnerSurname ($gradeApplyingFor • $homeLanguage${stream != null ? " • $stream" : ""})',
      ),
    );

    notifyListeners();
    return application;
  }

  void approveAdmission(String applicationId, {String? notes}) {
    final index = admissions.indexWhere((a) => a.id == applicationId);
    if (index == -1) return;

    final app = admissions[index];
    app.status = ApplicationStatus.approved;
    app.reviewedAt = DateTime.now();
    app.reviewerNotes = notes ?? 'Application meets all school admission and CAPS criteria.';

    // Send Simulated Email to Primary Parent with Registration Link and Token
    simulatedEmails.insert(
      0,
      SimulatedEmail(
        id: 'eml_${DateTime.now().millisecondsSinceEpoch}',
        recipientEmail: app.primaryParentEmail,
        recipientName: '${app.primaryParentName} ${app.primaryParentSurname}',
        subject: 'Official Admission Approval - ThutoTech Academy (${app.applicationNumber})',
        sentAt: DateTime.now(),
        body: '''
Dear ${app.primaryParentName} ${app.primaryParentSurname},

Congratulations! We are pleased to inform you that the admission application for your child, **${app.learnerName} ${app.learnerSurname}** for **${app.gradeApplyingFor}** (Home Language: ${app.homeLanguage}${app.stream != null ? ", Stream: ${app.stream}" : ""}), has been **APPROVED**.

### Your Official Registration Token:
**${app.registrationToken}**

### Registration Link:
Please click **"Complete Registration"** in the ThutoTech app and enter your registration token **${app.registrationToken}** to activate parent credentials and generate the official learner student number and login password.

${app.hasSecondaryParent ? "Note: You specified a secondary parent (${app.secondaryParentName} ${app.secondaryParentSurname}) who will also be authorized." : ""}

Warm regards,
**Admissions Directorate**
ThutoTech Digital School Ecosystem
LEARN • CONNECT • EMPOWER
''',
      ),
    );

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUser?.id ?? 'usr_principal',
        userName: currentUser?.fullName ?? 'Principal',
        role: 'PRINCIPAL',
        action: 'ADMISSION_APPROVED',
        entity: 'Application: ${app.applicationNumber}',
        timestamp: DateTime.now(),
        details: 'Approved admission for ${app.learnerName} ${app.learnerSurname} and sent registration token to ${app.primaryParentEmail}',
      ),
    );

    notifyListeners();
  }

  void rejectAdmission(String applicationId, {String? reason}) {
    final index = admissions.indexWhere((a) => a.id == applicationId);
    if (index == -1) return;

    final app = admissions[index];
    app.status = ApplicationStatus.rejected;
    app.reviewedAt = DateTime.now();
    app.reviewerNotes = reason ?? 'Grade placement capacity reached for selected stream.';

    simulatedEmails.insert(
      0,
      SimulatedEmail(
        id: 'eml_${DateTime.now().millisecondsSinceEpoch}',
        recipientEmail: app.primaryParentEmail,
        recipientName: '${app.primaryParentName} ${app.primaryParentSurname}',
        subject: 'Admission Application Status Update (${app.applicationNumber})',
        sentAt: DateTime.now(),
        body: 'Dear ${app.primaryParentName},\n\nThank you for applying to ThutoTech. Unfortunately, placement is unavailable at this time.',
      ),
    );

    notifyListeners();
  }

  // --- Complete Registration & Auto-Credential Dispatch ---

  Map<String, dynamic> completeRegistration({
    required String registrationToken,
    required String parentName,
    required String parentSurname,
    required String parentEmail,
    required String parentPassword,
    required String learnerName,
    required String learnerSurname,
    required String learnerIdNumber,
  }) {
    final matchingAdm = admissions.firstWhere(
      (a) => a.registrationToken.trim() == registrationToken.trim() && a.status == ApplicationStatus.approved,
      orElse: () => throw Exception('Invalid or unapproved Registration Token. Please check your token or wait for admission approval.'),
    );

    // 1. Generate Learner Number (e.g. 20260001)
    final learnerNumber = SAIdParser.generateLearnerNumber(_learnerSequence++);
    final learnerEmail = '$learnerNumber@thutotech.co.za';

    // 2. Generate Systematic Learner Password (Thuto@ + digits at indices 0, 3, 6, 9, 12)
    final generatedLearnerPassword = SAIdParser.generateLearnerPassword(learnerIdNumber);

    final parentUserId = 'usr_par_${DateTime.now().millisecondsSinceEpoch}';
    final learnerUserId = 'usr_lrn_${DateTime.now().millisecondsSinceEpoch}';
    final parentId = 'par_${DateTime.now().millisecondsSinceEpoch}';
    final learnerId = 'lrn_${DateTime.now().millisecondsSinceEpoch}';

    // Parse Learner ID for DOB/Age/Gender
    final learnerIdInfo = SAIdParser.parse(learnerIdNumber);

    // Create Parent User
    final newParentUser = User(
      id: parentUserId,
      email: parentEmail,
      name: parentName,
      surname: parentSurname,
      role: UserRole.parent,
      phone: matchingAdm.primaryParentPhone,
      avatarUrl: '',
      schoolId: 'sch_thutotech',
    );

    // Create Learner User
    final newLearnerUser = User(
      id: learnerUserId,
      email: learnerEmail,
      name: learnerName,
      surname: learnerSurname,
      role: UserRole.learner,
      phone: '',
      avatarUrl: '',
      schoolId: 'sch_thutotech',
    );

    // Create Learner Entity
    final newLearner = Learner(
      id: learnerId,
      userId: learnerUserId,
      learnerNumber: learnerNumber,
      idNumber: learnerIdNumber,
      fullName: learnerName,
      surname: learnerSurname,
      gender: learnerIdInfo.gender ?? matchingAdm.learnerGender,
      dateOfBirth: learnerIdInfo.dateOfBirth ?? matchingAdm.learnerDob,
      age: learnerIdInfo.age ?? matchingAdm.learnerAge,
      grade: matchingAdm.gradeApplyingFor,
      className: '${matchingAdm.gradeApplyingFor}A',
      homeLanguage: matchingAdm.homeLanguage,
      firstAdditionalLanguage: matchingAdm.firstAdditionalLanguage,
      stream: matchingAdm.stream,
      schoolId: 'sch_thutotech',
      parentId: parentId,
      attendancePercentage: 100.0,
      overallAverage: 0.0,
    );

    // Create Parent Entity
    final newParent = Parent(
      id: parentId,
      userId: parentUserId,
      fullName: parentName,
      surname: parentSurname,
      phone: matchingAdm.primaryParentPhone,
      email: parentEmail,
      hasSecondaryParent: matchingAdm.hasSecondaryParent,
      secondaryParentFullName: matchingAdm.secondaryParentName,
      secondaryParentSurname: matchingAdm.secondaryParentSurname,
      secondaryParentPhone: matchingAdm.secondaryParentPhone,
      secondaryParentEmail: matchingAdm.secondaryParentEmail,
      linkedLearnerIds: [learnerId],
    );

    users.addAll([newParentUser, newLearnerUser]);
    parents.add(newParent);
    learners.add(newLearner);

    // Assign to Class
    final matchingClass = classes.firstWhere(
      (c) => c.grade == matchingAdm.gradeApplyingFor,
      orElse: () => classes.first,
    );
    matchingClass.learnerIds.add(learnerId);

    // Set current active user to new parent
    currentUser = newParentUser;

    // Send Welcome Email with Generated Learner Credentials
    simulatedEmails.insert(
      0,
      SimulatedEmail(
        id: 'eml_${DateTime.now().millisecondsSinceEpoch}_welcome',
        recipientEmail: parentEmail,
        recipientName: '$parentName $parentSurname',
        subject: 'Official Registration Confirmed & Learner Access Credentials - ThutoTech',
        sentAt: DateTime.now(),
        body: '''
Dear $parentName $parentSurname,

Congratulations! Your registration for **$learnerName $learnerSurname** is now complete and active in the ThutoTech system.

### Learner Official Login Credentials:
- **Learner Student Number:** `$learnerNumber`
- **Learner Login Email:** `$learnerEmail`
- **Generated Password:** `$generatedLearnerPassword`

### Parent Portal Access:
- **Parent Login Email:** `$parentEmail`
- **Parent Password:** *(The password you created during registration)*

$learnerName can now log into the Learner Portal using their email `$learnerEmail` and the password `$generatedLearnerPassword` to view their timetable, subjects, and assignments.

Warm regards,
**Admissions & Records Office**
ThutoTech Digital School Ecosystem
LEARN • CONNECT • EMPOWER
''',
      ),
    );

    // Audit Log
    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: parentUserId,
        userName: '$parentName $parentSurname',
        role: 'PARENT',
        action: 'REGISTRATION_COMPLETED',
        entity: 'Learner: $learnerNumber ($learnerName $learnerSurname)',
        timestamp: DateTime.now(),
        details: 'Registered parent and dispatched learner credentials ($learnerNumber, password generated systematically) to $parentEmail',
      ),
    );

    notifyListeners();
    return {
      'learnerNumber': learnerNumber,
      'learnerEmail': learnerEmail,
      'generatedPassword': generatedLearnerPassword,
    };
  }

  // --- Automation Triggers & Actions ---

  void createAssignment({
    required String title,
    required String description,
    required String subjectId,
    required String classId,
    required DateTime dueDate,
    required double maxMarks,
  }) {
    final subject = subjects.firstWhere((s) => s.id == subjectId, orElse: () => subjects.first);
    final schoolClass = classes.firstWhere((c) => c.id == classId, orElse: () => classes.first);

    final newAssignment = Assignment(
      id: 'asg_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      subjectId: subjectId,
      subjectName: subject.name,
      classId: classId,
      className: schoolClass.name,
      teacherId: currentUser?.id ?? 'tch_dlamini',
      dueDate: dueDate,
      maxMarks: maxMarks,
      status: AssignmentStatus.published,
      createdDate: DateTime.now(),
    );

    assignments.insert(0, newAssignment);

    final enrolledLearners = learners.where((l) => schoolClass.learnerIds.contains(l.id)).toList();

    for (final learner in enrolledLearners) {
      submissions.add(
        Submission(
          id: 'subm_${DateTime.now().millisecondsSinceEpoch}_${learner.id}',
          assignmentId: newAssignment.id,
          learnerId: learner.id,
          learnerName: learner.completeName,
          status: SubmissionStatus.notSubmitted,
        ),
      );

      notifications.insert(
        0,
        AppNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${learner.id}',
          recipientUserId: learner.userId,
          title: 'New Assignment: ${subject.name}',
          body: '$title has been published. Due on ${_formatDate(dueDate)}.',
          timestamp: DateTime.now(),
          category: NotificationCategory.academic,
        ),
      );

      final parent = parents.firstWhere((p) => p.id == learner.parentId, orElse: () => parents.first);
      notifications.insert(
        0,
        AppNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${parent.id}',
          recipientUserId: parent.userId,
          title: 'New Assignment for ${learner.fullName}',
          body: '${learner.fullName} has a new ${subject.name} task due on ${_formatDate(dueDate)}.',
          timestamp: DateTime.now(),
          category: NotificationCategory.academic,
        ),
      );
    }

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUser?.id ?? 'usr_teacher1',
        userName: currentUser?.fullName ?? 'Teacher',
        role: 'TEACHER',
        action: 'ASSIGNMENT_PUBLISHED',
        entity: title,
        timestamp: DateTime.now(),
        details: 'Published to ${schoolClass.name}. Automated notifications sent to ${enrolledLearners.length} learners.',
      ),
    );

    notifyListeners();
  }

  void submitLearnerAssignment(String assignmentId, String learnerId) {
    final index = submissions.indexWhere((s) => s.assignmentId == assignmentId && s.learnerId == learnerId);
    final now = DateTime.now();
    final assignment = assignments.firstWhere((a) => a.id == assignmentId);
    final isLate = now.isAfter(assignment.dueDate);

    if (index != -1) {
      submissions[index].status = isLate ? SubmissionStatus.late : SubmissionStatus.submitted;
      submissions[index].submittedAt = now;
    } else {
      final learner = learners.firstWhere((l) => l.id == learnerId);
      submissions.add(
        Submission(
          id: 'subm_${DateTime.now().millisecondsSinceEpoch}',
          assignmentId: assignmentId,
          learnerId: learnerId,
          learnerName: learner.completeName,
          submittedAt: now,
          status: isLate ? SubmissionStatus.late : SubmissionStatus.submitted,
        ),
      );
    }

    final teacher = teachers.firstWhere((t) => t.id == assignment.teacherId, orElse: () => teachers.isNotEmpty ? teachers.first : Teacher(id: 't', userId: 'u', fullName: 'Teacher', surname: '', assignedSubjectIds: [], assignedClassIds: [], schoolId: ''));
    final learner = learners.firstWhere((l) => l.id == learnerId);
    notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        recipientUserId: teacher.userId,
        title: 'New Submission: ${assignment.title}',
        body: '${learner.completeName} submitted their assignment (${isLate ? 'LATE' : 'ON TIME'}).',
        timestamp: now,
        category: NotificationCategory.academic,
      ),
    );

    notifyListeners();
  }

  void gradeSubmission({
    required String submissionId,
    required double mark,
    required String feedback,
  }) {
    final index = submissions.indexWhere((s) => s.id == submissionId);
    if (index == -1) return;

    final sub = submissions[index];
    sub.mark = mark;
    sub.feedback = feedback;
    sub.status = SubmissionStatus.marked;

    final assignment = assignments.firstWhere((a) => a.id == sub.assignmentId);
    final learner = learners.firstWhere((l) => l.id == sub.learnerId);

    final learnerSubmissions = submissions.where((s) => s.learnerId == learner.id && s.mark != null).toList();
    if (learnerSubmissions.isNotEmpty) {
      final total = learnerSubmissions.map((s) => s.mark!).reduce((a, b) => a + b);
      learner.overallAverage = double.parse((total / learnerSubmissions.length).toStringAsFixed(1));
    }

    if (mark >= 85) {
      achievements.insert(
        0,
        Achievement(
          id: 'ach_${DateTime.now().millisecondsSinceEpoch}',
          learnerId: learner.id,
          title: 'Distinction in ${assignment.subjectName}',
          description: 'Achieved $mark% in "${assignment.title}"',
          icon: Icons.emoji_events_rounded,
          awardedAt: DateTime.now(),
          category: 'ACADEMIC',
        ),
      );
    }

    notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_l',
        recipientUserId: learner.userId,
        title: 'Assignment Marked: ${assignment.subjectName}',
        body: 'You scored $mark% on "${assignment.title}". Feedback: "$feedback"',
        timestamp: DateTime.now(),
        category: NotificationCategory.academic,
      ),
    );

    final parent = parents.firstWhere((p) => p.id == learner.parentId, orElse: () => parents.first);
    notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_p',
        recipientUserId: parent.userId,
        title: 'Result Update: ${learner.fullName}',
        body: '${learner.fullName} received $mark% for ${assignment.subjectName} (${assignment.title}).',
        timestamp: DateTime.now(),
        category: NotificationCategory.academic,
      ),
    );

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUser?.id ?? 'usr_teacher1',
        userName: currentUser?.fullName ?? 'Teacher',
        role: 'TEACHER',
        action: 'MARK_ENTERED',
        entity: 'Submission: ${assignment.title}',
        timestamp: DateTime.now(),
        details: 'Awarded $mark% to ${learner.completeName}. Recalculated learner average to ${learner.overallAverage}%.',
      ),
    );

    notifyListeners();
  }

  void recordClassAttendance(String classId, Map<String, AttendanceStatus> attendanceMap, {String? reason}) {
    final now = DateTime.now();

    attendanceMap.forEach((learnerId, status) {
      final learner = learners.firstWhere((l) => l.id == learnerId);
      attendanceRecords.insert(
        0,
        AttendanceRecord(
          id: 'att_${DateTime.now().millisecondsSinceEpoch}_$learnerId',
          date: now,
          classId: classId,
          learnerId: learnerId,
          learnerName: learner.completeName,
          status: status,
          reason: reason,
        ),
      );

      final learnerRecords = attendanceRecords.where((r) => r.learnerId == learnerId).toList();
      final presentCount = learnerRecords.where((r) => r.status == AttendanceStatus.present).length;
      if (learnerRecords.isNotEmpty) {
        learner.attendancePercentage = double.parse(((presentCount / learnerRecords.length) * 100).toStringAsFixed(1));
      }

      if (status == AttendanceStatus.absent) {
        final parent = parents.firstWhere((p) => p.id == learner.parentId, orElse: () => parents.first);
        notifications.insert(
          0,
          AppNotification(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}_att',
            recipientUserId: parent.userId,
            title: 'Attendance Alert: Absence Recorded',
            body: '${learner.fullName} was marked ABSENT today. Please contact the school if this is unexcused.',
            timestamp: now,
            category: NotificationCategory.attendance,
          ),
        );
      }
    });

    notifyListeners();
  }

  void publishAnnouncement({
    required String title,
    required String content,
    required String audience,
    required AnnouncementPriority priority,
  }) {
    final announcement = Announcement(
      id: 'anc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      content: content,
      publishedAt: DateTime.now(),
      authorName: currentUser?.fullName ?? 'School Management',
      audience: audience,
      priority: priority,
    );

    announcements.insert(0, announcement);

    for (final user in users) {
      bool shouldNotify = false;
      if (audience == 'ALL') shouldNotify = true;
      if (audience == 'PARENTS' && user.role == UserRole.parent) shouldNotify = true;
      if (audience == 'LEARNERS' && user.role == UserRole.learner) shouldNotify = true;
      if (audience == 'TEACHERS' && user.role == UserRole.teacher) shouldNotify = true;

      if (shouldNotify) {
        notifications.insert(
          0,
          AppNotification(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${user.id}',
            recipientUserId: user.id,
            title: 'Announcement: $title',
            body: content,
            timestamp: DateTime.now(),
            category: NotificationCategory.announcement,
          ),
        );
      }
    }

    notifyListeners();
  }

  double get schoolAverage {
    if (learners.isEmpty) return 0.0;
    final sum = learners.map((l) => l.overallAverage).reduce((a, b) => a + b);
    return double.parse((sum / learners.length).toStringAsFixed(1));
  }

  double get schoolAttendanceRate {
    if (learners.isEmpty) return 100.0;
    final sum = learners.map((l) => l.attendancePercentage).reduce((a, b) => a + b);
    return double.parse((sum / learners.length).toStringAsFixed(1));
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class SimulatedEmail {
  final String id;
  final String recipientEmail;
  final String recipientName;
  final String subject;
  final String body;
  final DateTime sentAt;

  SimulatedEmail({
    required this.id,
    required this.recipientEmail,
    required this.recipientName,
    required this.subject,
    required this.body,
    required this.sentAt,
  });
}
