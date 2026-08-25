import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

enum PasswordStrength { empty, weak, fair, good, strong }

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  static PasswordStrength calculateStrength(String pass) {
    if (pass.isEmpty) return PasswordStrength.empty;

    int score = 0;
    if (pass.length >= 8) score++;
    if (pass.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'[a-z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+]').hasMatch(pass)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.fair;
    if (score <= 4) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  static bool isSecure(String pass) {
    return pass.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(pass) &&
        RegExp(r'[a-z]').hasMatch(pass) &&
        RegExp(r'[0-9]').hasMatch(pass);
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = calculateStrength(password);
    final isMinLength = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+]').hasMatch(password);

    Color strengthColor;
    String strengthLabel;
    double progressValue;

    switch (strength) {
      case PasswordStrength.empty:
        strengthColor = Colors.transparent;
        strengthLabel = '';
        progressValue = 0.0;
        break;
      case PasswordStrength.weak:
        strengthColor = AppTheme.dangerRed;
        strengthLabel = 'Weak Password';
        progressValue = 0.25;
        break;
      case PasswordStrength.fair:
        strengthColor = AppTheme.warningOrange;
        strengthLabel = 'Fair (Moderate)';
        progressValue = 0.50;
        break;
      case PasswordStrength.good:
        strengthColor = Colors.blue.shade600;
        strengthLabel = 'Good Strength';
        progressValue = 0.75;
        break;
      case PasswordStrength.strong:
        strengthColor = AppTheme.primaryGreen;
        strengthLabel = 'Very Strong & Secure ✓';
        progressValue = 1.0;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: strengthColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: strengthColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Strength:',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
              ),
              Text(
                strengthLabel,
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: strengthColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildRequirementChip('8+ chars', isMinLength),
              _buildRequirementChip('Uppercase (A-Z)', hasUpper),
              _buildRequirementChip('Lowercase (a-z)', hasLower),
              _buildRequirementChip('Number (0-9)', hasDigit),
              _buildRequirementChip('Symbol (!@#)', hasSpecial),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementChip(String label, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: met ? AppTheme.lightGreen : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: met ? AppTheme.primaryGreen.withOpacity(0.4) : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: met ? AppTheme.primaryGreen : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: met ? FontWeight.bold : FontWeight.normal,
              color: met ? AppTheme.primaryNavy : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
