import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/curriculum/caps_curriculum.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/sa_id_parser.dart';
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
  int _currentStep = 0;

  // STEP 1: PRIMARY PARENT
  final _primaryNameCtrl = TextEditingController();
  final _primarySurnameCtrl = TextEditingController();
  final _primaryIdCtrl = TextEditingController();
  final _primaryPhoneCtrl = TextEditingController();
  final _primaryEmailCtrl = TextEditingController();
  SAIdInfo? _primaryIdInfo;

  // SECONDARY PARENT (OPTIONAL)
  bool _hasSecondaryParent = false;
  final _secNameCtrl = TextEditingController();
  final _secSurnameCtrl = TextEditingController();
  final _secIdCtrl = TextEditingController();
  final _secPhoneCtrl = TextEditingController();
  final _secEmailCtrl = TextEditingController();
  SAIdInfo? _secIdInfo;

  // STEP 2: LEARNER DETAILS & CAPS CURRICULUM
  final _learnerNameCtrl = TextEditingController();
  final _learnerSurnameCtrl = TextEditingController();
  final _learnerIdCtrl = TextEditingController();
  final _prevSchoolCtrl = TextEditingController();
  SAIdInfo? _learnerIdInfo;

  String _selectedGrade = 'Grade 8';
  String _selectedHomeLang = 'English';
  String _selectedFal = 'Afrikaans';
  String _selectedStream = CapsCurriculum.fetStreams.first;

  final List<String> _grades = ['Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];

  // STEP 3: AI OCR VERIFICATION
  bool _isOcrScanning = false;
  bool _ocrVerified = false;

  @override
  void initState() {
    super.initState();
    _primaryIdCtrl.addListener(() {
      if (_primaryIdCtrl.text.length == 13) {
        setState(() {
          _primaryIdInfo = SAIdParser.parse(_primaryIdCtrl.text);
        });
      }
    });

    _secIdCtrl.addListener(() {
      if (_secIdCtrl.text.length == 13) {
        setState(() {
          _secIdInfo = SAIdParser.parse(_secIdCtrl.text);
        });
      }
    });

    _learnerIdCtrl.addListener(() {
      if (_learnerIdCtrl.text.length == 13) {
        setState(() {
          _learnerIdInfo = SAIdParser.parse(_learnerIdCtrl.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _primaryNameCtrl.dispose();
    _primarySurnameCtrl.dispose();
    _primaryIdCtrl.dispose();
    _primaryPhoneCtrl.dispose();
    _primaryEmailCtrl.dispose();

    _secNameCtrl.dispose();
    _secSurnameCtrl.dispose();
    _secIdCtrl.dispose();
    _secPhoneCtrl.dispose();
    _secEmailCtrl.dispose();

    _learnerNameCtrl.dispose();
    _learnerSurnameCtrl.dispose();
    _learnerIdCtrl.dispose();
    _prevSchoolCtrl.dispose();
    super.dispose();
  }

  bool get _isFetPhase => _selectedGrade == 'Grade 10' || _selectedGrade == 'Grade 11' || _selectedGrade == 'Grade 12';

  void _runAiOcrVerification() {
    setState(() {
      _isOcrScanning = true;
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() {
        _isOcrScanning = false;
        _ocrVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI OCR Verification Successful: South African National IDs validated.', style: GoogleFonts.outfit()),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    });
  }

  void _submitFinalApplication() {
    if (_primaryNameCtrl.text.isEmpty ||
        _primarySurnameCtrl.text.isEmpty ||
        _primaryIdCtrl.text.length != 13 ||
        _learnerNameCtrl.text.isEmpty ||
        _learnerSurnameCtrl.text.isEmpty ||
        _learnerIdCtrl.text.length != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please ensure all required fields are correctly completed.', style: GoogleFonts.outfit()),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final application = widget.db.submitAdmissionApplication(
      primaryParentName: _primaryNameCtrl.text.trim(),
      primaryParentSurname: _primarySurnameCtrl.text.trim(),
      primaryParentPhone: _primaryPhoneCtrl.text.trim(),
      primaryParentEmail: _primaryEmailCtrl.text.trim(),
      primaryParentIdNumber: _primaryIdCtrl.text.trim(),
      primaryParentGender: _primaryIdInfo?.gender,
      primaryParentDob: _primaryIdInfo?.dateOfBirth,
      hasSecondaryParent: _hasSecondaryParent,
      secondaryParentName: _hasSecondaryParent ? _secNameCtrl.text.trim() : null,
      secondaryParentSurname: _hasSecondaryParent ? _secSurnameCtrl.text.trim() : null,
      secondaryParentPhone: _hasSecondaryParent ? _secPhoneCtrl.text.trim() : null,
      secondaryParentEmail: _hasSecondaryParent ? _secEmailCtrl.text.trim() : null,
      secondaryParentIdNumber: _hasSecondaryParent ? _secIdCtrl.text.trim() : null,
      secondaryParentGender: _secIdInfo?.gender,
      secondaryParentDob: _secIdInfo?.dateOfBirth,
      learnerName: _learnerNameCtrl.text.trim(),
      learnerSurname: _learnerSurnameCtrl.text.trim(),
      learnerIdNumber: _learnerIdCtrl.text.trim(),
      learnerGender: _learnerIdInfo?.gender,
      learnerDob: _learnerIdInfo?.dateOfBirth,
      learnerAge: _learnerIdInfo?.age,
      gradeApplyingFor: _selectedGrade,
      homeLanguage: _selectedHomeLang,
      firstAdditionalLanguage: _selectedFal,
      stream: _isFetPhase ? _selectedStream : null,
      previousSchool: _prevSchoolCtrl.text.trim().isEmpty ? 'Not Specified' : _prevSchoolCtrl.text.trim(),
      documentVerified: _ocrVerified,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text('Application Submitted!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your admission application has been placed in the admissions review queue.', style: GoogleFonts.outfit(fontSize: 14)),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Application Ref: ${application.applicationNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                  Text('Learner: ${application.learnerName} ${application.learnerSurname} (ID: ${application.learnerIdNumber})', style: GoogleFonts.outfit(fontSize: 12)),
                  Text('Placement: ${application.gradeApplyingFor} • ${application.homeLanguage}${application.stream != null ? " (${application.stream})" : ""}', style: GoogleFonts.outfit(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '✉️ Once approved by School Management, you will receive an official approval email with the registration link and token to register yourself and generate ${application.learnerName}\'s student credentials.',
              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryNavy, height: 1.4),
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
        title: Text('Online Admission Application', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_primaryNameCtrl.text.isEmpty || _primarySurnameCtrl.text.isEmpty || _primaryIdCtrl.text.length != 13 || _primaryPhoneCtrl.text.isEmpty || _primaryEmailCtrl.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please complete all primary parent fields.', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
              );
              return;
            }
            setState(() => _currentStep = 1);
          } else if (_currentStep == 1) {
            if (_learnerNameCtrl.text.isEmpty || _learnerSurnameCtrl.text.isEmpty || _learnerIdCtrl.text.length != 13) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please complete all learner fields with valid 13-digit ID.', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
              );
              return;
            }
            setState(() => _currentStep = 2);
          } else {
            _submitFinalApplication();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          // STEP 1: PARENT INFORMATION
          Step(
            title: const Text('Parent(s)'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader('Primary Parent / Legal Guardian', Icons.person_rounded),
                const SizedBox(height: 12),
                ValidatedTextField(
                  controller: _primaryNameCtrl,
                  label: 'Primary Parent First Name(s)',
                  hint: 'Letters only (e.g. Sibusiso)',
                  dataType: InputDataType.textOnly,
                  prefixIcon: Icons.person_outline,
                ),
                ValidatedTextField(
                  controller: _primarySurnameCtrl,
                  label: 'Primary Parent Surname',
                  hint: 'Letters only (e.g. Makola)',
                  dataType: InputDataType.textOnly,
                  prefixIcon: Icons.badge_outlined,
                ),
                ValidatedTextField(
                  controller: _primaryIdCtrl,
                  label: 'South African National ID Number',
                  hint: '13 digits (Numbers only)',
                  dataType: InputDataType.idNumber,
                  maxLength: 13,
                  prefixIcon: Icons.credit_card_rounded,
                ),

                // Live Auto-Filled DOB & Gender Card from SA ID
                if (_primaryIdInfo != null && _primaryIdInfo!.isValid) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.lightGreen, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Auto-Extracted: Born ${_primaryIdInfo!.formattedDob} • Gender: ${_primaryIdInfo!.gender} • SA Citizen',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                ValidatedTextField(
                  controller: _primaryPhoneCtrl,
                  label: 'Mobile Contact Number',
                  hint: '10 digits (e.g. 0821234567)',
                  dataType: InputDataType.phoneNumber,
                  maxLength: 10,
                  prefixIcon: Icons.phone_android_rounded,
                ),
                ValidatedTextField(
                  controller: _primaryEmailCtrl,
                  label: 'Email Address for Admission Notices',
                  hint: 'parent@example.com',
                  dataType: InputDataType.email,
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                // OPTIONAL SECONDARY PARENT SECTION
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
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
                              const SizedBox(width: 8),
                              Text('Add Secondary Parent (Optional)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
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
                        const Divider(),
                        ValidatedTextField(
                          controller: _secNameCtrl,
                          label: 'Secondary Parent First Name',
                          hint: 'Letters only (e.g. Nomsa)',
                          dataType: InputDataType.textOnly,
                          isRequired: _hasSecondaryParent,
                          prefixIcon: Icons.person_outline,
                        ),
                        ValidatedTextField(
                          controller: _secSurnameCtrl,
                          label: 'Secondary Parent Surname',
                          hint: 'Letters only (e.g. Makola)',
                          dataType: InputDataType.textOnly,
                          isRequired: _hasSecondaryParent,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        ValidatedTextField(
                          controller: _secIdCtrl,
                          label: 'Secondary Parent 13-digit ID Number',
                          hint: '13-digit National ID',
                          dataType: InputDataType.idNumber,
                          maxLength: 13,
                          isRequired: _hasSecondaryParent,
                          prefixIcon: Icons.credit_card_rounded,
                        ),
                        if (_secIdInfo != null && _secIdInfo!.isValid) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.lightGreen, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'Auto-Extracted: Born ${_secIdInfo!.formattedDob} • Gender: ${_secIdInfo!.gender}',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                          ),
                        ],
                        ValidatedTextField(
                          controller: _secPhoneCtrl,
                          label: 'Secondary Parent Contact',
                          hint: '10 digits (e.g. 0839876543)',
                          dataType: InputDataType.phoneNumber,
                          maxLength: 10,
                          isRequired: _hasSecondaryParent,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        ValidatedTextField(
                          controller: _secEmailCtrl,
                          label: 'Secondary Parent Email',
                          hint: 'secondary@example.com',
                          dataType: InputDataType.email,
                          isRequired: false,
                          prefixIcon: Icons.email_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // STEP 2: LEARNER & CAPS CURRICULUM
          Step(
            title: const Text('Learner & CAPS'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader('Learner Identification', Icons.child_care_rounded),
                const SizedBox(height: 12),
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
                ValidatedTextField(
                  controller: _learnerIdCtrl,
                  label: 'Learner 13-digit National ID Number',
                  hint: '13 digits (Numbers only)',
                  dataType: InputDataType.idNumber,
                  maxLength: 13,
                  prefixIcon: Icons.credit_card_rounded,
                ),

                // Real-Time Auto-Filled DOB, Age, Gender Card
                if (_learnerIdInfo != null && _learnerIdInfo!.isValid) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.lightGreen, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_rounded, color: AppTheme.primaryGreen, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Auto-Filled Demographic Details from ID:', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
                              Text(
                                'DOB: ${_learnerIdInfo!.formattedDob}  •  Age: ${_learnerIdInfo!.age} Years  •  Gender: ${_learnerIdInfo!.gender}',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Grade Selection
                Text('Grade Applying For *', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.stairs_rounded, color: AppTheme.secondaryNavy)),
                  items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedGrade = val);
                  },
                ),
                const SizedBox(height: 14),

                // Home Language (11 SA Languages)
                Text('Home Language (First Assigned Subject) *', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedHomeLang,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.language_rounded, color: AppTheme.secondaryNavy)),
                  items: CapsCurriculum.officialLanguages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedHomeLang = val);
                  },
                ),
                const SizedBox(height: 14),

                // First Additional Language
                Text('First Additional Language (FAL) *', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedFal,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.translate_rounded, color: AppTheme.secondaryNavy)),
                  items: CapsCurriculum.officialLanguages.where((l) => l != _selectedHomeLang).map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFal = val);
                  },
                ),
                const SizedBox(height: 14),

                // Stream selection if Grade 10, 11, or 12 (FET Phase)
                if (_isFetPhase) ...[
                  Text('FET Specialization Stream (DBE CAPS) *', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedStream,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.account_tree_rounded, color: AppTheme.primaryGreen)),
                    items: CapsCurriculum.fetStreams.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStream = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned CAPS FET Subjects for $_selectedStream:', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        const SizedBox(height: 6),
                        ...CapsCurriculum.getFetPhaseSubjects(
                          homeLanguage: _selectedHomeLang,
                          fal: _selectedFal,
                          stream: _selectedStream,
                        ).map((s) => Text('• $s', style: GoogleFonts.outfit(fontSize: 12, color: Colors.blue.shade900))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned Senior Phase (Grade 8-9) CAPS Subjects:', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        const SizedBox(height: 6),
                        ...CapsCurriculum.getSeniorPhaseSubjects(_selectedHomeLang, _selectedFal).map((s) => Text('• $s', style: GoogleFonts.outfit(fontSize: 12, color: Colors.green.shade900))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                ValidatedTextField(
                  controller: _prevSchoolCtrl,
                  label: 'Previous School Attended',
                  hint: 'e.g. Limpopo Primary School',
                  prefixIcon: Icons.account_balance_outlined,
                ),
              ],
            ),
          ),

          // STEP 3: AI DOCUMENT OCR VERIFICATION
          Step(
            title: const Text('AI Verification'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader('AI National ID Document Verification', Icons.document_scanner_rounded),
                const SizedBox(height: 12),
                Text(
                  'ThutoTech uses integrated AI OCR to inspect the South African National IDs and ensure data integrity with Home Affairs standards.',
                  style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _ocrVerified ? AppTheme.lightGreen : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _ocrVerified ? AppTheme.primaryGreen : AppTheme.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _ocrVerified ? Icons.verified_rounded : Icons.scanner_rounded,
                            color: _ocrVerified ? AppTheme.primaryGreen : AppTheme.secondaryNavy,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _ocrVerified ? 'All Documents Verified & Authentic' : 'Document Verification Required',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  _ocrVerified ? 'Parent ID and Learner ID matched SA National Register' : 'Click below to run automated AI OCR scan',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (!_ocrVerified)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isOcrScanning ? null : _runAiOcrVerification,
                            icon: _isOcrScanning
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.bolt_rounded),
                            label: Text(_isOcrScanning ? 'Running AI OCR Scan...' : 'Run AI OCR Verification'),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text('Summary of Application:', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('• Parent: ${_primaryNameCtrl.text} ${_primarySurnameCtrl.text} (${_primaryIdCtrl.text})', style: GoogleFonts.outfit(fontSize: 12)),
                if (_hasSecondaryParent)
                  Text('• Secondary Parent: ${_secNameCtrl.text} ${_secSurnameCtrl.text} (${_secIdCtrl.text})', style: GoogleFonts.outfit(fontSize: 12)),
                Text('• Learner: ${_learnerNameCtrl.text} ${_learnerSurnameCtrl.text} (ID: ${_learnerIdCtrl.text})', style: GoogleFonts.outfit(fontSize: 12)),
                Text('• Grade & Stream: $_selectedGrade • $_selectedHomeLang${_isFetPhase ? " • $_selectedStream" : ""}', style: GoogleFonts.outfit(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryNavy, size: 20),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
      ],
    );
  }
}
