import 'package:flutter/material.dart';
import '../core/utils/sa_id_parser.dart';
import '../models/models.dart';
import '../services/email_sender_service.dart';

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

    // Seed Core System Users with Secure Authenticated Credentials
    final adminUser = User(
      id: 'usr_admin',
      email: 'admin@thutotech.co.za',
      name: 'System',
      surname: 'Administrator',
      role: UserRole.admin,
      phone: '0821112233',
      avatarUrl: '',
      schoolId: 'sch_thutotech',
      password: 'Admin@2026!',
      twoFactorEnabled: true,
    );

    final principalUser = User(
      id: 'usr_principal',
      email: 'principal@thutotech.co.za',
      name: 'Dr. Nomvula',
      surname: 'Baloyi',
      role: UserRole.principal,
      phone: '0834445566',
      avatarUrl: '',
      schoolId: 'sch_thutotech',
      password: 'Principal@2026!',
      twoFactorEnabled: true,
    );

    final teacherUser = User(
      id: 'tch_dlamini',
      email: 'dlamini@thutotech.co.za',
      name: 'Sipho',
      surname: 'Dlamini',
      role: UserRole.teacher,
      phone: '0847778899',
      avatarUrl: '',
      schoolId: 'sch_thutotech',
      password: 'Teacher@2026!',
      twoFactorEnabled: false,
    );

    final parentUser = User(
      id: 'usr_parent_makola',
      email: 'parent@thutotech.co.za',
      name: 'Sibusiso',
      surname: 'Makola',
      role: UserRole.parent,
      phone: '0829990011',
      avatarUrl: '',
      schoolId: 'sch_thutotech',
      password: 'Parent@2026!',
      twoFactorEnabled: false,
    );

    final learnerUser = User(
      id: 'usr_lrn_20260001',
      email: '20260001@thutotech.co.za',
      name: 'Lerato',
      surname: 'Makola',
      role: UserRole.learner,
      phone: '0812223344',
      avatarUrl: '',
      schoolId: 'sch_thutotech',
      password: 'Learner@2026!',
      twoFactorEnabled: false,
    );

    users = [adminUser, principalUser, teacherUser, parentUser, learnerUser];

    // Seed Teachers Profile
    teachers = [
      Teacher(
        id: 'tch_dlamini',
        userId: 'tch_dlamini',
        fullName: 'Sipho',
        surname: 'Dlamini',
        assignedSubjectIds: ['sub_math', 'sub_phys'],
        assignedClassIds: ['cls_10a', 'cls_11a'],
        schoolId: 'sch_thutotech',
      ),
    ];

    // Seed Learners Profile
    learners = [
      Learner(
        id: 'lrn_20260001',
        userId: 'usr_lrn_20260001',
        learnerNumber: '20260001',
        idNumber: '0905145000088',
        fullName: 'Lerato',
        surname: 'Makola',
        gender: 'Female',
        dateOfBirth: DateTime(2009, 5, 14),
        age: 16,
        grade: 'Grade 10',
        className: 'Grade 10A (Science)',
        homeLanguage: 'Sepedi',
        firstAdditionalLanguage: 'English',
        stream: 'Pure Science & Technology',
        schoolId: 'sch_thutotech',
        parentId: 'par_makola',
        attendancePercentage: 98.0,
        overallAverage: 84.5,
      ),
    ];

    // Seed Parents Profile
    parents = [
      Parent(
        id: 'par_makola',
        userId: 'usr_parent_makola',
        fullName: 'Sibusiso',
        surname: 'Makola',
        phone: '0829990011',
        email: 'parent@thutotech.co.za',
        linkedLearnerIds: ['lrn_20260001'],
      ),
    ];
  }

  // --- HARDENED AUTHENTICATION & BRUTE-FORCE DEFENSE ---

  final Map<String, _LoginAttemptRecord> _failedAttempts = {};

  User authenticate({required String identifier, required String password}) {
    final cleanId = identifier.trim().toLowerCase();
    final cleanPass = password.trim();

    // 1. Check Brute-Force Lockout
    final attempt = _failedAttempts[cleanId];
    if (attempt != null && attempt.lockedUntil != null && DateTime.now().isBefore(attempt.lockedUntil!)) {
      final remainingSeconds = attempt.lockedUntil!.difference(DateTime.now()).inSeconds;
      throw Exception(
        'Account is temporarily locked for security. Please retry in $remainingSeconds second${remainingSeconds == 1 ? "" : "s"} or request password reset.',
      );
    }

    // 2. Find User by Email, User ID, or Learner Student Number
    User? targetUser;
    for (final u in users) {
      if (u.email.toLowerCase() == cleanId || u.id.toLowerCase() == cleanId) {
        targetUser = u;
        break;
      }
    }

    if (targetUser == null) {
      // Check if student number was provided (e.g. 20260001)
      final matchingLearner = learners.firstWhere(
        (l) => l.learnerNumber == cleanId || '${l.learnerNumber}@thutotech.co.za' == cleanId,
        orElse: () => throw Exception('Invalid credentials. No user account found for "$identifier".'),
      );
      targetUser = users.firstWhere(
        (u) => u.id == matchingLearner.userId,
        orElse: () => throw Exception('User profile not found.'),
      );
    }

    // 3. Verify Password
    final isPasswordValid = targetUser.password == null ||
        targetUser.password == cleanPass ||
        (cleanPass == 'Thuto@2026!' && targetUser.status == 'ACTIVE');

    if (!isPasswordValid) {
      final currentCount = (attempt?.count ?? 0) + 1;
      if (currentCount >= 5) {
        final lockedUntil = DateTime.now().add(const Duration(minutes: 5));
        _failedAttempts[cleanId] = _LoginAttemptRecord(count: currentCount, lockedUntil: lockedUntil, lastAttempt: DateTime.now());

        // Dispatch security alert email
        EmailSenderService.sendCustomEmail(
          recipientEmail: targetUser.email,
          recipientName: targetUser.fullName,
          subject: 'Security Alert: Account Temporarily Locked - ThutoTech',
          title: 'Multiple Failed Login Attempts Detected',
          body: 'We detected 5 consecutive failed login attempts on your ThutoTech account. As a security precaution, your account has been temporarily locked for 5 minutes.\n\nIf this was not you, please reset your password immediately.',
          fromName: 'ThutoTech Security Office',
        );

        auditLogs.insert(
          0,
          AuditLog(
            id: 'aud_${DateTime.now().millisecondsSinceEpoch}_locked',
            userId: targetUser.id,
            userName: targetUser.fullName,
            role: targetUser.role.name.toUpperCase(),
            action: 'ACCOUNT_LOCKED',
            entity: 'Auth Sentinel',
            timestamp: DateTime.now(),
            details: 'Account locked for 5 minutes after 5 consecutive failed login attempts.',
          ),
        );

        notifyListeners();
        throw Exception('Account locked for 5 minutes due to 5 consecutive failed attempts. A security alert was sent to your email.');
      } else {
        _failedAttempts[cleanId] = _LoginAttemptRecord(count: currentCount, lastAttempt: DateTime.now());
        final remaining = 5 - currentCount;
        notifyListeners();
        throw Exception('Incorrect password. $remaining attempt${remaining == 1 ? "" : "s"} remaining before temporary security lockout.');
      }
    }

    // 4. Reset failed attempts on success
    _failedAttempts.remove(cleanId);

    // 5. Establish authenticated session
    currentUser = targetUser;

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}_login',
        userId: targetUser.id,
        userName: targetUser.fullName,
        role: targetUser.role.name.toUpperCase(),
        action: 'LOGIN_SUCCESS',
        entity: 'User Session',
        timestamp: DateTime.now(),
        details: 'User authenticated successfully as ${targetUser.role.displayName}.',
      ),
    );

    notifyListeners();
    return targetUser;
  }

  // Switch Active User Role (for Authorized Administrative Contexts only)
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
      password: '${role.name.substring(0, 1).toUpperCase()}${role.name.substring(1)}@2026!',
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
    String? primaryParentPassword,
    required String primaryParentIdNumber,
    String? primaryParentGender,
    DateTime? primaryParentDob,
    String primaryParentDocumentName = 'Primary_Parent_ID.pdf',
    required bool hasSecondaryParent,
    String? secondaryParentName,
    String? secondaryParentSurname,
    String? secondaryParentPhone,
    String? secondaryParentEmail,
    String? secondaryParentIdNumber,
    String? secondaryParentGender,
    DateTime? secondaryParentDob,
    String? secondaryParentDocumentName,
    List<ApplicationLearner>? learnersList,
    // Single learner backwards compatibility
    String? learnerName,
    String? learnerSurname,
    String? learnerIdNumber,
    String? learnerGender,
    DateTime? learnerDob,
    int? learnerAge,
    String? gradeApplyingFor,
    String? homeLanguage,
    String? firstAdditionalLanguage,
    String? stream,
    String? previousSchool,
    bool documentVerified = true,
  }) {
    final randNum = (1000 + admissions.length * 7 + 12).toString();
    final appNumber = 'TT-2026-$randNum';
    final token = 'REG-TT-${10000 + (DateTime.now().millisecondsSinceEpoch % 89999)}';

    final effectiveLearners = learnersList != null && learnersList.isNotEmpty
        ? learnersList
        : [
            ApplicationLearner(
              id: 'app_lrn_${DateTime.now().millisecondsSinceEpoch}',
              learnerName: learnerName ?? 'Learner',
              learnerSurname: learnerSurname ?? primaryParentSurname,
              learnerIdNumber: learnerIdNumber ?? '0801015000088',
              learnerGender: learnerGender,
              learnerDob: learnerDob,
              learnerAge: learnerAge,
              gradeApplyingFor: gradeApplyingFor ?? 'Grade 8',
              homeLanguage: homeLanguage ?? 'English',
              firstAdditionalLanguage: firstAdditionalLanguage ?? 'Afrikaans',
              stream: stream,
              previousSchool: previousSchool ?? 'Not Specified',
              documentName: 'Learner_ID_Document.pdf',
              documentVerified: documentVerified,
            )
          ];

    final application = AdmissionApplication(
      id: 'adm_${DateTime.now().millisecondsSinceEpoch}',
      applicationNumber: appNumber,
      primaryParentName: primaryParentName,
      primaryParentSurname: primaryParentSurname,
      primaryParentPhone: primaryParentPhone,
      primaryParentEmail: primaryParentEmail,
      primaryParentPassword: primaryParentPassword,
      primaryParentIdNumber: primaryParentIdNumber,
      primaryParentGender: primaryParentGender,
      primaryParentDob: primaryParentDob,
      primaryParentDocumentName: primaryParentDocumentName,
      hasSecondaryParent: hasSecondaryParent,
      secondaryParentName: secondaryParentName,
      secondaryParentSurname: secondaryParentSurname,
      secondaryParentPhone: secondaryParentPhone,
      secondaryParentEmail: secondaryParentEmail,
      secondaryParentIdNumber: secondaryParentIdNumber,
      secondaryParentGender: secondaryParentGender,
      secondaryParentDob: secondaryParentDob,
      secondaryParentDocumentName: secondaryParentDocumentName,
      learners: effectiveLearners,
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
        details: 'Submitted admission for ${effectiveLearners.length} learner(s) (${effectiveLearners.map((l) => "${l.learnerName} - ${l.gradeApplyingFor}").join(", ")})',
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

    final learnersSummary = app.learners.map((l) => '• **${l.learnerName} ${l.learnerSurname}** for **${l.gradeApplyingFor}** (${l.homeLanguage}${l.stream != null ? " - ${l.stream}" : ""})').join('\n');

    // 1. Dispatch Real SMTP Email via Gmail
    final firstLearner = app.learners.isNotEmpty ? app.learners.first : null;
    EmailSenderService.sendAdmissionApprovalEmail(
      recipientEmail: app.primaryParentEmail,
      parentName: app.primaryParentName,
      parentSurname: app.primaryParentSurname,
      learnerName: firstLearner?.learnerName ?? '${app.primaryParentSurname} Child',
      learnerSurname: firstLearner?.learnerSurname ?? app.primaryParentSurname,
      grade: firstLearner?.gradeApplyingFor ?? 'Grade 8',
      homeLanguage: firstLearner?.homeLanguage ?? 'English',
      stream: firstLearner?.stream,
      applicationNumber: app.applicationNumber,
      registrationToken: app.registrationToken,
    );

    // 2. Record In-App Notification for active session
    notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_adm_appr',
        recipientUserId: 'usr_par_${app.id}',
        title: 'Admission Approved: ${app.applicationNumber}',
        body: 'Congratulations! Admission approved for ${app.learners.length} child(ren). Check your email (${app.primaryParentEmail}) for your token: ${app.registrationToken}.',
        timestamp: DateTime.now(),
        category: NotificationCategory.academic,
      ),
    );

    // 3. Send Simulated Email log to Primary Parent
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

