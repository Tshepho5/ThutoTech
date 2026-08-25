import 'package:intl/intl.dart';

class SAIdInfo {
  final bool isValid;
  final DateTime? dateOfBirth;
  final String? formattedDob;
  final int? age;
  final String? gender; // "Male" or "Female"
  final bool isCitizen;
  final String? error;

  SAIdInfo({
    required this.isValid,
    this.dateOfBirth,
    this.formattedDob,
    this.age,
    this.gender,
    this.isCitizen = true,
    this.error,
  });
}

class SAIdParser {
  /// Parses a 13-digit South African ID Number to extract DOB, Age, and Gender.
  static SAIdInfo parse(String? idNumber) {
    if (idNumber == null || idNumber.trim().length != 13) {
      return SAIdInfo(isValid: false, error: 'ID number must be 13 digits');
    }

    final id = idNumber.trim();
    if (!RegExp(r'^[0-9]{13}$').hasMatch(id)) {
      return SAIdInfo(isValid: false, error: 'ID number must contain only numeric digits');
    }

    try {
      final yy = int.parse(id.substring(0, 2));
      final mm = int.parse(id.substring(2, 4));
      final dd = int.parse(id.substring(4, 6));

      if (mm < 1 || mm > 12 || dd < 1 || dd > 31) {
        return SAIdInfo(isValid: false, error: 'Invalid birth date in ID');
      }

      // Determine century: 00-26 is 2000s, 27-99 is 1900s
      final fullYear = yy <= 26 ? 2000 + yy : 1900 + yy;
      final dob = DateTime(fullYear, mm, dd);
      final now = DateTime.now();

      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      // Gender: digits 6-9 (0000-4999 = Female, 5000-9999 = Male)
      final genderCode = int.parse(id.substring(6, 10));
      final gender = genderCode >= 5000 ? 'Male' : 'Female';

      // Citizenship: digit 10 (0 = SA Citizen, 1 = Permanent Resident)
      final citizenCode = int.parse(id.substring(10, 11));
      final isCitizen = citizenCode == 0;

      // Luhn Checksum validation (MOD 10)
      final isLuhnValid = validateLuhnChecksum(id);
      if (!isLuhnValid) {
        return SAIdInfo(
          isValid: false,
          dateOfBirth: dob,
          formattedDob: DateFormat('dd MMMM yyyy').format(dob),
          age: age,
          gender: gender,
          isCitizen: isCitizen,
          error: 'South African ID failed Luhn mathematical checksum validation (Invalid 13th Check Digit).',
        );
      }

      return SAIdInfo(
        isValid: true,
        dateOfBirth: dob,
        formattedDob: DateFormat('dd MMMM yyyy').format(dob),
        age: age,
        gender: gender,
        isCitizen: isCitizen,
      );
    } catch (_) {
      return SAIdInfo(isValid: false, error: 'Could not parse ID details');
    }
  }

  /// Validates South African National ID checksum using the official Luhn Algorithm (MOD 10)
  static bool validateLuhnChecksum(String id) {
    if (id.length != 13) return false;
    try {
      int sum = 0;
      for (int i = 0; i < 13; i++) {
        int digit = int.parse(id[i]);
        if (i % 2 == 1) {
          digit *= 2;
          if (digit > 9) digit -= 9;
        }
        sum += digit;
      }
      return sum % 10 == 0;
    } catch (_) {
      return false;
    }
  }

  /// Systematic Learner Password generation rule:
  /// "taking the first digit from the ID skip two digits and take the following systematically until the last digit is reached"
  /// Pattern: Thuto@ + id[0] + id[3] + id[6] + id[9] + id[12]
  static String generateLearnerPassword(String idNumber) {
    final cleanId = idNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanId.length < 13) {
      return 'Thuto@2026!';
    }

    final StringBuffer extractedDigits = StringBuffer();
    for (int i = 0; i < cleanId.length; i += 3) {
      extractedDigits.write(cleanId[i]);
    }

    return 'Thuto@$extractedDigits';
  }

  /// Generates learner student number (e.g., 20260001)
  static String generateLearnerNumber(int sequence) {
    final year = DateTime.now().year;
    final seqStr = sequence.toString().padLeft(4, '0');
    return '$year$seqStr';
  }
}
