import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation/input_validators.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';

class AdmissionApplicationScreen extends StatefulWidget {
  final MockDatabase db;

  const AdmissionApplicationScreen({super.key, required this.db});

  @override
  State<AdmissionApplicationScreen> createState() => _AdmissionApplicationScreenState();
}

class _AdmissionApplicationScreenState extends State<AdmissionApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Primary Parent Controllers
  final _parentNameController = TextEditingController();
  final _parentSurnameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentIdController = TextEditingController();

  // Secondary Parent
  bool _hasSecondaryParent = false;
  final _secParentNameController = TextEditingController();
  final _secParentSurnameController = TextEditingController();
  final _secParentPhoneController = TextEditingController();
  final _secParentEmailController = TextEditingController();

  // Learner Controllers
  final _learnerNameController = TextEditingController();
  final _learnerSurnameController = TextEditingController();
  final _learnerIdController = TextEditingController();
  final _previousSchoolController = TextEditingController();
  String _selectedGrade = 'Grade 8';

  final List<String> _grades = ['Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];

  @override
  void dispose() {
    _parentNameController.dispose();
    _parentSurnameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _parentIdController.dispose();

    _secParentNameController.dispose();
    _secParentSurnameController.dispose();
    _secParentPhoneController.dispose();
    _secParentEmailController.dispose();

    _learnerNameController.dispose();
    _learnerSurnameController.dispose();
    _learnerIdController.dispose();
    _previousSchoolController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please resolve the highlighted validation errors on the screen.',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final application = widget.db.submitAdmissionApplication(
      primaryParentName: _parentNameController.text.trim(),
      primaryParentSurname: _parentSurnameController.text.trim(),
      primaryParentPhone: _parentPhoneController.text.trim(),
      primaryParentEmail: _parentEmailController.text.trim(),
      primaryParentIdNumber: _parentIdController.text.trim(),
      hasSecondaryParent: _hasSecondaryParent,
      secondaryParentName: _hasSecondaryParent ? _secParentNameController.text.trim() : null,
      secondaryParentSurname: _hasSecondaryParent ? _secParentSurnameController.text.trim() : null,
      secondaryParentPhone: _hasSecondaryParent ? _secParentPhoneController.text.trim() : null,
      secondaryParentEmail: _hasSecondaryParent ? _secParentEmailController.text.trim() : null,
      learnerName: _learnerNameController.text.trim(),
      learnerSurname: _learnerSurnameController.text.trim(),
      learnerIdNumber: _learnerIdController.text.trim(),
      gradeApplyingFor: _selectedGrade,
      previousSchool: _previousSchoolController.text.trim(),
    );

    // Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Application Submitted!',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your application has been received and is currently under review by School Admissions.',
              style: GoogleFonts.outfit(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Application Reference:', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                  Text(
                    application.applicationNumber,
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                  ),
                  const SizedBox(height: 8),
                  Text('Learner: ${application.learnerName} ${application.learnerSurname}', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Grade: ${application.gradeApplyingFor}', style: GoogleFonts.outfit(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.secondaryNavy),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Once approved, you will receive an official admission email with your Registration Token.',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryNavy, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Online Admission Application',
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
              // Header Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryNavy, AppTheme.secondaryNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school_rounded, color: AppTheme.primaryGreen, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ThutoTech Academy Admissions',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete all required fields below. Strict field validation is enforced.',
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 1: PRIMARY PARENT / APPLICANT
              _buildSectionTitle(
                icon: Icons.person_rounded,
                title: '1. Primary Parent / Guardian Information',
                subtitle: 'Applicant contact and legal identification',
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: _parentNameController,
                label: 'Primary Parent First Name(s)',
                hint: 'e.g. Sibusiso',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.person_outline,
              ),

              ValidatedTextField(
                controller: _parentSurnameController,
                label: 'Primary Parent Surname',
                hint: 'e.g. Makola',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.badge_outlined,
              ),

              ValidatedTextField(
                controller: _parentIdController,
                label: 'Primary Parent National ID Number',
                hint: '13-digit South African ID number',
                dataType: InputDataType.idNumber,
                maxLength: 13,
                prefixIcon: Icons.credit_card_rounded,
              ),

              ValidatedTextField(
                controller: _parentPhoneController,
                label: 'Mobile Contact Number',
                hint: '10 digits (e.g. 0821234567)',
                dataType: InputDataType.phoneNumber,
                maxLength: 10,
                prefixIcon: Icons.phone_android_rounded,
              ),

              ValidatedTextField(
                controller: _parentEmailController,
                label: 'Email Address for Admission Notices',
                hint: 'parent@example.com',
                dataType: InputDataType.email,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              // SECTION 2: OPTIONAL SECONDARY PARENT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.group_add_rounded, color: AppTheme.secondaryNavy),
                            const SizedBox(width: 10),
                            Text(
                              'Secondary Parent / Guardian (Optional)',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: _hasSecondaryParent,
                          activeColor: AppTheme.primaryGreen,
                          onChanged: (val) => setState(() => _hasSecondaryParent = val),
                        ),
                      ],
                    ),
                    if (_hasSecondaryParent) ...[
                      const Divider(height: 24),
                      Text(
                        'Provide secondary emergency/guardian contact details:',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 12),
                      ValidatedTextField(
                        controller: _secParentNameController,
                        label: 'Secondary Parent First Name',
                        hint: 'e.g. Nomsa',
                        dataType: InputDataType.textOnly,
                        isRequired: _hasSecondaryParent,
                        prefixIcon: Icons.person_outline,
                      ),
                      ValidatedTextField(
                        controller: _secParentSurnameController,
                        label: 'Secondary Parent Surname',
                        hint: 'e.g. Makola',
                        dataType: InputDataType.textOnly,
                        isRequired: _hasSecondaryParent,
                        prefixIcon: Icons.badge_outlined,
                      ),
                      ValidatedTextField(
                        controller: _secParentPhoneController,
                        label: 'Secondary Parent Contact Number',
                        hint: '10 digits (e.g. 0839876543)',
                        dataType: InputDataType.phoneNumber,
                        maxLength: 10,
                        isRequired: _hasSecondaryParent,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      ValidatedTextField(
                        controller: _secParentEmailController,
                        label: 'Secondary Parent Email',
                        hint: 'secondary.parent@example.com',
                        dataType: InputDataType.email,
                        isRequired: false,
                        prefixIcon: Icons.email_outlined,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 3: LEARNER INFORMATION
              _buildSectionTitle(
                icon: Icons.child_care_rounded,
                title: '2. Child / Learner Information',
                subtitle: 'Prospective learner details for academic placement',
              ),
              const SizedBox(height: 12),

              ValidatedTextField(
                controller: _learnerNameController,
                label: 'Learner First Name(s)',
                hint: 'e.g. Thabo',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.person_outline,
              ),

              ValidatedTextField(
                controller: _learnerSurnameController,
                label: 'Learner Surname',
                hint: 'e.g. Makola',
                dataType: InputDataType.textOnly,
                prefixIcon: Icons.badge_outlined,
              ),

              ValidatedTextField(
                controller: _learnerIdController,
                label: 'Learner National ID Number',
                hint: '13-digit National ID number',
                dataType: InputDataType.idNumber,
                maxLength: 13,
                prefixIcon: Icons.credit_card_rounded,
              ),

              // Grade Selection Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grade Applying For *',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.stairs_rounded, color: AppTheme.secondaryNavy, size: 20),
                    ),
                    items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedGrade = val);
                    },
                  ),
                  const SizedBox(height: 14),
                ],
              ),

              ValidatedTextField(
                controller: _previousSchoolController,
                label: 'Previous School Name',
                hint: 'e.g. Limpopo Primary School',
                dataType: InputDataType.general,
                prefixIcon: Icons.account_balance_outlined,
              ),

              const SizedBox(height: 20),

              // Submit Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitApplication,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    'Submit Admission Application',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryNavy, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ],
    );
  }
}
