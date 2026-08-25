import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation/input_validators.dart';
import '../../data/mock_database.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final MockDatabase db;
  final String? initialEmail;
  final String? initialOtp;

  const ForgotPasswordScreen({
    super.key,
    required this.db,
    this.initialEmail,
    this.initialOtp,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentStep = 0; // 0: Request OTP, 1: Enter OTP, 2: Reset Password

  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // 2-minute countdown timer
  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes
  bool _isExpired = false;

  // Live password similarity detection
  bool _isCloseToOldPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
    }
    if (widget.initialOtp != null && widget.initialOtp!.isNotEmpty) {
      _otpCtrl.text = widget.initialOtp!;
      _currentStep = 1;
      _startTimer();
    }

    _newPasswordCtrl.addListener(_checkPasswordSimilarity);
  }

  void _checkPasswordSimilarity() {
    final text = _newPasswordCtrl.text.trim();
    if (text.length >= 4) {
      final isClose = widget.db.isPasswordCloseToOldPassword(_emailCtrl.text, text);
      if (isClose != _isCloseToOldPassword) {
        setState(() {
          _isCloseToOldPassword = isClose;
        });
      }
    } else if (_isCloseToOldPassword) {
      setState(() {
        _isCloseToOldPassword = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 120;
      _isExpired = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isExpired = true;
        });
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.removeListener(_checkPasswordSimilarity);
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // --- Step 1: Request 6-digit OTP ---
  void _requestOtp() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final generatedOtp = widget.db.requestPasswordResetOtp(email);
      _startTimer();

      setState(() {
        _isLoading = false;
        _currentStep = 1;
        _successMessage = 'A 6-digit verification code has been dispatched to $email. It expires in 2 minutes.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // --- Step 2: Verify 6-digit OTP ---
  void _verifyOtp() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code.');
      return;
    }

    if (_isExpired) {
      setState(() => _errorMessage = 'This OTP has expired (2-minute limit exceeded). Please tap Resend.');
      return;
    }

    try {
      widget.db.verifyPasswordResetOtp(_emailCtrl.text, otp);
      setState(() {
        _currentStep = 2;
        _successMessage = 'OTP verified successfully! Please choose your new password.';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    }
  }

  // --- Step 3: Set New Password ---
  void _submitNewPassword() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final pass = _newPasswordCtrl.text.trim();
    final confirm = _confirmPasswordCtrl.text.trim();

    if (pass.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters long.');
      return;
    }

    if (pass != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    try {
      widget.db.completePasswordReset(
        email: _emailCtrl.text,
        otp: _otpCtrl.text,
        newPassword: pass,
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
              Text('Password Reset Complete!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          content: Text(
            'Your password has been securely updated. You can now sign into your ThutoTech account.',
            style: GoogleFonts.outfit(fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Proceed to Sign In'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reset Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryGreen, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password Recovery', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('Secure 6-digit OTP verification', style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Step Progress Indicator
                Row(
                  children: [
                    _buildStepIndicator(step: 0, label: 'Email'),
                    _buildStepLine(active: _currentStep >= 1),
                    _buildStepIndicator(step: 1, label: 'Verify OTP'),
                    _buildStepLine(active: _currentStep >= 2),
                    _buildStepIndicator(step: 2, label: 'New Password'),
                  ],
                ),
                const SizedBox(height: 24),

                // Status Alerts
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.dangerRed.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.dangerRed.withOpacity(0.4))),
                    child: Text(_errorMessage!, style: GoogleFonts.outfit(color: const Color(0xFFFF8080), fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_successMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4))),
                    child: Text(_successMessage!, style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                ],

                // STEP 0: EMAIL INPUT
                if (_currentStep == 0) ...[
                  Text('Enter Account Email Address', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'user@thutotech.co.za or parent@gmail.com',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.accentGreen),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _requestOtp,
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded),
                      label: Text(_isLoading ? 'Sending OTP...' : 'Send 6-Digit OTP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],

                // STEP 1: OTP CODE & 2-MIN COUNTDOWN
                if (_currentStep == 1) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enter 6-Digit OTP Code', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isExpired ? AppTheme.dangerRed.withOpacity(0.2) : AppTheme.primaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _isExpired ? AppTheme.dangerRed : AppTheme.primaryGreen),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: _isExpired ? AppTheme.dangerRed : AppTheme.accentGreen),
                            const SizedBox(width: 4),
                            Text(
                              _isExpired ? 'EXPIRED' : _formattedTime,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _isExpired ? AppTheme.dangerRed : AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _otpCtrl,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 6),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isExpired ? null : _verifyOtp,
                      icon: const Icon(Icons.verified_rounded),
                      label: const Text('Verify Code & Proceed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: _requestOtp,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Resend New OTP Code'),
                    ),
                  ),
                ],

                // STEP 2: NEW PASSWORD & SIMILARITY CHECK
                if (_currentStep == 2) ...[
                  // Similarity Warning Banner
                  if (_isCloseToOldPassword) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "You're very close to your old password!",
                                  style: GoogleFonts.outfit(color: const Color(0xFFFCD34D), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "If you remember your password, you can simply sign in directly without changing it.",
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFCD34D),
                                side: const BorderSide(color: Color(0xFFF59E0B)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: const Size(60, 28),
                              ),
                              child: const Text('Go to Sign In', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Text('New Password', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _newPasswordCtrl,
                    obscureText: _obscureNewPass,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter new secure password',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.accentGreen),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNewPass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white60),
                        onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Confirm New Password', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirmPass,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Re-enter new password',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppTheme.accentGreen),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPass ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white60),
                        onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitNewPassword,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Update Password & Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required int step, required String label}) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primaryGreen : Colors.white.withOpacity(0.15),
            border: Border.all(color: isCurrent ? Colors.white : Colors.transparent, width: 2),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: isActive ? Colors.white : Colors.white54),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, color: isActive ? Colors.white : Colors.white54, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        color: active ? AppTheme.primaryGreen : Colors.white.withOpacity(0.15),
      ),
    );
  }
}