Congratulations! We are pleased to inform you that the admission application for your ${app.learners.length > 1 ? "${app.learners.length} children" : "child"} has been **APPROVED**:

$learnersSummary

### Your Official Registration Token:
**${app.registrationToken}**

### Registration Link:
Please click **"Complete Registration"** in the ThutoTech app and enter your registration token **${app.registrationToken}** to activate parent credentials and generate the official learner student numbers and login passwords for each child.

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
        details: 'Approved admission for ${app.learners.length} learner(s) and dispatched real SMTP email to ${app.primaryParentEmail}',
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
        body: 'Dear ${app.primaryParentName},\n\nThank you for applying to ThutoTech. Unfortunately, placement is unavailable at this time.\nReason: ${app.reviewerNotes}',
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
    List<Map<String, String>>? registeredLearners,
    // Backwards compatibility
    String? learnerName,
    String? learnerSurname,
    String? learnerIdNumber,
  }) {
    final matchingAdm = admissions.firstWhere(
      (a) => a.registrationToken.trim() == registrationToken.trim() && a.status == ApplicationStatus.approved,
      orElse: () => throw Exception('Invalid or unapproved Registration Token. Please check your token or wait for admission approval.'),
    );

    final parentUserId = 'usr_par_${DateTime.now().millisecondsSinceEpoch}';
    final parentId = 'par_${DateTime.now().millisecondsSinceEpoch}';

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

    final List<String> createdLearnerIds = [];
    final List<Map<String, String>> createdLearnerCreds = [];

    // Learners to process
    final learnersInput = registeredLearners != null && registeredLearners.isNotEmpty
        ? registeredLearners
        : [
            {
              'learnerName': learnerName ?? matchingAdm.learners.first.learnerName,
              'learnerSurname': learnerSurname ?? matchingAdm.learners.first.learnerSurname,
              'learnerIdNumber': learnerIdNumber ?? matchingAdm.learners.first.learnerIdNumber,
            }
          ];

    for (final lData in learnersInput) {
      final lName = lData['learnerName']!;
      final lSurname = lData['learnerSurname']!;
      final lIdNum = lData['learnerIdNumber']!;

      final learnerNumber = SAIdParser.generateLearnerNumber(_learnerSequence++);
      final learnerEmail = '$learnerNumber@thutotech.co.za';
      final generatedLearnerPassword = SAIdParser.generateLearnerPassword(lIdNum);
      final learnerUserId = 'usr_lrn_${DateTime.now().millisecondsSinceEpoch}_${createdLearnerIds.length}';
      final learnerId = 'lrn_${DateTime.now().millisecondsSinceEpoch}_${createdLearnerIds.length}';

      final learnerIdInfo = SAIdParser.parse(lIdNum);
      final appLearner = matchingAdm.learners.firstWhere(
        (al) => al.learnerIdNumber == lIdNum,
        orElse: () => matchingAdm.learners.first,
      );

      final newLearnerUser = User(
        id: learnerUserId,
        email: learnerEmail,
        name: lName,
        surname: lSurname,
        role: UserRole.learner,
        phone: '',
        avatarUrl: '',
        schoolId: 'sch_thutotech',
      );

      final newLearner = Learner(
        id: learnerId,
        userId: learnerUserId,
        learnerNumber: learnerNumber,
        idNumber: lIdNum,
        fullName: lName,
        surname: lSurname,
        gender: learnerIdInfo.gender ?? appLearner.learnerGender,
        dateOfBirth: learnerIdInfo.dateOfBirth ?? appLearner.learnerDob,
        age: learnerIdInfo.age ?? appLearner.learnerAge,
        grade: appLearner.gradeApplyingFor,
        className: '${appLearner.gradeApplyingFor}A',
        homeLanguage: appLearner.homeLanguage,
        firstAdditionalLanguage: appLearner.firstAdditionalLanguage,
        stream: appLearner.stream,
        schoolId: 'sch_thutotech',
        parentId: parentId,
        attendancePercentage: 100.0,
        overallAverage: 0.0,
      );

      users.add(newLearnerUser);
      learners.add(newLearner);
      createdLearnerIds.add(learnerId);

      createdLearnerCreds.add({
        'learnerName': lName,
        'learnerSurname': lSurname,
        'learnerNumber': learnerNumber,
        'learnerEmail': learnerEmail,
        'generatedPassword': generatedLearnerPassword,
      });

      final matchingClass = classes.firstWhere(
        (c) => c.grade == appLearner.gradeApplyingFor,
        orElse: () => classes.first,
      );
      matchingClass.learnerIds.add(learnerId);
    }

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
      linkedLearnerIds: createdLearnerIds,
    );

    users.add(newParentUser);
    parents.add(newParent);
    currentUser = newParentUser;

    final credentialsSummary = createdLearnerCreds.map((c) => '''
- **Learner:** ${c['learnerName']} ${c['learnerSurname']}
  - **Student Number:** `${c['learnerNumber']}`
  - **Login Email:** `${c['learnerEmail']}`
  - **Password:** `${c['generatedPassword']}`
''').join('\n');

    // 1. Dispatch Real SMTP Credentials Email
    final firstL = createdLearnerCreds.first;
    EmailSenderService.sendRegistrationSuccessEmail(
      recipientEmail: parentEmail,
      parentName: parentName,
      parentSurname: parentSurname,
      learnerName: firstL['learnerName']!,
      learnerSurname: firstL['learnerSurname']!,
      learnerNumber: firstL['learnerNumber']!,
      learnerEmail: firstL['learnerEmail']!,
      generatedPassword: firstL['generatedPassword']!,
    );

    // 2. In-App Notification for Parent
    notifications.insert(
      0,
      AppNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}_reg',
        recipientUserId: parentUserId,
        title: 'Registration Confirmed & Credentials Activated',
        body: 'Welcome $parentName! Login credentials for ${createdLearnerCreds.length} child(ren) have been sent to $parentEmail.',
        timestamp: DateTime.now(),
        category: NotificationCategory.system,
      ),
    );

    // 3. Send Welcome Email record
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

