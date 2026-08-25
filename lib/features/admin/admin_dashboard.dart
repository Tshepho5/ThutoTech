import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../widgets/custom_widgets.dart';

class AdminDashboard extends StatefulWidget {
  final MockDatabase db;

  const AdminDashboard({super.key, required this.db});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUsers = widget.db.users.where((u) {
      final q = _searchQuery.toLowerCase();
      return u.fullName.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.role.name.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF020617), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryGreen,
                          child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SYSTEM ADMINISTRATOR CONSOLE',
                                style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.db.currentUser?.name} ${widget.db.currentUser?.surname}',
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Core Platform Infrastructure & Security Management',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SYSTEM HEALTH TELEMETRY
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Users',
                          value: '${widget.db.users.length}',
                          subtitle: '5 Active Roles',
                          icon: Icons.people_alt_rounded,
                          iconColor: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'System Health',
                          value: '100% OK',
                          subtitle: 'All Services Operational',
                          icon: Icons.health_and_safety_rounded,
                          iconColor: AppTheme.infoBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Automation Rules',
                          value: '${widget.db.automationRules.length}',
                          subtitle: 'Active Sentinels',
                          icon: Icons.bolt_rounded,
                          iconColor: AppTheme.warningOrange,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Audit Events',
                          value: '${widget.db.auditLogs.length}',
                          subtitle: 'Security Logged',
                          icon: Icons.security_rounded,
                          iconColor: AppTheme.purpleAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // USER MANAGEMENT & RBAC
                  SectionHeader(
                    title: 'User Management & Access Control',
                    subtitle: 'Directory of authenticated platform accounts',
                    trailing: Text('${filteredUsers.length} Users', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),

                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search users by name, email, or role...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...filteredUsers.map((u) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryNavy.withOpacity(0.1),
                          child: Icon(u.role.icon, color: AppTheme.primaryNavy, size: 20),
                        ),
                        title: Text(u.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${u.email} • ${u.phone}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            u.role.displayName,
                            style: GoogleFonts.outfit(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 28),

                  // AUTOMATION RULES MONITOR
                  const SectionHeader(
                    title: 'Event-Driven Automation Engine',
                    subtitle: 'Reusable triggers, conditions, and actions active in ThutoTech',
                  ),
                  ...widget.db.automationRules.map((rule) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(rule.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text('ACTIVE • ${rule.runCount} RUNS', style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Event Trigger: ${rule.eventName}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.secondaryNavy)),
                            const SizedBox(height: 4),
                            Text('Condition: ${rule.conditionDescription}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            Text('Action: ${rule.actionDescription}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.primaryGreen)),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 28),

                  // IMMUTABLE AUDIT LOGS
                  const SectionHeader(
                    title: 'System Security & Audit Logs',
                    subtitle: 'Immutable traceability of privileged actions and automated events',
                  ),
                  ...widget.db.auditLogs.map((log) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.primaryNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
                                  child: Text(log.action, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                ),
                                Text(
                                  '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')} • ${log.timestamp.day}/${log.timestamp.month}',
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(log.details, style: GoogleFonts.outfit(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('Actor: ${log.userName} (${log.role}) • Entity: ${log.entity}', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
