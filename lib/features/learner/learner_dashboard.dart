import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../widgets/custom_widgets.dart';

class LearnerDashboard extends StatefulWidget {
  final MockDatabase db;

  const LearnerDashboard({super.key, required this.db});

  @override
  State<LearnerDashboard> createState() => _LearnerDashboardState();
}

class _LearnerDashboardState extends State<LearnerDashboard> {
  @override
  Widget build(BuildContext context) {
    final learner = widget.db.learners.firstWhere(
      (l) => l.userId == widget.db.currentUser?.id,
      orElse: () => widget.db.learners.isNotEmpty ? widget.db.learners.first : Learner(
        id: 'lrn_tmp',
        userId: widget.db.currentUser?.id ?? '',
        idNumber: '0000000000000',
        fullName: widget.db.currentUser?.name ?? 'Learner',
        surname: widget.db.currentUser?.surname ?? '',
        grade: 'Grade 10',
        className: 'Grade 10A',
        schoolId: 'sch_thutotech',
        parentId: 'par_sibusiso',
      ),
    );

    final mySubmissions = widget.db.submissions.where((s) => s.learnerId == learner.id).toList();
    final myAchievements = widget.db.achievements.where((a) => a.learnerId == learner.id).toList();
    final myAssignments = widget.db.assignments.where((a) => a.className == learner.className).toList();

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
                    colors: [AppTheme.secondaryNavy, AppTheme.primaryNavy],
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
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LEARNER PORTAL • ${learner.grade}',
                                style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${learner.fullName} ${learner.surname}',
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Class: ${learner.className} • ID: ${learner.idNumber}',
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
                  // KPI CARDS
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Overall Average',
                          value: '${learner.overallAverage}%',
                          subtitle: 'Calculated Aggregate',
                          icon: Icons.auto_graph_rounded,
                          iconColor: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Attendance',
                          value: '${learner.attendancePercentage}%',
                          subtitle: 'Term 3 Attendance',
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
                          title: 'Assignments',
                          value: '${myAssignments.length}',
                          subtitle: '${mySubmissions.where((s) => s.status == SubmissionStatus.submitted || s.status == SubmissionStatus.marked).length} Submitted',
                          icon: Icons.assignment_turned_in_rounded,
                          iconColor: AppTheme.warningOrange,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Achievements',
                          value: '${myAchievements.length}',
                          subtitle: 'Badges Earned',
                          icon: Icons.military_tech_rounded,
                          iconColor: AppTheme.purpleAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // TODAY'S TIMETABLE
                  const SectionHeader(title: "Today's Schedule & Classes", subtitle: 'South African CAPS Curriculum Timetable'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildTimetableRow('08:00 - 09:00', 'Mathematics', 'Room 101 • Mr. Dlamini', Icons.calculate_rounded),
                          const Divider(),
                          _buildTimetableRow('09:05 - 10:05', 'Physical Sciences', 'Science Lab A • Mr. Dlamini', Icons.science_rounded),
                          const Divider(),
                          _buildTimetableRow('10:30 - 11:30', 'English FAL', 'Room 104 • Ms. Nkosi', Icons.menu_book_rounded),
                          const Divider(),
                          _buildTimetableRow('11:35 - 12:35', 'Life Sciences', 'Biology Lab • Mr. Maseko', Icons.eco_rounded),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ACTIVE ASSIGNMENTS WITH SUBMISSION ACTION
                  const SectionHeader(title: 'Active Assignments & Submissions', subtitle: 'Submit homework & view teacher grades'),
                  ...myAssignments.map((task) {
                    final submission = mySubmissions.firstWhere(
                      (s) => s.assignmentId == task.id,
                      orElse: () => Submission(id: '', assignmentId: task.id, learnerId: learner.id, learnerName: learner.completeName),
                    );
                    final isSubmitted = submission.status == SubmissionStatus.submitted || submission.status == SubmissionStatus.marked;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(task.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
                                if (submission.mark != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(8)),
                                    child: Text('${submission.mark}%', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${task.subjectName} • Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                            const SizedBox(height: 8),
                            Text(task.description, style: GoogleFonts.outfit(fontSize: 13, height: 1.3)),
                            const SizedBox(height: 12),
                            if (!isSubmitted)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    widget.db.submitLearnerAssignment(task.id, learner.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Assignment submitted successfully! Teacher notified.', style: GoogleFonts.outfit()),
                                        backgroundColor: AppTheme.primaryGreen,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                                  label: const Text('Submit Solution'),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppTheme.lightGreen, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        submission.status == SubmissionStatus.marked
                                            ? 'Graded: ${submission.feedback ?? "Marked by teacher"}'
                                            : 'Submitted • Awaiting Teacher Evaluation',
                                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.primaryNavy, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // ACHIEVEMENTS
                  const SectionHeader(title: 'Earned Achievements & Badges', subtitle: 'Automated milestone awards'),
                  ...myAchievements.map((ach) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.purpleAccent.withOpacity(0.15),
                          child: Icon(ach.icon, color: AppTheme.purpleAccent),
                        ),
                        title: Text(ach.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(ach.description, style: GoogleFonts.outfit(fontSize: 12)),
                        trailing: Text(
                          '${ach.awardedAt.day}/${ach.awardedAt.month}',
                          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted),
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

  Widget _buildTimetableRow(String time, String subject, String room, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryNavy.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: AppTheme.primaryNavy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(room, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondaryNavy)),
        ],
      ),
    );
  }
}
