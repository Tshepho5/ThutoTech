import 'package:flutter/material.dart';
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

  void _initData() {
    // 1. Initial Subjects
    subjects = [
      Subject(id: 'sub_math', name: 'Mathematics', code: 'MATH10', grade: 'Grade 10'),
      Subject(id: 'sub_phys', name: 'Physical Sciences', code: 'PHYS10', grade: 'Grade 10'),
      Subject(id: 'sub_life', name: 'Life Sciences', code: 'LIFE10', grade: 'Grade 10'),
      Subject(id: 'sub_eng', name: 'English First Additional', code: 'ENG10', grade: 'Grade 10'),
      Subject(id: 'sub_geo', name: 'Geography', code: 'GEO10', grade: 'Grade 10'),
    ];

    // 2. Initial Users
    final adminUser = User(
      id: 'usr_admin',
      email: 'admin@thutotech.co.za',
      name: 'Kabelo',
      surname: 'Mokoena',
      role: UserRole.admin,
      phone: '0812345678',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      schoolId: 'sch_thutotech',
    );

    final principalUser = User(
      id: 'usr_principal',
      email: 'principal@thutotech.co.za',
      name: 'Dr. Sipho',
      surname: 'Khumalo',
      role: UserRole.principal,
      phone: '0823456789',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      schoolId: 'sch_thutotech',
    );

    final teacherUser1 = User(
      id: 'usr_teacher1',
      email: 'ndlamini@thutotech.co.za',
      name: 'Nkululeko',
      surname: 'Dlamini',
      role: UserRole.teacher,
      phone: '0834567890',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      schoolId: 'sch_thutotech',
    );

    final parentUser = User(
      id: 'usr_parent',
      email: 'sibusiso.makola@gmail.com',
      name: 'Sibusiso',
      surname: 'Makola',
      role: UserRole.parent,
      phone: '0845678901',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      schoolId: 'sch_thutotech',
    );

    final learnerUser1 = User(
      id: 'usr_learner1',
      email: 'thabo.makola@learner.thutotech.co.za',
      name: 'Thabo',
      surname: 'Makola',
      role: UserRole.learner,
      phone: '0856789012',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
      schoolId: 'sch_thutotech',
    );

    final learnerUser2 = User(
      id: 'usr_learner2',
      email: 'lerato.makola@learner.thutotech.co.za',
      name: 'Lerato',
      surname: 'Makola',
      role: UserRole.learner,
      phone: '0856789013',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      schoolId: 'sch_thutotech',
    );

    users = [adminUser, principalUser, teacherUser1, parentUser, learnerUser1, learnerUser2];

    // Default current user is Parent to demonstrate the user flow immediately
    currentUser = parentUser;

    // 3. Teachers & Classes
    teachers = [
      Teacher(
        id: 'tch_dlamini',
        userId: 'usr_teacher1',
        fullName: 'Nkululeko',
        surname: 'Dlamini',
        assignedSubjectIds: ['sub_math', 'sub_phys'],
        assignedClassIds: ['cls_10a', 'cls_10b'],
        schoolId: 'sch_thutotech',
      ),
    ];

    classes = [
      SchoolClass(id: 'cls_10a', name: 'Grade 10A', grade: 'Grade 10', teacherId: 'tch_dlamini', learnerIds: ['lrn_thabo', 'lrn_lerato']),
      SchoolClass(id: 'cls_10b', name: 'Grade 10B', grade: 'Grade 10', teacherId: 'tch_dlamini', learnerIds: []),
      SchoolClass(id: 'cls_11a', name: 'Grade 11A', grade: 'Grade 11', teacherId: 'tch_dlamini', learnerIds: []),
    ];

    // 4. Learners & Parents
    learners = [
      Learner(
        id: 'lrn_thabo',
        userId: 'usr_learner1',
        idNumber: '0805125841088',
        fullName: 'Thabo',
        surname: 'Makola',
        grade: 'Grade 10',
        className: 'Grade 10A',
        schoolId: 'sch_thutotech',
        parentId: 'par_sibusiso',
        attendancePercentage: 92.5,
        overallAverage: 81.4,
      ),
      Learner(
        id: 'lrn_lerato',
        userId: 'usr_learner2',
        idNumber: '1008240892084',
        fullName: 'Lerato',
        surname: 'Makola',
        grade: 'Grade 8',
        className: 'Grade 8C',
        schoolId: 'sch_thutotech',
        parentId: 'par_sibusiso',
        attendancePercentage: 98.0,
        overallAverage: 88.6,
      ),
    ];

    parents = [
      Parent(
        id: 'par_sibusiso',
        userId: 'usr_parent',
        fullName: 'Sibusiso',
        surname: 'Makola',
        phone: '0845678901',
        email: 'sibusiso.makola@gmail.com',
        hasSecondaryParent: true,
        secondaryParentFullName: 'Nomsa',
        secondaryParentSurname: 'Makola',
        secondaryParentPhone: '0829876543',
        secondaryParentEmail: 'nomsa.makola@gmail.com',
        linkedLearnerIds: ['lrn_thabo', 'lrn_lerato'],
      ),
    ];

    // 5. Assignments & Submissions
    final now = DateTime.now();
    assignments = [
      Assignment(
        id: 'asg_math_03',
        title: 'Mathematics Assignment 03 - Trigonometric Functions',
        description: 'Solve problem set 4A questions 1 to 12. Show all workings and trigonometric identities applied.',
        subjectId: 'sub_math',
        subjectName: 'Mathematics',
        classId: 'cls_10a',
        className: 'Grade 10A',
        teacherId: 'tch_dlamini',
        dueDate: now.add(const Duration(days: 3)),
        maxMarks: 100,
        status: AssignmentStatus.published,
        createdDate: now.subtract(const Duration(days: 2)),
      ),
      Assignment(
        id: 'asg_phys_01',
        title: 'Physics Lab Report - Newton\'s Laws of Motion',
        description: 'Complete the laboratory investigation write-up for velocity and acceleration carts.',
        subjectId: 'sub_phys',
        subjectName: 'Physical Sciences',
        classId: 'cls_10a',
        className: 'Grade 10A',
        teacherId: 'tch_dlamini',
        dueDate: now.add(const Duration(days: 6)),
        maxMarks: 50,
        status: AssignmentStatus.published,
        createdDate: now.subtract(const Duration(days: 1)),
      ),
      Assignment(
        id: 'asg_eng_essay',
        title: 'English Creative Essay - Digital Horizons',
        description: 'Write a 400-word reflective essay exploring technology in modern South African education.',
        subjectId: 'sub_eng',
        subjectName: 'English First Additional',
        classId: 'cls_10a',
        className: 'Grade 10A',
        teacherId: 'tch_dlamini',
        dueDate: now.subtract(const Duration(days: 1)),
        maxMarks: 50,
        status: AssignmentStatus.closed,
        createdDate: now.subtract(const Duration(days: 8)),
      ),
    ];

    submissions = [
      Submission(
        id: 'subm_1',
        assignmentId: 'asg_math_03',
        learnerId: 'lrn_thabo',
        learnerName: 'Thabo Makola',
        submittedAt: now.subtract(const Duration(hours: 4)),
        status: SubmissionStatus.marked,
        mark: 85,
        feedback: 'Excellent breakdown of quadratic and trigonometric identities! Keep up the great precision.',
      ),
      Submission(
        id: 'subm_2',
        assignmentId: 'asg_phys_01',
        learnerId: 'lrn_thabo',
        learnerName: 'Thabo Makola',
        status: SubmissionStatus.notSubmitted,
      ),
      Submission(
        id: 'subm_3',
        assignmentId: 'asg_eng_essay',
        learnerId: 'lrn_thabo',
        learnerName: 'Thabo Makola',
        submittedAt: now.subtract(const Duration(days: 2)),
        status: SubmissionStatus.marked,
        mark: 42,
        feedback: 'Vivid imagery and articulate reasoning throughout the essay.',
      ),
    ];

    // 6. Attendance records
    for (int i = 1; i <= 14; i++) {
      attendanceRecords.add(
        AttendanceRecord(
          id: 'att_thabo_$i',
          date: now.subtract(Duration(days: i)),
          classId: 'cls_10a',
          learnerId: 'lrn_thabo',
          learnerName: 'Thabo Makola',
          status: i == 5 ? AttendanceStatus.absent : (i == 10 ? AttendanceStatus.late : AttendanceStatus.present),
          reason: i == 5 ? 'Flu / Doctor Consultation' : null,
        ),
      );
      attendanceRecords.add(
        AttendanceRecord(
          id: 'att_lerato_$i',
          date: now.subtract(Duration(days: i)),
          classId: 'cls_10a',
          learnerId: 'lrn_lerato',
          learnerName: 'Lerato Makola',
          status: AttendanceStatus.present,
        ),
      );
    }

    // 7. Achievements
    achievements = [
      Achievement(
        id: 'ach_1',
        learnerId: 'lrn_thabo',
        title: 'Maths Distinction',
        description: 'Achieved 85%+ on Mathematics Assignment 03',
        icon: Icons.emoji_events_rounded,
        awardedAt: now.subtract(const Duration(days: 1)),
        category: 'ACADEMIC',
      ),
      Achievement(
        id: 'ach_2',
        learnerId: 'lrn_thabo',
        title: 'Perfect Attendance Week',
        description: '100% on-time attendance for 5 consecutive school days',
        icon: Icons.verified_rounded,
        awardedAt: now.subtract(const Duration(days: 4)),
        category: 'ATTENDANCE',
      ),
      Achievement(
        id: 'ach_3',
        learnerId: 'lrn_lerato',
        title: 'Top Academic Scholar',
        description: 'Maintaining 88%+ aggregate across all subjects',
        icon: Icons.stars_rounded,
        awardedAt: now.subtract(const Duration(days: 3)),
        category: 'ACADEMIC',
      ),
    ];

    // 8. Notifications
    notifications = [
      AppNotification(
        id: 'notif_1',
        recipientUserId: 'usr_parent',
        title: 'Mathematics Mark Published',
        body: 'Thabo scored 85% on Mathematics Assignment 03 - Trigonometric Functions.',
        timestamp: now.subtract(const Duration(hours: 3)),
        category: NotificationCategory.academic,
      ),
      AppNotification(
        id: 'notif_2',
        recipientUserId: 'usr_parent',
        title: 'Upcoming Assignment Deadline',
        body: 'Physics Lab Report is due in 6 days for Thabo.',
        timestamp: now.subtract(const Duration(hours: 10)),
        category: NotificationCategory.academic,
      ),
      AppNotification(
        id: 'notif_3',
        recipientUserId: 'usr_learner1',
        title: 'New Achievement Earned!',
        body: 'Congratulations! You earned the "Maths Distinction" badge.',
        timestamp: now.subtract(const Duration(days: 1)),
        category: NotificationCategory.achievement,
      ),
    ];

    // 9. Announcements
    announcements = [
      Announcement(
        id: 'anc_1',
        title: 'Term 3 Parent-Teacher Academic Conference',
        content: 'The Term 3 Parent-Teacher meeting is scheduled for Saturday, 10:00 AM in the School Great Hall.',
        publishedAt: now.subtract(const Duration(days: 2)),
        authorName: 'Dr. Sipho Khumalo (Principal)',
        audience: 'PARENTS',
        priority: AnnouncementPriority.high,
      ),
      Announcement(
        id: 'anc_2',
        title: 'Annual Science & Tech Fair 2026',
        content: 'All Grade 10 to 12 learners are invited to submit their innovative robotics and coding projects.',
        publishedAt: now.subtract(const Duration(days: 4)),
        authorName: 'School Management',
        audience: 'ALL',
        priority: AnnouncementPriority.normal,
      ),
    ];

    // 10. Audit Logs
    auditLogs = [
      AuditLog(
        id: 'aud_1',
        userId: 'usr_admin',
        userName: 'Kabelo Mokoena',
        role: 'ADMIN',
        action: 'USER_CREATED',
        entity: 'User (Learner: Thabo Makola)',
        timestamp: now.subtract(const Duration(days: 20)),
        details: 'Enrolled learner into Grade 10A and linked to parent Sibusiso Makola',
      ),
      AuditLog(
        id: 'aud_2',
        userId: 'usr_teacher1',
        userName: 'Nkululeko Dlamini',
        role: 'TEACHER',
        action: 'MARK_ENTERED',
        entity: 'Assignment: asg_math_03',
        timestamp: now.subtract(const Duration(hours: 3)),
        details: 'Awarded 85% to Thabo Makola. Auto-recalculated averages and dispatched notification.',
      ),
    ];

    // 11. Automation Rules
    automationRules = [
      AutomationRule(
        id: 'rule_1',
        name: 'Assignment Publication Dispatcher',
        eventName: 'ASSIGNMENT_PUBLISHED',
        conditionDescription: 'When teacher publishes an assignment to class',
        actionDescription: 'Link assignment to all enrolled learners, update calendars, and notify parents.',
        isActive: true,
        lastRun: now.subtract(const Duration(days: 1)),
        runCount: 14,
      ),
      AutomationRule(
        id: 'rule_2',
        name: 'Automated Mark & Performance Recalculator',
        eventName: 'MARK_RECORDED',
        conditionDescription: 'When teacher submits mark for learner',
        actionDescription: 'Recalculate learner average, subject aggregate, class and school statistics.',
        isActive: true,
        lastRun: now.subtract(const Duration(hours: 3)),
        runCount: 42,
      ),
      AutomationRule(
        id: 'rule_3',
        name: 'Attendance Threshold Sentinel',
        eventName: 'ATTENDANCE_RECORDED',
        conditionDescription: 'If learner attendance drops below 85% or 3 consecutive absences',
        actionDescription: 'Generate automated alert for Parent and flag for Principal review.',
        isActive: true,
        lastRun: now.subtract(const Duration(days: 1)),
        runCount: 8,
      ),
    ];

    // 12. Sample Initial Admissions
    admissions = [
      AdmissionApplication(
        id: 'adm_101',
        applicationNumber: 'TT-2026-9042',
        primaryParentName: 'Mandla',
        primaryParentSurname: 'Zulu',
        primaryParentPhone: '0831112233',
        primaryParentEmail: 'mandla.zulu@outlook.com',
        primaryParentIdNumber: '8204155123089',
        hasSecondaryParent: true,
        secondaryParentName: 'Zanele',
        secondaryParentSurname: 'Zulu',
        secondaryParentPhone: '0834445566',
        secondaryParentEmail: 'zanele.zulu@gmail.com',
        learnerName: 'Bongani',
        learnerSurname: 'Zulu',
        learnerIdNumber: '1106200876082',
        gradeApplyingFor: 'Grade 8',
        previousSchool: 'Limpopo Primary Academy',
        status: ApplicationStatus.underReview,
        registrationToken: 'REG-TT-88912',
        submittedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  // Switch Active User Role
  void switchUser(UserRole role) {
    final user = users.firstWhere((u) => u.role == role, orElse: () => users.first);
    currentUser = user;
    notifyListeners();
  }

  // --- Admission & Registration Actions ---

  AdmissionApplication submitAdmissionApplication({
    required String primaryParentName,
    required String primaryParentSurname,
    required String primaryParentPhone,
    required String primaryParentEmail,
    required String primaryParentIdNumber,
    required bool hasSecondaryParent,
    String? secondaryParentName,
    String? secondaryParentSurname,
    String? secondaryParentPhone,
    String? secondaryParentEmail,
    required String learnerName,
    required String learnerSurname,
    required String learnerIdNumber,
    required String gradeApplyingFor,
    required String previousSchool,
  }) {
    final randNum = (1000 + admissions.length * 7 + 34).toString();
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
      hasSecondaryParent: hasSecondaryParent,
      secondaryParentName: secondaryParentName,
      secondaryParentSurname: secondaryParentSurname,
      secondaryParentPhone: secondaryParentPhone,
      secondaryParentEmail: secondaryParentEmail,
      learnerName: learnerName,
      learnerSurname: learnerSurname,
      learnerIdNumber: learnerIdNumber,
      gradeApplyingFor: gradeApplyingFor,
      previousSchool: previousSchool,
      status: ApplicationStatus.submitted,
      registrationToken: token,
      submittedAt: DateTime.now(),
    );

    admissions.insert(0, application);

    // Audit log
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
        details: 'Submitted admission for $learnerName $learnerSurname ($gradeApplyingFor)',
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
    app.reviewerNotes = notes ?? 'Application meets all school admission criteria.';

    // Send Simulated Email to Primary Parent
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

Congratulations! We are delighted to inform you that the admission application for your child, **${app.learnerName} ${app.learnerSurname}** for **${app.gradeApplyingFor}**, has been **APPROVED** for the upcoming academic period.

### Your Official Registration Token:
**${app.registrationToken}**

### Next Steps for Registration:
1. Open the ThutoTech Application.
2. Navigate to the **"Complete Registration"** tab.
3. Enter your registration token (**${app.registrationToken}**) and provide your names, surnames, and learner National ID (**${app.learnerIdNumber}**).
4. Create your secure account password to access the ThutoTech Parent and Learner portals.

We look forward to welcoming ${app.learnerName} to the ThutoTech family!

Warm regards,
**Admissions Office**
ThutoTech Digital School Ecosystem
LEARN • CONNECT • EMPOWER
''',
      ),
    );

    // Add notification
    notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        recipientUserId: 'usr_admin',
        title: 'Admission Approved',
        body: 'Admission application ${app.applicationNumber} for ${app.learnerName} ${app.learnerSurname} approved.',
        timestamp: DateTime.now(),
        category: NotificationCategory.system,
      ),
    );

    // Audit Log
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
        details: 'Approved admission and dispatched official acceptance email to ${app.primaryParentEmail}',
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
    app.reviewerNotes = reason ?? 'Capacity reached for selected grade.';

    simulatedEmails.insert(
      0,
      SimulatedEmail(
        id: 'eml_${DateTime.now().millisecondsSinceEpoch}',
        recipientEmail: app.primaryParentEmail,
        recipientName: '${app.primaryParentName} ${app.primaryParentSurname}',
        subject: 'Admission Application Status Update (${app.applicationNumber})',
        sentAt: DateTime.now(),
        body: 'Dear ${app.primaryParentName},\n\nThank you for applying to ThutoTech. Unfortunately, due to high enrollment capacity, we are unable to offer a placement at this time.',
      ),
    );

    notifyListeners();
  }

  // Complete Registration for Parent and Learner
  bool completeRegistration({
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
      orElse: () => throw Exception('Invalid or unapproved Registration Token.'),
    );

    final parentUserId = 'usr_par_${DateTime.now().millisecondsSinceEpoch}';
    final learnerUserId = 'usr_lrn_${DateTime.now().millisecondsSinceEpoch}';
    final parentId = 'par_${DateTime.now().millisecondsSinceEpoch}';
    final learnerId = 'lrn_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Create Parent User
    final newParentUser = User(
      id: parentUserId,
      email: parentEmail,
      name: parentName,
      surname: parentSurname,
      role: UserRole.parent,
      phone: matchingAdm.primaryParentPhone,
      avatarUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=150',
      schoolId: 'sch_thutotech',
    );

    // 2. Create Learner User
    final newLearnerUser = User(
      id: learnerUserId,
      email: '${learnerName.toLowerCase()}.${learnerSurname.toLowerCase()}@learner.thutotech.co.za',
      name: learnerName,
      surname: learnerSurname,
      role: UserRole.learner,
      phone: '0810000000',
      avatarUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=150',
      schoolId: 'sch_thutotech',
    );

    // 3. Create Entities
    final newLearner = Learner(
      id: learnerId,
      userId: learnerUserId,
      idNumber: learnerIdNumber,
      fullName: learnerName,
      surname: learnerSurname,
      grade: matchingAdm.gradeApplyingFor,
      className: '${matchingAdm.gradeApplyingFor}A',
      schoolId: 'sch_thutotech',
      parentId: parentId,
      attendancePercentage: 100.0,
      overallAverage: 80.0,
    );

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

    // Assign Learner to Class 10A / Grade
    if (classes.isNotEmpty) {
      classes.first.learnerIds.add(learnerId);
    }

    // Set current active user to new parent
    currentUser = newParentUser;

    // Audit Log
    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: parentUserId,
        userName: '$parentName $parentSurname',
        role: 'PARENT',
        action: 'REGISTRATION_COMPLETED',
        entity: 'Parent & Learner Accounts Created',
        timestamp: DateTime.now(),
        details: 'Successfully registered parent $parentName $parentSurname and linked learner $learnerName $learnerSurname ($learnerIdNumber)',
      ),
    );

    notifyListeners();
    return true;
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

    // AUTOMATION CASCADE:
    // 1. Identify enrolled learners
    final enrolledLearners = learners.where((l) => schoolClass.learnerIds.contains(l.id)).toList();

    for (final learner in enrolledLearners) {
      // 2. Create blank submission entry
      submissions.add(
        Submission(
          id: 'subm_${DateTime.now().millisecondsSinceEpoch}_${learner.id}',
          assignmentId: newAssignment.id,
          learnerId: learner.id,
          learnerName: learner.completeName,
          status: SubmissionStatus.notSubmitted,
        ),
      );

      // 3. Notify Learner
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

      // 4. Notify Linked Parent
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

    // Record Audit
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
        details: 'Published to ${schoolClass.name}. Automated notifications sent to ${enrolledLearners.length} learners and their parents.',
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

    // Notify Teacher
    final teacher = teachers.firstWhere((t) => t.id == assignment.teacherId, orElse: () => teachers.first);
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

    // AUTOMATION: Recalculate learner overall performance average
    final learnerSubmissions = submissions.where((s) => s.learnerId == learner.id && s.mark != null).toList();
    if (learnerSubmissions.isNotEmpty) {
      final total = learnerSubmissions.map((s) => s.mark!).reduce((a, b) => a + b);
      learner.overallAverage = double.parse((total / learnerSubmissions.length).toStringAsFixed(1));
    }

    // AUTOMATION: Evaluate achievement rules
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

    // AUTOMATION: Dispatch notification to Learner
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

    // AUTOMATION: Dispatch notification to Parent
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

    // Record Audit Log
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

      // Recalculate learner attendance percentage
      final learnerRecords = attendanceRecords.where((r) => r.learnerId == learnerId).toList();
      final presentCount = learnerRecords.where((r) => r.status == AttendanceStatus.present).length;
      if (learnerRecords.isNotEmpty) {
        learner.attendancePercentage = double.parse(((presentCount / learnerRecords.length) * 100).toStringAsFixed(1));
      }

      // AUTOMATION: Check attendance concerns & trigger Parent Notification if absent
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

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUser?.id ?? 'usr_teacher1',
        userName: currentUser?.fullName ?? 'Teacher',
        role: 'TEACHER',
        action: 'ATTENDANCE_RECORDED',
        entity: 'Class $classId',
        timestamp: now,
        details: 'Recorded attendance for ${attendanceMap.length} learners. Averages and parent alerts updated.',
      ),
    );

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

    // AUTOMATION: Dispatch notifications based on targeted audience
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

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUser?.id ?? 'usr_principal',
        userName: currentUser?.fullName ?? 'Principal',
        role: currentUser?.role.name.toUpperCase() ?? 'PRINCIPAL',
        action: 'ANNOUNCEMENT_PUBLISHED',
        entity: title,
        timestamp: DateTime.now(),
        details: 'Broadcasted to audience "$audience" with priority ${priority.name.toUpperCase()}',
      ),
    );

    notifyListeners();
  }

  // Helper getters for statistics
  double get schoolAverage {
    if (learners.isEmpty) return 0.0;
    final sum = learners.map((l) => l.overallAverage).reduce((a, b) => a + b);
    return double.parse((sum / learners.length).toStringAsFixed(1));
  }

  double get schoolAttendanceRate {
    if (learners.isEmpty) return 0.0;
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