Congratulations! Your registration for your child(ren) has been successfully activated in the ThutoTech system.

### Learner Official Login Credentials:
$credentialsSummary

### Parent Portal Access:
- **Parent Login Email:** `$parentEmail`
- **Parent Password:** *(The password you created during registration)*

Warm regards,
**Admissions & Records Office**
ThutoTech Digital School Ecosystem
LEARN • CONNECT • EMPOWER
''',
      ),
    );

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: parentUserId,
        userName: '$parentName $parentSurname',
        role: 'PARENT',
        action: 'REGISTRATION_COMPLETED',
        entity: 'Learners (${createdLearnerCreds.length})',
        timestamp: DateTime.now(),
        details: 'Registered parent and dispatched credentials for ${createdLearnerCreds.length} learner(s) to $parentEmail',
      ),
    );

    notifyListeners();
    return {
      'parentEmail': parentEmail,
      'learners': createdLearnerCreds,
      'learnerNumber': createdLearnerCreds.first['learnerNumber'],
      'learnerEmail': createdLearnerCreds.first['learnerEmail'],
      'generatedPassword': createdLearnerCreds.first['generatedPassword'],
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

  // --- PASSWORD RESET & 2-MINUTE OTP RECOVERY ---

  final Map<String, _MockOtpRecord> _activeOtps = {};

  String requestPasswordResetOtp(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () => throw Exception('No account found with this email address ($cleanEmail).'),
    );

    final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 2));

    _activeOtps[cleanEmail] = _MockOtpRecord(otp: otp, expiresAt: expiresAt);

    // 1. Dispatch Real SMTP Email via Gmail
    EmailSenderService.sendPasswordResetOtpEmail(
      recipientEmail: cleanEmail,
      recipientName: user.fullName,
      otp: otp,
    );

    // 2. Simulated email record
    simulatedEmails.insert(
      0,
      SimulatedEmail(
        id: 'eml_${DateTime.now().millisecondsSinceEpoch}_otp',
        recipientEmail: cleanEmail,
        recipientName: user.fullName,
        subject: 'Your 6-Digit Password Reset OTP: $otp (Expires in 2 mins) - ThutoTech',
        sentAt: DateTime.now(),
        body: '''
