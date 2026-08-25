import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_theme.dart';

class AppDownloadModal extends StatelessWidget {
  const AppDownloadModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const AppDownloadModal(),
    );
  }

  Future<void> _launchDownloadUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $url...', style: GoogleFonts.outfit())),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading application package...', style: GoogleFonts.outfit())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B192C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button & Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.download_rounded, color: AppTheme.accentGreen, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'DOWNLOAD OFFICIAL APP',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentGreen, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Logo & App Name
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.25), blurRadius: 16),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_logo.jpg',
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: AppTheme.primaryGreen, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Get the ThutoTech App',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enjoy offline access, instant push notifications, real-time CAPS study materials, and direct teacher messaging on your device.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  color: const Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // DOWNLOAD OPTIONS
              // 1. Android APK
              _buildDownloadOption(
                context: context,
                icon: Icons.android_rounded,
                iconColor: const Color(0xFF3DDC84),
                title: 'Android Mobile App',
                subtitle: 'Direct APK Package & Google Play',
                badgeText: 'Recommended for Phones',
                isPrimary: isMobile,
                onTap: () => _launchDownloadUrl(context, 'https://thutotechapp-1-p9dy.onrender.com/downloads/thutotech.apk'),
              ),
              const SizedBox(height: 10),

              // 2. Windows PC (.exe)
              _buildDownloadOption(
                context: context,
                icon: Icons.desktop_windows_rounded,
                iconColor: const Color(0xFF00ADEF),
                title: 'Windows Desktop App',
                subtitle: 'Direct Standalone Installer (.exe)',
                badgeText: 'PC / Laptop',
                isPrimary: !isMobile,
                onTap: () => _launchDownloadUrl(context, 'https://thutotechapp-1-p9dy.onrender.com/downloads/thutotech-setup.exe'),
              ),
              const SizedBox(height: 10),

              // 3. Apple iOS / PWA
              _buildDownloadOption(
                context: context,
                icon: Icons.apple_rounded,
                iconColor: Colors.white,
                title: 'Apple iOS / Web App (PWA)',
                subtitle: 'Tap Share ➔ Add to Home Screen',
                badgeText: 'iPhone / iPad / Mac',
                isPrimary: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('On iPhone/iPad: Tap Share (⎋) and select "Add to Home Screen" to install!', style: GoogleFonts.outfit()),
                      backgroundColor: AppTheme.primaryGreen,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Continue on Web
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Continue on Web Browser ➔',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen.withOpacity(0.12) : const Color(0xFF132238),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? AppTheme.primaryGreen : Colors.white.withOpacity(0.1),
            width: isPrimary ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 6),
                      if (isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(4)),
                          child: Text('DETECTED', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
          ],
        ),
      ),
    );
  }
}
