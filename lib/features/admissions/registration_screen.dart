import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation/input_validators.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../widgets/password_strength_meter.dart';

class RegistrationScreen extends StatefulWidget {
  final MockDatabase db;

  const RegistrationScreen({super.key, required this.db});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tokenCtrl = TextEditingController();
  final _parentNameCtrl = TextEditingController();
  final _parentSurnameCtrl = TextEditingController();
  final _parentEmailCtrl = TextEditingController();
  final _parentPasswordCtrl = TextEditingController();

  final _learnerNameCtrl = TextEditingController();
  final _learnerSurnameCtrl = TextEditingController();
  final _learnerIdCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _parentPasswordCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentSurnameCtrl.dispose();
    _parentEmailCtrl.dispose();
    _parentPasswordCtrl.dispose();
    _learnerNameCtrl.dispose();
    _learnerSurnameCtrl.dispose();
    _learnerIdCtrl.dispose();
    super.dispose();
  }

  void _autofillFromApprovedApplication(AdmissionApplication app) {
    setState(() {
      _tokenCtrl.text = app.registrationToken;
      _parentNameCtrl.text = app.primaryParentName;
      _parentSurnameCtrl.text = app.primaryParentSurname;
      _parentEmailCtrl.text = app.primaryParentEmail;
      if (app.primaryParentPassword != null && app.primaryParentPassword!.isNotEmpty) {
        _parentPasswordCtrl.text = app.primaryParentPassword!;
      }
      _learnerNameCtrl.text = app.learnerName;
      _learnerSurnameCtrl.text = app.learnerSurname;
      _learnerIdCtrl.text = app.learnerIdNumber;
      _generalError = null;
    });
  }

  void _submitRegistration() {
    setState(() => _generalError = null);

    if (!_formKey.currentState!.validate()) {
      setState(() => _generalError = 'Please fix all highlighted errors.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final creds = widget.db.completeRegistration(
        registrationToken: _tokenCtrl.text.trim(),
        parentName: _parentNameCtrl.text.trim(),
        parentSurname: _parentSurnameCtrl.text.trim(),
        parentEmail: _parentEmailCtrl.text.trim(),
        parentPassword: _parentPasswordCtrl.text.trim(),
        learnerName: _learnerNameCtrl.text.trim(),
        learnerSurname: _learnerSurnameCtrl.text.trim(),
        learnerIdNumber: _learnerIdCtrl.text.trim(),
      );

      setState(() => _isLoading = false);

      // Show Success Dialog with Generated Learner Credentials
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Registration & Credentials Generated!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent account and Learner profile have been activated. An official confirmation email with these login details was sent to ${_parentEmailCtrl.text}.',
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B192C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: AppTheme.primaryGreen, size: 22),
                          const SizedBox(width: 8),
                          Text('Confidential Credential Delivery', style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 16),
                      Text(
                        'All official student login credentials, institutional emails, and access keys have been encrypted and sent directly to your registered parent email address.',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '📬 Please check your email inbox to view your credentials and sign in.',
                        style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Proceed to Parent Dashboard'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _generalError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvedApplications = widget.db.admissions.where((a) => a.status == ApplicationStatus.approved).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Registration', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppTheme.primaryGreen, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Activate Approved Enrollment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            'Enter your registration token from your approval email. The system will activate parent access and automatically generate the learner credentials.',
                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (approvedApplications.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.warningOrange),
                          const SizedBox(width: 6),
                          Text('Autofill from Approved Admission Queue:', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: approvedApplications.map((app) {
                          return ActionChip(
                            avatar: const Icon(Icons.touch_app_rounded, size: 14, color: AppTheme.primaryGreen),
                            label: Text('${app.learnerName} (${app.registrationToken})', style: GoogleFonts.outfit(fontSize: 11)),
                            onPressed: () => _autofillFromApprovedApplication(app),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_generalError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.dangerRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.dangerRed)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.dangerRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_generalError!, style: GoogleFonts.outfit(color: AppTheme.dangerRed, fontSize: 12, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              ValidatedTextField(
                controller: _tokenCtrl,
                label: 'Admission Registration Token',
                hint: 'e.g. REG-TT-88912',
                dataType: InputDataType.general,
                prefixIcon: Icons.key_rounded,
              ),

              const Divider(height: 28),

              Text('Parent Account Details', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              const SizedBox(height: 10),

              ValidatedTextField(
                controller: _parentNameCtrl,
                label: 'Parent Name(s)',
                hint: 'Letters only (e.g. Sibusiso)',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.person_outline,
              ),

              ValidatedTextField(
                controller: _parentSurnameCtrl,
                label: 'Parent Surname',
                hint: 'Letters only (e.g. Makola)',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.badge_outlined,
              ),

              ValidatedTextField(
                controller: _parentEmailCtrl,
                label: 'Parent Email (Username)',
                hint: 'parent@example.com',
                dataType: InputDataType.email,
                prefixIcon: Icons.email_outlined,
              ),

              ValidatedTextField(
                controller: _parentPasswordCtrl,
                label: 'Create Parent Password',
                hint: 'Min 8 characters (e.g. Pass@2026)',
                dataType: InputDataType.password,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),
              PasswordStrengthMeter(password: _parentPasswordCtrl.text),

              const Divider(height: 28),

              Text('Learner Profile Details', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
              Text('Requires only Learner ID number, First Name(s), and Surname:', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 10),

              ValidatedTextField(
                controller: _learnerIdCtrl,
                label: 'Learner National ID Number',
                hint: '13-digit National ID (Numbers only)',
                dataType: InputDataType.idNumber,
                maxLength: 13,
                prefixIcon: Icons.credit_card_rounded,
              ),

              ValidatedTextField(
                controller: _learnerNameCtrl,
                label: 'Learner First Name(s)',
                hint: 'Letters only (e.g. Thabo)',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.person_outline,
              ),

              ValidatedTextField(
                controller: _learnerSurnameCtrl,
                label: 'Learner Surname',
                hint: 'Letters only (e.g. Makola)',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.badge_outlined,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitRegistration,
                  icon: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.how_to_reg_rounded),
                  label: Text(_isLoading ? 'Activating...' : 'Register & Generate Credentials', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
