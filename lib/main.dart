import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'data/mock_database.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/admissions/admission_application_screen.dart';
import 'features/admissions/registration_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/learner/learner_dashboard.dart';
import 'features/parent/parent_dashboard.dart';
import 'features/principal/principal_dashboard.dart';
import 'features/teacher/teacher_dashboard.dart';
import 'models/models.dart';
import 'widgets/custom_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThutoTechApp());
}

class ThutoTechApp extends StatelessWidget {
  const ThutoTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThutoTech - Learn • Connect • Empower',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      home: const MainAppWrapper(),
    );
  }
}

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  final MockDatabase _db = MockDatabase();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _db.addListener(_onDbUpdated);
  }

  @override
  void dispose() {
    _db.removeListener(_onDbUpdated);
    super.dispose();
  }

  void _onDbUpdated() {
    if (mounted) setState(() {});
  }

  Widget _getCurrentPortal() {
    switch (_db.currentUser?.role ?? UserRole.parent) {
      case UserRole.learner:
        return LearnerDashboard(db: _db);
      case UserRole.parent:
        return ParentDashboard(db: _db);
      case UserRole.teacher:
        return TeacherDashboard(db: _db);
      case UserRole.principal:
        return PrincipalDashboard(db: _db);
      case UserRole.admin:
        return AdminDashboard(db: _db);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated && _db.currentUser == null) {
      return LoginScreen(
        db: _db,
        onLoginSuccess: () {
          setState(() {
            _isAuthenticated = true;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_logo.jpg',
                height: 32,
                width: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.school_rounded, color: AppTheme.primaryGreen, size: 28),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ThutoTech',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          // Admission Application Button
          IconButton(
            icon: const Icon(Icons.app_registration_rounded, color: Colors.white),
            tooltip: 'Apply for Admission',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdmissionApplicationScreen(db: _db)),
              );
            },
          ),
          // Complete Registration Button
          IconButton(
            icon: const Icon(Icons.how_to_reg_rounded, color: AppTheme.primaryGreen),
            tooltip: 'Complete Registration',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegistrationScreen(db: _db)),
              );
            },
          ),
          // Notification badge button
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (_db.notifications.where((n) => !n.isRead).isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppTheme.dangerRed, shape: BoxShape.circle),
                      child: Text(
                        '${_db.notifications.where((n) => !n.isRead).length}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'System Notifications',
            onPressed: _showNotificationsModal,
          ),
          // Sign out
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () {
              setState(() {
                _db.currentUser = null;
                _isAuthenticated = false;
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          RoleSwitcherBar(
            db: _db,
            onRoleSwitched: () => setState(() {}),
          ),
          Expanded(child: _getCurrentPortal()),
        ],
      ),
    );
  }

  void _showNotificationsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          Text('Notifications', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            for (var n in _db.notifications) {
                              n.isRead = true;
                            }
                          });
                          setState(() {});
                        },
                        child: const Text('Mark all as read'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _db.notifications.isEmpty
                      ? Center(child: Text('No notifications.', style: GoogleFonts.outfit(color: AppTheme.textMuted)))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _db.notifications.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (ctx, i) {
                            final notif = _db.notifications[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: notif.isRead ? Colors.grey.shade200 : AppTheme.primaryGreen.withOpacity(0.15),
                                  child: Icon(
                                    _getNotificationIcon(notif.category),
                                    color: notif.isRead ? Colors.grey : AppTheme.primaryGreen,
                                  ),
                                ),
                                title: Text(notif.title, style: GoogleFonts.outfit(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notif.body, style: GoogleFonts.outfit(fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${notif.timestamp.hour}:${notif.timestamp.minute.toString().padLeft(2, '0')} • ${notif.timestamp.day}/${notif.timestamp.month}',
                                      style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                                trailing: !notif.isRead
                                    ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle))
                                    : null,
                                onTap: () {
                                  setModalState(() => notif.isRead = true);
                                  setState(() {});
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.academic:
        return Icons.menu_book_rounded;
      case NotificationCategory.attendance:
        return Icons.event_available_rounded;
      case NotificationCategory.announcement:
        return Icons.campaign_rounded;
      case NotificationCategory.achievement:
        return Icons.emoji_events_rounded;
      case NotificationCategory.system:
        return Icons.admin_panel_settings_rounded;
    }
  }
}
