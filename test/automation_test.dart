import 'package:flutter_test/flutter_test.dart';
import 'package:thutotech/data/mock_database.dart';
import 'package:thutotech/models/models.dart';

void main() {
  group('ThutoTech End-to-End Automation Cascade Tests', () {
    late MockDatabase db;

    setUp(() {
      db = MockDatabase();
    });

    test('1. Admission Submission -> Principal Approval -> Automated Email with Token', () {
      // Step A: Parent submits admission
      final app = db.submitAdmissionApplication(
        primaryParentName: 'Kagiso',
        primaryParentSurname: 'Mthethwa',
        primaryParentPhone: '0825551234',
        primaryParentEmail: 'kagiso.mthethwa@gmail.com',
        primaryParentIdNumber: '8001015009087',
        hasSecondaryParent: true,
        secondaryParentName: 'Palesa',
        secondaryParentSurname: 'Mthethwa',
        secondaryParentPhone: '0825555678',
        secondaryParentEmail: 'palesa.mthethwa@gmail.com',
        learnerName: 'Tshepo',
        learnerSurname: 'Mthethwa',
        learnerIdNumber: '0903155800085',
        gradeApplyingFor: 'Grade 10',
        previousSchool: 'Sunrise Secondary',
      );

      expect(app.status, equals(ApplicationStatus.submitted));
      expect(app.registrationToken, startsWith('REG-TT-'));

      // Step B: Principal approves admission
      db.approveAdmission(app.id);

      expect(app.status, equals(ApplicationStatus.approved));
      expect(db.simulatedEmails.any((e) => e.recipientEmail == 'kagiso.mthethwa@gmail.com' && e.body.contains(app.registrationToken)), isTrue);
    });

    test('2. Registration using Token creates Parent and Learner and links them', () {
      final app = db.admissions.firstWhere((a) => a.status == ApplicationStatus.underReview);
      db.approveAdmission(app.id);

      final initialLearnerCount = db.learners.length;
      final initialParentCount = db.parents.length;

      final success = db.completeRegistration(
        registrationToken: app.registrationToken,
        parentName: 'Mandla',
        parentSurname: 'Zulu',
        parentEmail: 'mandla.zulu@outlook.com',
        parentPassword: 'Password123!',
        learnerName: 'Bongani',
        learnerSurname: 'Zulu',
        learnerIdNumber: '1106200876082',
      );

      expect(success, isTrue);
      expect(db.learners.length, equals(initialLearnerCount + 1));
      expect(db.parents.length, equals(initialParentCount + 1));
      final registeredLearner = db.learners.firstWhere((l) => l.idNumber == '1106200876082');
      expect(registeredLearner.fullName, equals('Bongani'));
      expect(registeredLearner.surname, equals('Zulu'));
    });

    test('3. Teacher publishes assignment -> auto creates submissions and notifies learners and parents', () {
      final initialNotifs = db.notifications.length;

      db.createAssignment(
        title: 'Trig Automation Test',
        description: 'Solve questions 1-5',
        subjectId: 'sub_math',
        classId: 'cls_10a',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        maxMarks: 100,
      );

      expect(db.assignments.any((a) => a.title == 'Trig Automation Test'), isTrue);
      expect(db.notifications.length, greaterThan(initialNotifs));
    });

    test('4. Learner submits -> Teacher grades -> Averages recalculated, achievement evaluated, parent notified', () {
      final learner = db.learners.first;
      final asg = db.assignments.first;

      // Submit
      db.submitLearnerAssignment(asg.id, learner.id);
      final sub = db.submissions.firstWhere((s) => s.assignmentId == asg.id && s.learnerId == learner.id);
      expect(sub.status, isNot(equals(SubmissionStatus.notSubmitted)));

      // Grade with 95% (should trigger achievement and update average)
      final initialAchievements = db.achievements.length;
      db.gradeSubmission(
        submissionId: sub.id,
        mark: 95.0,
        feedback: 'Outstanding mastery!',
      );

      expect(sub.status, equals(SubmissionStatus.marked));
      expect(sub.mark, equals(95.0));
      expect(db.achievements.length, greaterThan(initialAchievements));
      expect(db.notifications.any((n) => n.title.contains('Result Update') || n.title.contains('Assignment Marked')), isTrue);
    });

    test('5. Teacher marks absence -> parent alert generated', () {
      final initialNotifs = db.notifications.length;
      db.recordClassAttendance('cls_10a', {
        'lrn_thabo': AttendanceStatus.absent,
      }, reason: 'Unexcused absence test');

      expect(db.notifications.length, greaterThan(initialNotifs));
      expect(db.notifications.any((n) => n.title.contains('Attendance Alert')), isTrue);
    });
  });
}
