import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation/input_validators.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';

class RegistrationScreen extends StatefulWidget {
  final MockDatabase db;

  const RegistrationScreen({super.key, required this.db});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tokenController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentSurnameController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _learnerNameController = TextEditingController();
  final _learnerSurnameController = TextEditingController();
  final _learnerIdController = TextEditingController();

  bool _isLoading = false;
  String? _generalError;

  @override
  void dispose() {
    _tokenController.dispose();
    _parentNameController.dispose();
    _parentSurnameController.dispose();
    _parentEmailController.dispose();
    _passwordController.dispose();
    _learnerNameController.dispose();
    _learnerSurnameController.dispose();
    _learnerIdController.dispose();
    super.dispose();
  }

  void _autofillFromApprovedApplication(AdmissionApplication app) {
    setState(() {
      _tokenController.text = app.registrationToken;
      _parentNameController.text = app.primaryParentName;
      _parentSurnameController.text = app.primaryParentSurname;
      _parentEmailController.text = app.primaryParentEmail;
      _learnerNameController.text = app.learnerName;
      _learnerSurnameController.text = app.learnerSurname;
      _learnerIdController.text = app.learnerIdNumber;
      _generalError = null;
    });
  }

  void _submitRegistration() {
    setState(() => _generalError = null);

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _generalError = 'Please fix all field validation errors highlighted in red below.';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = widget.db.completeRegistration(
        registrationToken: _tokenController.text.trim(),
        parentName: _parentNameController.text.trim(),
        parentSurname: _parentSurnameController.text.trim(),
        parentEmail: _parentEmailController.text.trim(),
        parentPassword: _passwordController.text.trim(),
        learnerName: _learnerNameController.text.trim(),
        learnerSurname: _learnerSurnameController.text.trim(),
        learnerIdNumber: _learnerIdController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 28),
                const SizedBox(width: 10),
                Text('Registration Successful!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'Your parent and learner accounts have been activated. You are now logged into the ThutoTech Parent Portal.',
              style: GoogleFonts.outfit(fontSize: 14),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Go to Parent Dashboard'),
              ),
            ],
          ),
        );
      }
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
        title: Text(
          'Complete School Registration',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppTheme.primaryGreen, size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Enrollment Activation',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Enter your Admission Registration Token sent to your email to create your official credentials.',
                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Fast Demo Autofill if approved applications exist
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
                          Text(
                            'Quick Demo Token Autofill (From Approved Applications):',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
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
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.dangerRed),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_rounded, color: AppTheme.dangerRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _generalError!,
                          style: GoogleFonts.outfit(color: AppTheme.dangerRed, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // TOKEN FIELD
              ValidatedTextField(
                controller: _tokenController,
                label: 'Admission Registration Token',
                hint: 'e.g. REG-TT-88912',
                dataType: InputDataType.general,
                prefixIcon: Icons.key_rounded,
              ),

              const Divider(height: 32),

              // PARENT REGISTRATION SECTION
              Text(
                'Parent Account Details',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: _parentNameController,
                label: 'Parent Name(s)',
                hint: 'Letters only (e.g. Sibusiso)',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.person_outline,
              ),

              ValidatedTextField(
                controller: _parentSurnameController,
                label: 'Parent Surname',
                hint: 'Letters only (e.g. Makola)',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.badge_outlined,
              ),

              ValidatedTextField(
                controller: _parentEmailController,
                label: 'Parent Email (Login Username)',
                hint: 'parent@example.com',
                dataType: InputDataType.email,
                prefixIcon: Icons.email_outlined,
              ),

              ValidatedTextField(
                controller: _passwordController,
                label: 'Create Secure Password',
                hint: 'Minimum 6 characters',
                dataType: InputDataType.password,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
              ),

              const Divider(height: 32),

              // LEARNER REGISTRATION SECTION
              Text(
                'Learner Profile Details',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
              ),
              Text(
                'Requires only Learner ID Number, First Name(s), and Surname:',
                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: _learnerIdController,
                label: 'Learner National ID Number',
                hint: '13-digit National ID (Numbers only)',
                dataType: InputDataType.idNumber,
                maxLength: 13,
                prefixIcon: Icons.credit_card_rounded,
              ),

              ValidatedTextField(
                controller: _learnerNameController,
                label: 'Learner First Name(s)',
                hint: 'Letters only (e.g. Thabo)',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.person_outline,
              ),

              ValidatedTextField(
                controller: _learnerSurnameController,
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
                      : const Icon(Icons.how_to_reg_rounded, size: 20),
                  label: Text(
                    _isLoading ? 'Activating Accounts...' : 'Complete Registration & Log In',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
