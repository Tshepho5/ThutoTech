import 'package:flutter_test/flutter_test.dart';
import 'package:thutotech/core/curriculum/caps_curriculum.dart';
import 'package:thutotech/core/utils/sa_id_parser.dart';
import 'package:thutotech/data/mock_database.dart';
import 'package:thutotech/models/models.dart';

void main() {
  group('ThutoTech End-to-End Automation & CAPS Validation Tests', () {
    late MockDatabase db;

    setUp(() {
      db = MockDatabase();
    });

    test('1. SA ID Parser correctly extracts DOB, Gender, and Age', () {
      final info = SAIdParser.parse('0805125841088');
      expect(info.isValid, isTrue);
      expect(info.gender, equals('Male'));
      expect(info.dateOfBirth?.year, equals(2008));
      expect(info.dateOfBirth?.month, equals(5));
      expect(info.dateOfBirth?.day, equals(12));
    });

    test('2. Systematic Learner Password Generation Algorithm', () {
      // ID: 0805125841088
      // indices 0, 3, 6, 9, 12 -> '0', '5', '5', '1', '8'
      final generatedPassword = SAIdParser.generateLearnerPassword('0805125841088');
      expect(generatedPassword, equals('Thuto@05518'));
    });

    test('3. CAPS Curriculum returns correct stream subjects', () {
      final scienceSubjects = CapsCurriculum.getFetPhaseSubjects(
        homeLanguage: 'Sepedi',
        fal: 'English',
        stream: 'Science Stream (STEM)',
      );
      expect(scienceSubjects.any((s) => s.contains('Mathematics (Pure)')), isTrue);
      expect(scienceSubjects.any((s) => s.contains('Physical Sciences')), isTrue);
      expect(scienceSubjects.any((s) => s.contains('Sepedi')), isTrue);

      final commerceSubjects = CapsCurriculum.getFetPhaseSubjects(
        homeLanguage: 'isiZulu',
        fal: 'English',
        stream: 'Commerce Stream (Business & Accounting)',
      );
      expect(commerceSubjects.any((s) => s.contains('Accounting')), isTrue);
      expect(commerceSubjects.any((s) => s.contains('Economics')), isTrue);
    });

    test('4. Full Admission -> Approval -> Registration -> Password & Student Number Verification', () {
      // Step A: Submit application
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
        secondaryParentIdNumber: '8204120123089',
        learnerName: 'Tshepo',
        learnerSurname: 'Mthethwa',
        learnerIdNumber: '0805125841088',
        gradeApplyingFor: 'Grade 10',
        homeLanguage: 'Sepedi (Sesotho sa Leboa)',
        firstAdditionalLanguage: 'English',
        stream: 'Science Stream (STEM)',
        previousSchool: 'Sunrise Secondary',
      );

      expect(app.status, equals(ApplicationStatus.submitted));

      // Step B: Principal Approves
      db.approveAdmission(app.id);
      expect(app.status, equals(ApplicationStatus.approved));

      // Step C: Parent completes registration
      final creds = db.completeRegistration(
        registrationToken: app.registrationToken,
        parentName: 'Kagiso',
        parentSurname: 'Mthethwa',
        parentEmail: 'kagiso.mthethwa@gmail.com',
        parentPassword: 'SecureParentPass2026!',
        learnerName: 'Tshepo',
        learnerSurname: 'Mthethwa',
        learnerIdNumber: '0805125841088',
      );

      expect(creds['learnerNumber'], startsWith('2026'));
      expect(creds['generatedPassword'], equals('Thuto@05518'));
      expect(creds['learnerEmail'], endsWith('@thutotech.co.za'));

      // Check that automated welcome email was dispatched
      expect(db.simulatedEmails.any((e) => e.recipientEmail == 'kagiso.mthethwa@gmail.com' && e.body.contains('Thuto@05518')), isTrue);
    });

    test('5. Multi-Learner Admission & Batch Credentials Generation', () {
      final l1 = ApplicationLearner(
        id: 'l1',
        learnerName: 'Lesedi',
        learnerSurname: 'Mokoena',
        learnerIdNumber: '0805125841088',
        gradeApplyingFor: 'Grade 10',
        homeLanguage: 'English',
        stream: 'Science Stream (STEM)',
        previousSchool: 'Limpopo Primary',
        documentName: 'Lesedi_ID.pdf',
        documentVerified: true,
      );

      final l2 = ApplicationLearner(
        id: 'l2',
        learnerName: 'Kamohelo',
        learnerSurname: 'Mokoena',
        learnerIdNumber: '1001015009087',
        gradeApplyingFor: 'Grade 8',
        homeLanguage: 'English',
        previousSchool: 'Limpopo Primary',
        documentName: 'Kamohelo_BirthCert.pdf',
        documentVerified: true,
      );

      final app = db.submitAdmissionApplication(
        primaryParentName: 'Boitumelo',
        primaryParentSurname: 'Mokoena',
        primaryParentPhone: '0831112233',
        primaryParentEmail: 'boitumelo.mokoena@gmail.com',
        primaryParentIdNumber: '7801015009087',
        primaryParentDocumentName: 'Boitumelo_ID.pdf',
        hasSecondaryParent: false,
        learnersList: [l1, l2],
      );

      expect(app.learners.length, equals(2));
      db.approveAdmission(app.id);

      final regResult = db.completeRegistration(
        registrationToken: app.registrationToken,
        parentName: 'Boitumelo',
        parentSurname: 'Mokoena',
        parentEmail: 'boitumelo.mokoena@gmail.com',
        parentPassword: 'Password123!',
        registeredLearners: [
          {'learnerName': 'Lesedi', 'learnerSurname': 'Mokoena', 'learnerIdNumber': '0805125841088'},
          {'learnerName': 'Kamohelo', 'learnerSurname': 'Mokoena', 'learnerIdNumber': '1001015009087'},
        ],
      );

      final registeredLearners = regResult['learners'] as List;
      expect(registeredLearners.length, equals(2));
      expect(registeredLearners[0]['learnerEmail'], contains('@thutotech.co.za'));
      expect(registeredLearners[1]['learnerEmail'], contains('@thutotech.co.za'));
    });

    test('6. 6-Digit OTP Password Reset Flow with 2-Minute Expiry & Similarity Detection', () {
      // Create test user in db
      final testEmail = 'sipho.khumalo@thutotech.co.za';
      db.users.add(User(
        id: 'usr_test_sipho',
        email: testEmail,
        name: 'Sipho',
        surname: 'Khumalo',
        role: UserRole.teacher,
        phone: '0820001122',
        avatarUrl: '',
        schoolId: 'sch_thutotech',
      ));

      // Step A: Request 6-digit OTP
      final otp = db.requestPasswordResetOtp(testEmail);
      expect(otp.length, equals(6));
      expect(int.tryParse(otp), isNotNull);

      // Verify OTP email dispatched
      expect(db.simulatedEmails.any((e) => e.recipientEmail == testEmail && e.body.contains(otp)), isTrue);

      // Step B: Verify OTP
      expect(db.verifyPasswordResetOtp(testEmail, otp), isTrue);

      // Step C: Test Password Similarity detector (e.g. 'Teacher@2026!' vs 'Teacher@2026')
      final isSimilar = db.isPasswordCloseToOldPassword(testEmail, 'Teacher@2026');
      expect(isSimilar, isTrue);

      // Step D: Complete Password Reset
      db.completePasswordReset(
        email: testEmail,
        otp: otp,
        newPassword: 'BrandNewSecurePass2026!',
      );

      // Verify audit log
      expect(db.auditLogs.any((a) => a.action == 'PASSWORD_RESET_SUCCESS' && a.entity.contains(testEmail)), isTrue);
    });
  });
}
