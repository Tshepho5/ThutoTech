import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation/input_validators.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../widgets/custom_widgets.dart';

class PrincipalDashboard extends StatefulWidget {
  final MockDatabase db;

  const PrincipalDashboard({super.key, required this.db});

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  void _openAnnouncementComposer() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedAudience = 'PARENTS';
    AnnouncementPriority priority = AnnouncementPriority.normal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Publish School Announcement', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                ValidatedTextField(
                  controller: titleCtrl,
                  label: 'Announcement Title',
                  hint: 'e.g. End of Term Examination Schedule',
                  prefixIcon: Icons.campaign_rounded,
                ),
                ValidatedTextField(
                  controller: contentCtrl,
                  label: 'Official Message Content',
                  hint: 'Enter announcement details...',
                  maxLines: 4,
                  prefixIcon: Icons.article_outlined,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedAudience,
                        decoration: const InputDecoration(labelText: 'Target Audience'),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('Entire School Community')),
                          DropdownMenuItem(value: 'PARENTS', child: Text('Parents Only')),
                          DropdownMenuItem(value: 'LEARNERS', child: Text('Learners Only')),
                          DropdownMenuItem(value: 'TEACHERS', child: Text('Teaching Staff Only')),
                        ],
                        onChanged: (v) => setModalState(() => selectedAudience = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<AnnouncementPriority>(
                        value: priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: const [
                          DropdownMenuItem(value: AnnouncementPriority.normal, child: Text('Normal')),
                          DropdownMenuItem(value: AnnouncementPriority.high, child: Text('High')),
                          DropdownMenuItem(value: AnnouncementPriority.urgent, child: Text('Urgent')),
                        ],
                        onChanged: (v) => setModalState(() => priority = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
                      widget.db.publishAnnouncement(
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        audience: selectedAudience,
                        priority: priority,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Announcement published to $selectedAudience!', style: GoogleFonts.outfit()),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Broadcast Announcement'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAdmissionDetails(AdmissionApplication app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.school_rounded, color: AppTheme.primaryNavy),
            const SizedBox(width: 8),
            Expanded(child: Text('Review Admission: ${app.applicationNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Learner Name', '${app.learnerName} ${app.learnerSurname}'),
              _buildInfoRow('Learner ID', app.learnerIdNumber),
              _buildInfoRow('Applying For', app.gradeApplyingFor),
              _buildInfoRow('Previous School', app.previousSchool),
              const Divider(),
              _buildInfoRow('Primary Parent', '${app.primaryParentName} ${app.primaryParentSurname}'),
              _buildInfoRow('Parent Phone', app.primaryParentPhone),
              _buildInfoRow('Parent Email', app.primaryParentEmail),
              _buildInfoRow('Parent ID', app.primaryParentIdNumber),
              if (app.hasSecondaryParent) ...[
                const Divider(),
                _buildInfoRow('Secondary Parent', '${app.secondaryParentName} ${app.secondaryParentSurname}'),
                _buildInfoRow('Secondary Phone', app.secondaryParentPhone ?? '-'),
                _buildInfoRow('Secondary Email', app.secondaryParentEmail ?? '-'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.db.rejectAdmission(app.id);
              Navigator.pop(ctx);
            },
            child: const Text('Reject', style: TextStyle(color: AppTheme.dangerRed)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.db.approveAdmission(app.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Admission APPROVED! Automated approval email dispatched to ${app.primaryParentEmail} with registration token ${app.registrationToken}.',
                    style: GoogleFonts.outfit(),
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Approve & Dispatch Email'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingAdmissions = widget.db.admissions.where((a) => a.status == ApplicationStatus.submitted || a.status == ApplicationStatus.underReview).toList();

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
                    colors: [Color(0xFF0F172A), AppTheme.primaryNavy],
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
                          child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRINCIPAL COMMAND CENTRE',
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
                      'ThutoTech High Academy • Academic Year 2026',
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
                  // ACTION BAR
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openAnnouncementComposer,
                          icon: const Icon(Icons.campaign_rounded, size: 18),
                          label: const Text('Publish Announcement'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // SCHOOL HEALTH METRICS
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'School Average',
                          value: '${widget.db.schoolAverage}%',
                          subtitle: 'Calculated Aggregate',
                          icon: Icons.trending_up_rounded,
                          iconColor: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'School Attendance',
                          value: '${widget.db.schoolAttendanceRate}%',
                          subtitle: 'Active Compliance',
                          icon: Icons.how_to_reg_rounded,
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
                          title: 'Enrolled Learners',
                          value: '${widget.db.learners.length}',
                          subtitle: 'Active Students',
                          icon: Icons.school_rounded,
                          iconColor: AppTheme.purpleAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Pending Admissions',
                          value: '${pendingAdmissions.length}',
                          subtitle: 'Awaiting Decision',
                          icon: Icons.pending_rounded,
                          iconColor: pendingAdmissions.isNotEmpty ? AppTheme.warningOrange : AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // PENDING ADMISSIONS WORKSPACE
                  SectionHeader(
                    title: 'Admissions Approval Workspace',
                    subtitle: 'Approve prospective parent applications to trigger automated email with token',
                    trailing: Text('${pendingAdmissions.length} In Queue', style: GoogleFonts.outfit(color: AppTheme.warningOrange, fontWeight: FontWeight.bold)),
                  ),

                  if (pendingAdmissions.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 36),
                              const SizedBox(height: 8),
                              Text('No pending admissions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              Text('Use the "Online Admission Application" form to submit new applications.', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...pendingAdmissions.map((adm) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryNavy.withOpacity(0.1),
                            child: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryNavy),
                          ),
                          title: Text('${adm.learnerName} ${adm.learnerSurname} (${adm.gradeApplyingFor})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('Parent: ${adm.primaryParentName} ${adm.primaryParentSurname} • Ref: ${adm.applicationNumber}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                          trailing: ElevatedButton(
                            onPressed: () => _showAdmissionDetails(adm),
                            child: const Text('Review'),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 28),

                  // GRADE & CLASS PERFORMANCE OVERVIEW
                  const SectionHeader(title: 'Class Performance Overview', subtitle: 'Live class-level averages & submission monitoring'),
                  ...widget.db.classes.map((cls) {
                    final classLearners = widget.db.learners.where((l) => cls.learnerIds.contains(l.id)).toList();
                    final avg = classLearners.isNotEmpty
                        ? (classLearners.map((l) => l.overallAverage).reduce((a, b) => a + b) / classLearners.length).toStringAsFixed(1)
                        : '0.0';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                          child: Text(cls.name.substring(0, 2), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                        ),
                        title: Text(cls.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        subtitle: Text('${cls.learnerIds.length} Learners • CAPS Grade 10', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppTheme.primaryNavy, borderRadius: BorderRadius.circular(10)),
                          child: Text('Class Avg: $avg%', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
