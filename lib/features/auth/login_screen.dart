import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/app_download_modal.dart';
import '../admissions/admission_application_screen.dart';
import '../admissions/registration_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final MockDatabase db;
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.db, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int? _lockoutSecondsRemaining;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    // Auto-pop the Download App dialog upon device access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppDownloadModal.show(context);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockoutCountdown(int seconds) {
    setState(() => _lockoutSecondsRemaining = seconds);
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockoutSecondsRemaining! <= 1) {
        timer.cancel();
        setState(() {
          _lockoutSecondsRemaining = null;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _lockoutSecondsRemaining = _lockoutSecondsRemaining! - 1;
        });
      }
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final identifier = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your login email / student number and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Attempt Backend API Authentication
      User? authenticatedUser;
      try {
        final backendResponse = await ApiService.login(identifier, password);
        if (backendResponse['success'] == true && backendResponse['user'] != null) {
          final uData = backendResponse['user'];
          final roleString = (uData['role'] as String).toLowerCase();
          final userRole = UserRole.values.firstWhere(
            (r) => r.name == roleString,
            orElse: () => UserRole.parent,
          );

          authenticatedUser = User(
            id: uData['id'],
            email: uData['email'],
            name: uData['name'],
            surname: uData['surname'],
            role: userRole,
            phone: uData['phone'] ?? '',
            avatarUrl: '',
            schoolId: uData['schoolId'] ?? 'sch_thutotech',
            twoFactorEnabled: userRole == UserRole.admin || userRole == UserRole.principal,
          );

          widget.db.currentUser = authenticatedUser;
        } else if (backendResponse['locked'] == true) {
          final secs = backendResponse['remainingSeconds'] ?? 300;
          _startLockoutCountdown(secs);
          throw Exception(backendResponse['message'] ?? 'Account is temporarily locked.');
        } else if (backendResponse['message'] != null && backendResponse['success'] == false) {
          throw Exception(backendResponse['message']);
        }
      } catch (backendError) {
        final errStr = backendError.toString();
        if (errStr.contains('locked') || errStr.contains('Invalid') || errStr.contains('attempts remaining')) {
          rethrow;
        }
        // Fallback to local hardened engine if offline
        authenticatedUser = widget.db.authenticate(
          identifier: identifier,
          password: password,
        );
      }

      if (authenticatedUser == null) {
        throw Exception('Authentication failed.');
      }

      // 2. Check Two-Factor Authentication (2FA) for protected roles
      if (authenticatedUser.twoFactorEnabled) {
        setState(() => _isLoading = false);
        await _promptTwoFactorOtpDialog(authenticatedUser);
      } else {
        setState(() => _isLoading = false);
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _promptTwoFactorOtpDialog(User user) async {
    final otpController = TextEditingController();
    String? otpError;
    int remainingSeconds = 120;
    Timer? otpTimer;

    // Send 2FA OTP to user email
    try {
      widget.db.sendTwoFactorOtp(user.email);
    } catch (_) {}

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            otpTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (remainingSeconds <= 1) {
                t.cancel();
                setDialogState(() {
                  remainingSeconds = 0;
                  otpError = 'OTP has expired. Please request a new security code.';
                });
              } else {
                setDialogState(() {
                  remainingSeconds--;
                });
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.security_rounded, color: AppTheme.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('Two-Factor 2FA', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A 6-digit security code was dispatched via SMTP to:',
                    style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (otpError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(otpError!, style: GoogleFonts.outfit(color: AppTheme.dangerRed, fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, letterSpacing: 8),
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppTheme.warningOrange),
                          const SizedBox(width: 4),
                          Text(
                            'Expires in ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: remainingSeconds == 0
                            ? () {
                                widget.db.sendTwoFactorOtp(user.email);
                                setDialogState(() {
                                  remainingSeconds = 120;
                                  otpError = null;
                                });
                              }
                            : null,
                        child: const Text('Resend Code', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    otpTimer?.cancel();
                    Navigator.pop(dialogCtx);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      final code = otpController.text.trim();
                      if (code.length != 6) {
                        setDialogState(() => otpError = 'Please enter a valid 6-digit OTP.');
                        return;
                      }

                      final isValid = widget.db.verifyTwoFactorOtp(user.email, code);
                      if (isValid) {
                        otpTimer?.cancel();
                        Navigator.pop(dialogCtx);
                        widget.onLoginSuccess();
                      }
                    } catch (e) {
                      setDialogState(() => otpError = e.toString().replaceAll('Exception: ', ''));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Verify & Enter'),
                ),
              ],
            );
          },
        );
      },
    );

    otpTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient & Cyber Grid
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF030712), Color(0xFF0B192C), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Glow accents
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryNavy.withOpacity(0.3),
              ),
            ),
          ),

          // Top-Right Download App Button
          Positioned(
            top: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () => AppDownloadModal.show(context),
              icon: const Icon(Icons.download_rounded, size: 16, color: Colors.black),
              label: Text(
                'Get App 📲',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo & Header
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/app_logo.jpg',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: AppTheme.primaryGreen, size: 70),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ThutoTech',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'LEARN • CONNECT • EMPOWER',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGreen,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Glassmorphic Login Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E1E32).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Portal Sign In',
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter your credentials to access your designated role portal',
                            style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 20),

                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.dangerRed.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.dangerRed.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppTheme.dangerRed, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (_lockoutSecondsRemaining != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.warningOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.warningOrange.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock_clock_rounded, color: AppTheme.warningOrange, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Account Locked. Try again in ${_lockoutSecondsRemaining!}s',
                                      style: GoogleFonts.outfit(color: AppTheme.warningOrange, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email / Identifier Field
                          Text('Login Email or Student Number', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailController,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'e.g. parent@thutotech.co.za or 20260001',
                              hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 13),
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryGreen),
                              filled: true,
                              fillColor: const Color(0xFF132238),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Password Field with View Password Icon
                          Text('Password', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Enter your account password',
                              hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 13),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryGreen),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: AppTheme.primaryGreen,
                                  size: 20,
                                ),
                                tooltip: _obscurePassword ? 'View Password' : 'Hide Password',
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF132238),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Forgot Password Action
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordScreen(
                                      db: widget.db,
                                      initialEmail: _emailController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                minimumSize: const Size(50, 30),
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_isLoading || _lockoutSecondsRemaining != null) ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(
                                      'Sign In to Dashboard',
                                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions (Apply & Complete Registration)
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AdmissionApplicationScreen(db: widget.db)),
                            );
                          },
                          icon: const Icon(Icons.school_outlined, size: 16, color: Colors.white70),
                          label: Text(
                            'Apply for Admission',
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => RegistrationScreen(db: widget.db)),
                            );
                          },
                          icon: const Icon(Icons.how_to_reg_rounded, size: 16, color: AppTheme.accentGreen),
                          label: Text(
                            'Complete Registration',
                            style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
