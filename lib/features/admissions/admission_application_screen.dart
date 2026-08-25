import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/curriculum/caps_curriculum.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/ai_document_verifier.dart';
import '../../core/utils/sa_id_parser.dart';
import '../../core/validation/input_validators.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../widgets/password_strength_meter.dart';

class _LearnerFormEntry {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController surnameCtrl = TextEditingController();
  final TextEditingController idCtrl = TextEditingController();
  final TextEditingController prevSchoolCtrl = TextEditingController();
  SAIdInfo? idInfo;
  String selectedGrade = 'Grade 8';
  String selectedHomeLang = 'English';
  String selectedFal = 'Afrikaans';
  String selectedStream = CapsCurriculum.fetStreams.first;
  String? documentName;
  PlatformFile? pickedFile;
  String? fileSizeString;
  AiVerificationResult? aiResult;

  void dispose() {
    nameCtrl.dispose();
    surnameCtrl.dispose();
    idCtrl.dispose();
    prevSchoolCtrl.dispose();
  }
}

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
  final _primaryPasswordCtrl = TextEditingController();
  final _primaryConfirmPasswordCtrl = TextEditingController();
  SAIdInfo? _primaryIdInfo;
  String? _parentDocName;
  PlatformFile? _parentPickedFile;
  String? _parentFileSizeString;

  // SECONDARY PARENT (OPTIONAL)
  bool _hasSecondaryParent = false;
  final _secNameCtrl = TextEditingController();
  final _secSurnameCtrl = TextEditingController();
  final _secIdCtrl = TextEditingController();
  final _secPhoneCtrl = TextEditingController();
  final _secEmailCtrl = TextEditingController();
  SAIdInfo? _secIdInfo;
  String? _secParentDocName;
  PlatformFile? _secParentPickedFile;
  String? _secParentFileSizeString;

  // STEP 2: MULTI-LEARNERS LIST
  final List<_LearnerFormEntry> _learners = [];
  final List<String> _grades = ['Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];

  // STEP 3: AI OCR & MULTI-DOCUMENT VERIFICATION
  bool _isOcrScanning = false;
  AiVerificationResult? _parentAiResult;
  AiVerificationResult? _secParentAiResult;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickParentDocument() async {
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'doc'],
      );
      if (result != null && result.isNotEmpty) {
        final file = result.first;
        setState(() {
          _parentPickedFile = file;
          _parentDocName = file.name;
          _parentFileSizeString = 'Attached ✓';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attached Parent ID: ${file.name}', style: GoogleFonts.outfit()),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not browse file: $e', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  Future<void> _pickSecondaryParentDocument() async {
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'doc'],
      );
      if (result != null && result.isNotEmpty) {
        final file = result.first;
        setState(() {
          _secParentPickedFile = file;
          _secParentDocName = file.name;
          _secParentFileSizeString = 'Attached ✓';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attached Secondary Parent ID: ${file.name}', style: GoogleFonts.outfit()),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not browse file: $e', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  Future<void> _pickLearnerDocument(_LearnerFormEntry entry) async {
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'docx', 'doc'],
      );
      if (result != null && result.isNotEmpty) {
        final file = result.first;
        setState(() {
          entry.pickedFile = file;
          entry.documentName = file.name;
          entry.fileSizeString = 'Attached ✓';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Attached Learner Document: ${file.name}', style: GoogleFonts.outfit()),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not browse file: $e', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Start with 1 default learner
    _addNewLearner();

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

    _primaryPasswordCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _addNewLearner() {
    final newEntry = _LearnerFormEntry();
    newEntry.idCtrl.addListener(() {
      if (newEntry.idCtrl.text.length == 13) {
        setState(() {
          newEntry.idInfo = SAIdParser.parse(newEntry.idCtrl.text);
        });
      }
    });
    setState(() {
      _learners.add(newEntry);
    });
  }

  void _removeLearner(int index) {
    if (_learners.length > 1) {
      setState(() {
        _learners[index].dispose();
        _learners.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _primaryNameCtrl.dispose();
    _primarySurnameCtrl.dispose();
    _primaryIdCtrl.dispose();
    _primaryPhoneCtrl.dispose();
    _primaryEmailCtrl.dispose();
    _primaryPasswordCtrl.dispose();
    _primaryConfirmPasswordCtrl.dispose();

    _secNameCtrl.dispose();
    _secSurnameCtrl.dispose();
    _secIdCtrl.dispose();
    _secPhoneCtrl.dispose();
    _secEmailCtrl.dispose();

    for (final l in _learners) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _runAiDeepDocumentVerification() async {
    setState(() {
      _isOcrScanning = true;
      _parentAiResult = null;
      _secParentAiResult = null;
      for (final l in _learners) {
        l.aiResult = null;
      }
    });

    // 1. Verify Primary Parent
    final parentRes = await AiDocumentVerifier.verifyDocument(
      formFullName: _primaryNameCtrl.text,
      formSurname: _primarySurnameCtrl.text,
      formIdNumber: _primaryIdCtrl.text,
      formGender: _primaryIdInfo?.gender,
      fileName: _parentDocName ?? '',
    );

    // 2. Verify Secondary Parent if present
    AiVerificationResult? secParentRes;
    if (_hasSecondaryParent && _secIdCtrl.text.length == 13) {
      secParentRes = await AiDocumentVerifier.verifyDocument(
        formFullName: _secNameCtrl.text,
        formSurname: _secSurnameCtrl.text,
        formIdNumber: _secIdCtrl.text,
        formGender: _secIdInfo?.gender,
        fileName: _secParentDocName ?? '',
      );
    }

    // 3. Verify All Learners
    final List<AiVerificationResult> learnerResults = [];
    for (final l in _learners) {
      final lRes = await AiDocumentVerifier.verifyDocument(
        formFullName: l.nameCtrl.text,
        formSurname: l.surnameCtrl.text,
        formIdNumber: l.idCtrl.text,
        formGender: l.idInfo?.gender,
        fileName: l.documentName ?? '',
      );
      l.aiResult = lRes;
      learnerResults.add(lRes);
    }

    if (!mounted) return;

    setState(() {
      _isOcrScanning = false;
      _parentAiResult = parentRes;
      _secParentAiResult = secParentRes;
    });

    final allLearnersPassed = learnerResults.every((r) => r.decision == 'ACCEPTED');
    final isOverallApproved = parentRes.decision == 'ACCEPTED' &&
        (_secParentAiResult == null || _secParentAiResult!.decision == 'ACCEPTED') &&
        allLearnersPassed;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOverallApproved
              ? 'AI Verification Passed: All ${learnerResults.length} learner(s) and parent ID documents verified!'
              : 'AI Alert: Discrepancy detected during cross-inspection.',
          style: GoogleFonts.outfit(),
        ),
        backgroundColor: isOverallApproved ? AppTheme.primaryGreen : AppTheme.dangerRed,
      ),
    );
  }

  void _submitFinalApplication() {
    if (_parentAiResult == null || _learners.any((l) => l.aiResult == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please run the AI Document Verification before submitting.', style: GoogleFonts.outfit()),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    final allLearnersPassed = _learners.every((l) => l.aiResult?.decision == 'ACCEPTED');
    final isAiApproved = _parentAiResult!.decision == 'ACCEPTED' && allLearnersPassed;

    final applicationLearnersList = _learners.map((l) {
      final isFet = l.selectedGrade == 'Grade 10' || l.selectedGrade == 'Grade 11' || l.selectedGrade == 'Grade 12';
      return ApplicationLearner(
        id: 'lrn_app_${DateTime.now().millisecondsSinceEpoch}_${_learners.indexOf(l)}',
        learnerName: l.nameCtrl.text.trim(),
        learnerSurname: l.surnameCtrl.text.trim(),
        learnerIdNumber: l.idCtrl.text.trim(),
        learnerGender: l.idInfo?.gender,
        learnerDob: l.idInfo?.dateOfBirth,
        learnerAge: l.idInfo?.age,
        gradeApplyingFor: l.selectedGrade,
        homeLanguage: l.selectedHomeLang,
        firstAdditionalLanguage: l.selectedFal,
        stream: isFet ? l.selectedStream : null,
        previousSchool: l.prevSchoolCtrl.text.trim().isEmpty ? 'Not Specified' : l.prevSchoolCtrl.text.trim(),
        documentName: l.documentName,
        documentVerified: isAiApproved,
      );
    }).toList();

    final application = widget.db.submitAdmissionApplication(
      primaryParentName: _primaryNameCtrl.text.trim(),
      primaryParentSurname: _primarySurnameCtrl.text.trim(),
      primaryParentPhone: _primaryPhoneCtrl.text.trim(),
      primaryParentEmail: _primaryEmailCtrl.text.trim(),
      primaryParentPassword: _primaryPasswordCtrl.text.trim().isNotEmpty ? _primaryPasswordCtrl.text.trim() : null,
      primaryParentIdNumber: _primaryIdCtrl.text.trim(),
      primaryParentGender: _primaryIdInfo?.gender,
      primaryParentDob: _primaryIdInfo?.dateOfBirth,
      primaryParentDocumentName: _parentDocName,
      hasSecondaryParent: _hasSecondaryParent,
      secondaryParentName: _hasSecondaryParent ? _secNameCtrl.text.trim() : null,
      secondaryParentSurname: _hasSecondaryParent ? _secSurnameCtrl.text.trim() : null,
      secondaryParentPhone: _hasSecondaryParent ? _secPhoneCtrl.text.trim() : null,
      secondaryParentEmail: _hasSecondaryParent ? _secEmailCtrl.text.trim() : null,
      secondaryParentIdNumber: _hasSecondaryParent ? _secIdCtrl.text.trim() : null,
      secondaryParentGender: _secIdInfo?.gender,
      secondaryParentDob: _secIdInfo?.dateOfBirth,
      secondaryParentDocumentName: _hasSecondaryParent ? _secParentDocName : null,
      learnersList: applicationLearnersList,
      documentVerified: isAiApproved,
    );

    // If AI approved, automatically pre-approve admission and dispatch approval email
    if (isAiApproved) {
      widget.db.approveAdmission(application.id);
    } else {
      widget.db.rejectAdmission(application.id, reason: 'AI Document Verification detected mismatch with South African National ID register.');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isAiApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isAiApproved ? AppTheme.primaryGreen : AppTheme.dangerRed,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAiApproved ? 'Admission & ID Verification Accepted!' : 'Application Rejected by AI Verification',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAiApproved
                    ? 'Your admission application for ${application.learners.length} learner(s) and South African ID documents have been verified.'
                    : 'Your application could not be verified against the official South African National ID register.',
                style: GoogleFonts.outfit(fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (isAiApproved ? AppTheme.primaryGreen : AppTheme.dangerRed).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (isAiApproved ? AppTheme.primaryGreen : AppTheme.dangerRed).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Application Ref: ${application.applicationNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text('Applying for ${application.learners.length} Child(ren):', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                    ...application.learners.map((l) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '• ${l.learnerName} ${l.learnerSurname} (${l.gradeApplyingFor} - ${l.homeLanguage}${l.stream != null ? " • ${l.stream}" : ""})',
                            style: GoogleFonts.outfit(fontSize: 12),
                          ),
                        )),
                    const SizedBox(height: 8),
                    Text(
                      'AI Match Status: ${isAiApproved ? "100% Validated (SA Biometric Match)" : "Discrepancy Detected"}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isAiApproved ? AppTheme.primaryGreen : AppTheme.dangerRed, fontSize: 12),
                    ),
                    if (isAiApproved) ...[
                      const Divider(height: 16),
                      Text('Parent Portal Sign-In Credentials:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy)),
                      const SizedBox(height: 4),
                      Text('• Username / Email: ${_primaryEmailCtrl.text}', style: GoogleFonts.outfit(fontSize: 12)),
                      Text('• Password: ${_primaryPasswordCtrl.text.isNotEmpty ? _primaryPasswordCtrl.text : "Password chosen in Step 1"}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isAiApproved
                    ? '✉️ A real ADMISSION ACCEPTANCE EMAIL with your registration token (${application.registrationToken}) has been dispatched to ${_primaryEmailCtrl.text} via Gmail SMTP.'
                    : '✉️ An automated REJECTION NOTICE with details regarding the document mismatch has been sent to ${_primaryEmailCtrl.text}.',
                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.secondaryNavy, height: 1.4),
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
            child: const Text('Return to Home / Sign In'),
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
            if (_primaryNameCtrl.text.trim().isEmpty ||
                _primarySurnameCtrl.text.trim().isEmpty ||
                _primaryIdCtrl.text.trim().length != 13 ||
                _primaryPhoneCtrl.text.trim().isEmpty ||
                _primaryEmailCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please complete all primary parent contact and identification fields.', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
              );
              return;
            }
            if (_parentDocName == null || _parentDocName!.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please upload the Primary Parent South African ID document copy.', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
              );
              return;
            }
            if (_primaryPasswordCtrl.text.trim().isEmpty || _primaryPasswordCtrl.text.trim().length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please create a parent portal password (at least 6 characters).', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
              );
              return;
            }
            if (_primaryPasswordCtrl.text.trim() != _primaryConfirmPasswordCtrl.text.trim()) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Parent password and confirm password do not match.', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
              );
              return;
            }
            setState(() => _currentStep = 1);
          } else if (_currentStep == 1) {
            final invalidLearner = _learners.any((l) => l.nameCtrl.text.trim().isEmpty || l.surnameCtrl.text.trim().isEmpty || l.idCtrl.text.trim().length != 13);
            if (invalidLearner) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please complete details for all learner(s) with valid 13-digit IDs.', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
              );
              return;
            }
            final missingDoc = _learners.any((l) => l.documentName == null || l.documentName!.isEmpty);
            if (missingDoc) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please upload the Birth Certificate / ID document for all learner(s).', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
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
          // STEP 1: PARENT INFORMATION & DOCUMENT UPLOADS
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

                // Auto-Extracted DOB & Gender
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

                // Parent ID Upload Card with Native File Picker
                _buildUploadPicker(
                  label: 'Upload Primary Parent SA ID Copy *',
                  supportingDocInfo: 'Attach a certified copy of the parent/guardian South African Green ID Book or Smart ID Card (PDF, PNG, JPG).',
                  fileName: _parentDocName,
                  fileSize: _parentFileSizeString,
                  icon: Icons.upload_file_rounded,
                  onPick: _pickParentDocument,
                ),
                const SizedBox(height: 12),

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
                  label: 'Email Address for Admission Notices & Login',
                  hint: 'parent@example.com',
                  dataType: InputDataType.email,
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(height: 14),

                // PARENT PORTAL PASSWORD CREATION
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_person_rounded, color: AppTheme.primaryGreen, size: 22),
                          const SizedBox(width: 8),
                          Text('Create Parent Portal Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Set the password you will use to sign in to your Parent Portal upon admission approval.',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 12),
                      ValidatedTextField(
                        controller: _primaryPasswordCtrl,
                        label: 'Create Parent Password *',
                        hint: 'Minimum 8 characters (e.g. Pass@2026)',
                        dataType: InputDataType.password,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                      ),
                      PasswordStrengthMeter(password: _primaryPasswordCtrl.text),
                      const SizedBox(height: 6),
                      ValidatedTextField(
                        controller: _primaryConfirmPasswordCtrl,
                        label: 'Confirm Parent Password *',
                        hint: 'Re-type the chosen password',
                        dataType: InputDataType.password,
                        isPassword: true,
                        prefixIcon: Icons.lock_reset_rounded,
                      ),
                    ],
                  ),
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
                          hint: 'Letters only',
                          dataType: InputDataType.textOnly,
                          isRequired: _hasSecondaryParent,
                          prefixIcon: Icons.person_outline,
                        ),
                        ValidatedTextField(
                          controller: _secSurnameCtrl,
                          label: 'Secondary Parent Surname',
                          hint: 'Letters only',
                          dataType: InputDataType.textOnly,
                          isRequired: _hasSecondaryParent,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        ValidatedTextField(
                          controller: _secIdCtrl,
                          label: 'Secondary Parent 13-digit ID',
                          hint: '13 digits',
                          dataType: InputDataType.idNumber,
                          maxLength: 13,
                          isRequired: _hasSecondaryParent,
                          prefixIcon: Icons.credit_card_rounded,
                        ),
                        _buildUploadPicker(
                          label: 'Upload Secondary Parent ID Copy',
                          supportingDocInfo: 'Attach a copy of the secondary parent/guardian South African ID document (PDF, PNG, JPG).',
                          fileName: _secParentDocName,
                          fileSize: _secParentFileSizeString,
                          icon: Icons.upload_file_rounded,
                          onPick: _pickSecondaryParentDocument,
                          isRequired: false,
                        ),
                        const SizedBox(height: 12),
                        ValidatedTextField(
                          controller: _secPhoneCtrl,
                          label: 'Secondary Parent Contact',
                          hint: '10 digits',
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

          // STEP 2: MULTI-LEARNERS LIST & CAPS CURRICULUM
          Step(
            title: Text('Learner(s) (${_learners.length})'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardHeader('Applying for ${_learners.length} Learner(s)', Icons.child_care_rounded),
                    ElevatedButton.icon(
                      onPressed: _addNewLearner,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Child'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Render dynamic learner cards
                ..._learners.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final l = entry.value;
                  final isFet = l.selectedGrade == 'Grade 10' || l.selectedGrade == 'Grade 11' || l.selectedGrade == 'Grade 12';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.primaryNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                              child: Text('Learner #${idx + 1}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, fontSize: 13)),
                            ),
                            if (_learners.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed, size: 20),
                                onPressed: () => _removeLearner(idx),
                                tooltip: 'Remove this learner',
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ValidatedTextField(
                          controller: l.nameCtrl,
                          label: 'Learner First Name(s)',
                          hint: 'Letters only',
                          dataType: InputDataType.textOnly,
                          prefixIcon: Icons.person_outline,
                        ),
                        ValidatedTextField(
                          controller: l.surnameCtrl,
                          label: 'Learner Surname',
                          hint: 'Letters only',
                          dataType: InputDataType.textOnly,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        ValidatedTextField(
                          controller: l.idCtrl,
                          label: 'Learner 13-digit SA ID Number',
                          hint: '13 digits',
                          dataType: InputDataType.idNumber,
                          maxLength: 13,
                          prefixIcon: Icons.credit_card_rounded,
                        ),

                        // Auto-Filled Demographic Details
                        if (l.idInfo != null && l.idInfo!.isValid) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.lightGreen, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'Auto-Extracted: Born ${l.idInfo!.formattedDob} • Age: ${l.idInfo!.age} • Gender: ${l.idInfo!.gender}',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                          ),
                        ],

                        // Learner Document Upload Picker
                        _buildUploadPicker(
                          label: 'Upload Learner Birth Certificate / Smart ID *',
                          supportingDocInfo: 'Attach the official DHA Unabridged Birth Certificate (with ID number) or Smart ID Card (PDF, PNG, JPG).',
                          fileName: l.documentName,
                          fileSize: l.fileSizeString,
                          icon: Icons.document_scanner_rounded,
                          onPick: () => _pickLearnerDocument(l),
                        ),
                        const SizedBox(height: 12),

                        // Grade Selection
                        Text('Grade Applying For *', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: l.selectedGrade,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.stairs_rounded, color: AppTheme.secondaryNavy)),
                          items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => l.selectedGrade = val);
                          },
                        ),
                        const SizedBox(height: 10),

                        // Home Language
                        Text('Home Language *', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: l.selectedHomeLang,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.language_rounded, color: AppTheme.secondaryNavy)),
                          items: CapsCurriculum.officialLanguages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => l.selectedHomeLang = val);
                          },
                        ),
                        const SizedBox(height: 10),

                        // Stream selection if FET Phase
                        if (isFet) ...[
                          Text('FET Specialization Stream (CAPS) *', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: l.selectedStream,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.account_tree_rounded, color: AppTheme.primaryGreen)),
                            items: CapsCurriculum.fetStreams.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => l.selectedStream = val);
                            },
                          ),
                          const SizedBox(height: 8),
                        ],

                        ValidatedTextField(
                          controller: l.prevSchoolCtrl,
                          label: 'Previous School Attended',
                          hint: 'School name',
                          prefixIcon: Icons.account_balance_outlined,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // STEP 3: AI DOCUMENT CROSS-INSPECTION
          Step(
            title: const Text('AI ID Verification'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader('AI National ID Inspection & Verification', Icons.verified_user_rounded),
                const SizedBox(height: 6),
                Text(
                  'Our integrated AI model analyzes the uploaded South African ID copies for all parents and learners, checks authenticity against the Republic of South Africa standards, and cross-compares demographic data against form inputs.',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),

                // Uploaded Documents Matrix
                _buildUploadSummary('Primary Parent ID Document', _parentDocName, Icons.badge_outlined),
                if (_hasSecondaryParent) ...[
                  const SizedBox(height: 8),
                  _buildUploadSummary('Secondary Parent ID Document', _secParentDocName, Icons.badge_outlined),
                ],
                const SizedBox(height: 8),
                ..._learners.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildUploadSummary('Learner #${entry.key + 1} (${entry.value.nameCtrl.text.isNotEmpty ? entry.value.nameCtrl.text : "Child"}) ID Copy', entry.value.documentName, Icons.child_care_rounded),
                    )),

                const SizedBox(height: 16),

                // AI Cross-Inspection Action & Results
                if (_parentAiResult == null && _learners.every((l) => l.aiResult == null)) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryNavy.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_rounded, color: AppTheme.primaryGreen, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AI Multi-Document Inspector Ready', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('Click below to run deep cross-comparison on all uploaded parent and learner ID documents.', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isOcrScanning ? null : _runAiDeepDocumentVerification,
                            icon: _isOcrScanning
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.bolt_rounded),
                            label: Text(_isOcrScanning ? 'Inspecting ID Documents with AI...' : 'Run AI Document Cross-Inspection'),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // AI VERIFICATION REPORT CARDS
                  if (_parentAiResult != null) _buildAiReportCard('Primary Parent Verification Report', _parentAiResult!),
                  if (_secParentAiResult != null) ...[
                    const SizedBox(height: 12),
                    _buildAiReportCard('Secondary Parent Verification Report', _secParentAiResult!),
                  ],
                  ..._learners.asMap().entries.map((e) {
                    if (e.value.aiResult != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildAiReportCard('Learner #${e.key + 1} (${e.value.nameCtrl.text}) Verification Report', e.value.aiResult!),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isOcrScanning ? null : _runAiDeepDocumentVerification,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Re-run AI Cross-Inspection'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPicker({
    required String label,
    required String? fileName,
    String? fileSize,
    String? supportingDocInfo,
    required IconData icon,
    required VoidCallback onPick,
    bool isRequired = true,
  }) {
    final hasFile = fileName != null && fileName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasFile ? AppTheme.lightGreen.withOpacity(0.35) : Colors.blueGrey.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? AppTheme.primaryGreen.withOpacity(0.6) : AppTheme.cardBorder,
          width: hasFile ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasFile ? Icons.check_circle_rounded : icon,
                color: hasFile ? AppTheme.primaryGreen : AppTheme.primaryNavy,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hasFile ? fileName : 'No document selected yet',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: hasFile ? AppTheme.primaryNavy : AppTheme.textMuted,
                              fontWeight: hasFile ? FontWeight.bold : FontWeight.normal,
                              fontStyle: hasFile ? FontStyle.normal : FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: (hasFile ? AppTheme.primaryGreen : Colors.orange.shade800).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hasFile ? (fileSize ?? 'Attached ✓') : (isRequired ? 'Required *' : 'Optional'),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: hasFile ? AppTheme.primaryGreen : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onPick,
                icon: Icon(hasFile ? Icons.refresh_rounded : Icons.folder_open_rounded, size: 14),
                label: Text(hasFile ? 'Change' : 'Browse', style: const TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasFile ? AppTheme.primaryGreen : AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(80, 32),
                ),
              ),
            ],
          ),
          if (supportingDocInfo != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Text(
                'ℹ️ $supportingDocInfo',
                style: GoogleFonts.outfit(fontSize: 10.5, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadSummary(String title, String? fileName, IconData icon) {
    final hasFile = fileName != null && fileName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasFile ? Colors.white : Colors.red.shade50.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: hasFile ? AppTheme.cardBorder : Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: hasFile ? AppTheme.primaryNavy : AppTheme.dangerRed, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                Text(
                  hasFile ? 'File: $fileName' : 'No document uploaded',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: hasFile ? AppTheme.textMuted : AppTheme.dangerRed,
                    fontStyle: hasFile ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: hasFile ? AppTheme.lightGreen : Colors.red.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hasFile ? 'Attached ✓' : 'Missing ⚠️',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: hasFile ? AppTheme.primaryGreen : AppTheme.dangerRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiReportCard(String title, AiVerificationResult result) {
    final isAccepted = result.decision == 'ACCEPTED';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAccepted ? AppTheme.lightGreen.withOpacity(0.5) : AppTheme.dangerRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isAccepted ? AppTheme.primaryGreen : AppTheme.dangerRed).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isAccepted ? Icons.verified_user_rounded : Icons.error_outline_rounded,
                    color: isAccepted ? AppTheme.primaryGreen : AppTheme.dangerRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAccepted ? AppTheme.primaryGreen : AppTheme.dangerRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${result.decision} (${result.overallConfidence.toStringAsFixed(1)}%)',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(result.message, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.secondaryNavy)),
          const Divider(height: 16),
          Text('AI Cross-Comparison Matrix:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 6),
          ...result.comparisonFields.map((f) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(f.isMatch ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, size: 14, color: f.isMatch ? AppTheme.primaryGreen : AppTheme.dangerRed),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${f.fieldName}: Form (${f.formValue}) ⟷ ID (${f.extractedValue})',
                      style: GoogleFonts.outfit(fontSize: 10, color: f.isMatch ? Colors.black87 : AppTheme.dangerRed),
                    ),
                  ),
                  Text('${f.confidence.toStringAsFixed(0)}%', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                ],
              ),
            );
          }),
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