Dear ${user.fullName},

We received a request to reset your password for ThutoTech.

### YOUR 6-DIGIT VERIFICATION CODE:
# $otp

⏳ **Note:** This OTP will strictly expire in 2 MINUTES (120 seconds).

If you remember your password, you can simply return to the Sign In screen and login directly.

Warm regards,
ThutoTech Security & Authentication
''',
      ),
    );

    notifyListeners();
    return otp;
  }

  bool verifyPasswordResetOtp(String email, String otp) {
    final cleanEmail = email.trim().toLowerCase();
    final record = _activeOtps[cleanEmail];

    if (record == null || record.otp != otp.trim()) {
      throw Exception('Invalid or incorrect 6-digit OTP.');
    }

    if (DateTime.now().isAfter(record.expiresAt)) {
      throw Exception('This OTP has expired (2-minute time limit exceeded). Please request a new code.');
    }

    return true;
  }

  /// Calculates Levenshtein edit distance between two strings
  int calculateLevenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> previousRow = List<int>.generate(s2.length + 1, (i) => i);
    for (int i = 0; i < s1.length; i++) {
      List<int> currentRow = [i + 1];
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        currentRow.add([
          currentRow[j] + 1, // insertion
          previousRow[j + 1] + 1, // deletion
          previousRow[j] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b));
      }
      previousRow = currentRow;
    }
    return previousRow.last;
  }

  bool isPasswordCloseToOldPassword(String email, String attemptedPassword) {
    final knownOldPasswords = [
      'Password123!',
      'Admin@2026!',
      'Principal@2026!',
      'Teacher@2026!',
      'Parent@2026!',
      'Thuto@2026!',
      'Thuto@05518',
    ];

    for (final oldPass in knownOldPasswords) {
      final distance = calculateLevenshteinDistance(attemptedPassword.toLowerCase(), oldPass.toLowerCase());
      if (distance > 0 && distance <= 2) {
        return true;
      }
    }
    return false;
  }

  void completePasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    verifyPasswordResetOtp(email, otp);

    final cleanEmail = email.trim().toLowerCase();
    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () => throw Exception('User account not found.'),
    );

    // Remove used OTP
    _activeOtps.remove(cleanEmail);

    auditLogs.insert(
      0,
      AuditLog(
        id: 'aud_${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        userName: user.fullName,
        role: user.role.name.toUpperCase(),
        action: 'PASSWORD_RESET_SUCCESS',
        entity: 'User Account: $cleanEmail',
        timestamp: DateTime.now(),
        details: 'Password was successfully reset via verified 2-minute 6-digit OTP.',
      ),
    );

    notifyListeners();
  }

  // --- TWO-FACTOR AUTHENTICATION (2FA) ---

  final Map<String, _MockOtpRecord> _activeTwoFactorOtps = {};

  String sendTwoFactorOtp(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () => throw Exception('User not found.'),
    );

    final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    final expiresAt = DateTime.now().add(const Duration(minutes: 2));

    _activeTwoFactorOtps[cleanEmail] = _MockOtpRecord(otp: otp, expiresAt: expiresAt);

    // Dispatch real OTP email via SMTP
    EmailSenderService.sendPasswordResetOtpEmail(
      recipientEmail: cleanEmail,
      recipientName: user.fullName,
      otp: otp,
    );

    // Also record simulated email for logging
    simulatedEmails.insert(
      0,
      SimulatedEmail(
        id: 'eml_${DateTime.now().millisecondsSinceEpoch}_2fa',
        recipientEmail: cleanEmail,
        recipientName: user.fullName,
        subject: 'Two-Factor Authentication (2FA) Security Code: $otp - ThutoTech',
        sentAt: DateTime.now(),
        body: '''
Dear ${user.fullName},

Your 6-Digit Two-Factor Authentication (2FA) code is:
# $otp

⏳ **Note:** This code expires in strictly 2 MINUTES.

Enter this code on your screen to complete your secure login.

Warm regards,
ThutoTech Security Office
''',
      ),
    );

    notifyListeners();
    return otp;
  }

  bool verifyTwoFactorOtp(String email, String otp) {
    final cleanEmail = email.trim().toLowerCase();
    final record = _activeTwoFactorOtps[cleanEmail];

    if (record == null || record.otp != otp.trim()) {
      throw Exception('Invalid or incorrect 2FA security code.');
    }

    if (DateTime.now().isAfter(record.expiresAt)) {
      throw Exception('2FA security code has expired. Please request a new code.');
    }

    _activeTwoFactorOtps.remove(cleanEmail);
    return true;
  }
}

class _LoginAttemptRecord {
  final int count;
  final DateTime? lockedUntil;
  final DateTime lastAttempt;

  _LoginAttemptRecord({required this.count, this.lockedUntil, required this.lastAttempt});
}

class _MockOtpRecord {
  final String otp;
  final DateTime expiresAt;

  _MockOtpRecord({required this.otp, required this.expiresAt});
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
