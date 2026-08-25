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

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userSearchQuery = '';
  String _selectedRoleFilter = 'ALL';
  String _subjectSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.db,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryGreen, width: 2),
                              ),
                              child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentGreen, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'SUPER ADMINISTRATOR',
                                        style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(4)),
                                        child: Text('ROOT ACCESS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${widget.db.currentUser?.name ?? "Lebogang"} ${widget.db.currentUser?.surname ?? "Makola"}',
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${widget.db.currentUser?.email ?? "thutotech.admin@gmail.com"} • ID: 8206051072085',
                                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTopBadge(Icons.domain_rounded, 'ThutoTech Academy'),
                            const SizedBox(width: 8),
                            _buildTopBadge(Icons.verified_user_rounded, 'National CAPS Ecosystem'),
                            const SizedBox(width: 8),
                            _buildTopBadge(Icons.speed_rounded, '100% Operational'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.accentGreen,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: AppTheme.accentGreen,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                  tabs: [
                    Tab(icon: const Icon(Icons.people_alt_rounded, size: 18), text: 'Users & Staff (${widget.db.users.length})'),
                    Tab(icon: const Icon(Icons.menu_book_rounded, size: 18), text: 'CAPS Subjects (${widget.db.subjects.length})'),
                    Tab(icon: const Icon(Icons.assignment_ind_rounded, size: 18), text: 'Admissions (${widget.db.admissions.length})'),
                    Tab(icon: const Icon(Icons.campaign_rounded, size: 18), text: 'Announcements (${widget.db.announcements.length})'),
                    Tab(icon: const Icon(Icons.security_rounded, size: 18), text: 'Audit Logs (${widget.db.auditLogs.length})'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildSubjectsTab(),
                _buildAdmissionsTab(),
                _buildAnnouncementsTab(),
                _buildAuditTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: USERS & STAFF MANAGEMENT
  // ==========================================
  Widget _buildUsersTab() {
    final filteredUsers = widget.db.users.where((u) {
      final q = _userSearchQuery.toLowerCase();
      final matchesQuery = u.fullName.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.phone.contains(q);
      final matchesRole = _selectedRoleFilter == 'ALL' || u.role.name.toUpperCase() == _selectedRoleFilter;
      return matchesQuery && matchesRole;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Directory & Access Control', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
                  Text('Manage teachers, principals, parents, learners, and platform accounts', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddTeacherDialog,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Appoint Teacher'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search & Role Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _userSearchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search users by name, email, or phone number...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.cardBorder)),
                  child: DropdownButton<String>(
                    value: _selectedRoleFilter,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Roles')),
                      DropdownMenuItem(value: 'TEACHER', child: Text('Teachers')),
                      DropdownMenuItem(value: 'PARENT', child: Text('Parents')),
                      DropdownMenuItem(value: 'LEARNER', child: Text('Learners')),
                      DropdownMenuItem(value: 'PRINCIPAL', child: Text('Principals')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Admins')),
                    ],
                    onChanged: (v) => setState(() => _selectedRoleFilter = v ?? 'ALL'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (filteredUsers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
              child: Column(
                children: [
                  const Icon(Icons.people_outline_rounded, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  Text('No users matching current search/filter.', style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 14)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final u = filteredUsers[index];
                final isSuperAdmin = u.email == 'thutotech.admin@gmail.com';
                final isTeacher = u.role == UserRole.teacher;
                final teacherProfile = isTeacher ? widget.db.teachers.cast<Teacher?>().firstWhere((t) => t?.userId == u.id, orElse: () => null) : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.cardBorder)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: _getRoleColor(u.role).withOpacity(0.12),
                          child: Icon(u.role.icon, color: _getRoleColor(u.role), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(u.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(u.role).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      u.role.displayName,
                                      style: GoogleFonts.outfit(color: _getRoleColor(u.role), fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                  if (isSuperAdmin) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(4)),
                                      child: Text('PRIMARY ROOT', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('✉️ ${u.email} • 📞 ${u.phone.isNotEmpty ? u.phone : "No Phone"}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                              if (teacherProfile != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '📚 Assigned: ${teacherProfile.assignedSubjectIds.length} Subject(s) • 🏫 ${teacherProfile.assignedClassIds.length} Class(es)',
                                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isSuperAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed, size: 20),
                            tooltip: 'Delete User Account',
                            onPressed: () => _confirmDeleteUser(u),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: CAPS SUBJECTS & TEACHER ASSIGNMENT
  // ==========================================
  Widget _buildSubjectsTab() {
    final filteredSubjects = widget.db.subjects.where((s) {
      final q = _subjectSearchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.code.toLowerCase().contains(q) || s.grade.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CAPS Curriculum & Teacher Assignment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
                  Text('Assign certified educators to Mathematics, Sciences, Languages & Commerce', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primaryNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Text('${filteredSubjects.length} Active CAPS Subjects', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryNavy)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            onChanged: (v) => setState(() => _subjectSearchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search subjects by name, code, or grade...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredSubjects.length,
            itemBuilder: (context, index) {
              final sub = filteredSubjects[index];
              final assignedTeacher = widget.db.teachers.cast<Teacher?>().firstWhere(
                    (t) => t?.id == sub.teacherId,
                    orElse: () => null,
                  );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.cardBorder)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_stories_rounded, color: AppTheme.primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(sub.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppTheme.primaryNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                                  child: Text(sub.grade, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Curriculum Code: ${sub.code}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  assignedTeacher != null ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                                  size: 14,
                                  color: assignedTeacher != null ? AppTheme.primaryGreen : AppTheme.warningOrange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  assignedTeacher != null
                                      ? 'Assigned Educator: ${assignedTeacher.fullName} ${assignedTeacher.surname}'
                                      : 'No Educator Assigned (Vacant)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: assignedTeacher != null ? AppTheme.primaryGreen : AppTheme.warningOrange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showAssignTeacherDialog(sub),
                        icon: const Icon(Icons.person_outline_rounded, size: 16),
                        label: Text(assignedTeacher != null ? 'Reassign' : 'Assign'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryNavy,
                          side: const BorderSide(color: AppTheme.primaryNavy),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: ADMISSIONS QUEUE & APPROVALS
  // ==========================================
  Widget _buildAdmissionsTab() {
    final admissionsList = widget.db.admissions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admissions & Registration Queue', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
                  Text('Automated AI identity verification, grade placement, and token generation', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text('${admissionsList.length} Total Applications', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryGreen)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (admissionsList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
              child: Column(
                children: [
                  const Icon(Icons.inbox_rounded, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  Text('No admission applications submitted yet.', style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('New applications from the public portal will appear here in real time.', style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: admissionsList.length,
              itemBuilder: (context, index) {
                final app = admissionsList[index];
                final isApproved = app.status == ApplicationStatus.approved;
                final isRejected = app.status == ApplicationStatus.rejected;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.cardBorder)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(app.applicationNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isApproved ? AppTheme.primaryGreen : isRejected ? AppTheme.dangerRed : AppTheme.warningOrange).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isApproved ? 'APPROVED' : isRejected ? 'REJECTED' : 'PENDING REVIEW',
                                style: GoogleFonts.outfit(
                                  color: isApproved ? AppTheme.primaryGreen : isRejected ? AppTheme.dangerRed : AppTheme.warningOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Text(
                          'Parent: ${app.primaryParentName} ${app.primaryParentSurname} • ✉️ ${app.primaryParentEmail} • 📞 ${app.primaryParentPhone}',
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Learners (${app.learners.length}): ${app.learners.map((l) => "${l.learnerName} ${l.learnerSurname} (${l.gradeApplyingFor})").join(", ")}',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(app.documentVerified ? Icons.verified_rounded : Icons.pending_actions_rounded, size: 14, color: app.documentVerified ? AppTheme.primaryGreen : AppTheme.warningOrange),
                            const SizedBox(width: 6),
                            Text(
                              app.documentVerified ? 'AI Document Match: 100% Validated' : 'AI Verification Pending',
                              style: GoogleFonts.outfit(fontSize: 11, color: app.documentVerified ? AppTheme.primaryGreen : AppTheme.warningOrange, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text('Reg Token: ${app.registrationToken}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                          ],
                        ),
                        if (!isApproved && !isRejected) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => widget.db.rejectAdmission(app.id, reason: 'Capacity constraints for selected stream.'),
                                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.dangerRed, side: const BorderSide(color: AppTheme.dangerRed)),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => widget.db.approveAdmission(app.id),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
                                child: const Text('Approve & Dispatch Email'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: INSTITUTIONAL ANNOUNCEMENTS
  // ==========================================
  Widget _buildAnnouncementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('School Announcements & Broadcasts', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
                  Text('Broadcast official notices to parents, teachers, and learners', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showBroadcastAnnouncementDialog,
                icon: const Icon(Icons.add_comment_rounded, size: 18),
                label: const Text('New Announcement'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (widget.db.announcements.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.cardBorder)),
              child: Column(
                children: [
                  const Icon(Icons.campaign_outlined, size: 48, color: AppTheme.textMuted),
                  const SizedBox(height: 12),
                  Text('No announcements published yet.', style: GoogleFonts.outfit(color: AppTheme.textMuted, fontSize: 14)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.db.announcements.length,
              itemBuilder: (context, index) {
                final anc = widget.db.announcements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.cardBorder)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(anc.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryNavy)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (anc.priority == AnnouncementPriority.urgent ? AppTheme.dangerRed : AppTheme.primaryNavy).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                anc.priority.name.toUpperCase(),
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: anc.priority == AnnouncementPriority.urgent ? AppTheme.dangerRed : AppTheme.primaryNavy),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(anc.content, style: GoogleFonts.outfit(fontSize: 13, height: 1.4)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Published by: ${anc.authorName}', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
                            Text('Audience: ${anc.audience}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 5: SYSTEM SECURITY & AUDIT LOGS
  // ==========================================
  Widget _buildAuditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Immutable Security Audit Trail', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
          Text('Traceability for all user mutations, admission reviews, and permission changes', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.db.auditLogs.length,
            itemBuilder: (context, index) {
              final log = widget.db.auditLogs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.cardBorder)),
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
                            '${log.timestamp.hour.toString().padLeft(2, "0")}:${log.timestamp.minute.toString().padLeft(2, "0")} • ${log.timestamp.day}/${log.timestamp.month}',
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
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODALS & DIALOGS
  // ==========================================

  void _showAddTeacherDialog() {
    final nameCtrl = TextEditingController();
    final surnameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Teacher@2026!');
    final List<String> selectedSubjectIds = [];
    final List<String> selectedClassIds = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Appoint New Teacher', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Educator Personal Details:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: surnameCtrl,
                          decoration: InputDecoration(labelText: 'Surname', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(labelText: 'Official Email', hintText: 'teacher@thutotech.co.za', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: 'Phone Number', hintText: '084 123 4567', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    decoration: InputDecoration(labelText: 'Initial Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 16),

                  Text('Assign CAPS Subjects:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.db.subjects.map((sub) {
                      final isSelected = selectedSubjectIds.contains(sub.id);
                      return FilterChip(
                        label: Text('${sub.name} (${sub.grade})', style: GoogleFonts.outfit(fontSize: 11)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedSubjectIds.add(sub.id);
                            } else {
                              selectedSubjectIds.remove(sub.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  Text('Assign Classes:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.db.classes.map((cls) {
                      final isSelected = selectedClassIds.contains(cls.id);
                      return FilterChip(
                        label: Text(cls.name, style: GoogleFonts.outfit(fontSize: 11)),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryNavy.withOpacity(0.2),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedClassIds.add(cls.id);
                            } else {
                              selectedClassIds.remove(cls.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || surnameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required educator details.')));
                  return;
                }
                widget.db.addTeacher(
                  name: nameCtrl.text.trim(),
                  surname: surnameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  password: passCtrl.text.trim(),
                  subjectIds: selectedSubjectIds,
                  classIds: selectedClassIds,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.primaryGreen,
                    content: Text('Teacher ${nameCtrl.text} ${surnameCtrl.text} appointed and assigned successfully!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
              child: const Text('Save & Appoint'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignTeacherDialog(Subject subject) {
    String? selectedTeacherId = subject.teacherId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Assign Teacher to ${subject.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryNavy)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select an authenticated educator from the staff directory:', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 12),
                if (widget.db.teachers.isEmpty)
                  Text('No teachers registered yet. Appoint a teacher first.', style: GoogleFonts.outfit(color: AppTheme.dangerRed, fontSize: 12))
                else
                  DropdownButtonFormField<String>(
                    value: selectedTeacherId,
                    decoration: InputDecoration(
                      labelText: 'Select Educator',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: widget.db.teachers.map((t) {
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text('${t.fullName} ${t.surname} (${t.assignedSubjectIds.length} subjects)'),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedTeacherId = v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: selectedTeacherId == null
                  ? null
                  : () {
                      widget.db.assignTeacherToSubject(subject.id, selectedTeacherId!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.primaryGreen,
                          content: Text('Assigned teacher to ${subject.name} successfully!'),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
              child: const Text('Save Assignment'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBroadcastAnnouncementDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String priority = 'Normal';
    final List<String> targetRoles = ['All'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Broadcast Institutional Announcement', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryNavy)),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(labelText: 'Title', hintText: 'Term 1 Final Examination Timetable', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: 'Announcement Content', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: InputDecoration(labelText: 'Priority Level', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: const [
                    DropdownMenuItem(value: 'Normal', child: Text('Normal Priority')),
                    DropdownMenuItem(value: 'High', child: Text('High Priority')),
                    DropdownMenuItem(value: 'Urgent', child: Text('Urgent Notice')),
                  ],
                  onChanged: (v) => setDialogState(() => priority = v ?? 'Normal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                widget.db.broadcastAnnouncement(
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  priority: priority,
                  targetRoles: targetRoles,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: AppTheme.primaryGreen, content: Text('Announcement broadcasted to ecosystem!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy, foregroundColor: Colors.white),
              child: const Text('Publish Announcement'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete User Account?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.dangerRed)),
        content: Text('Are you sure you want to delete ${user.fullName} (${user.email})? This action will revoke all portal access.', style: GoogleFonts.outfit(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.db.deleteUser(user.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${user.fullName} removed from registry.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.dangerRed;
      case UserRole.principal:
        return AppTheme.purpleAccent;
      case UserRole.teacher:
        return AppTheme.primaryGreen;
      case UserRole.parent:
        return AppTheme.warningOrange;
      case UserRole.learner:
        return AppTheme.infoBlue;
    }
  }
}
