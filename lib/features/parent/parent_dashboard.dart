import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../widgets/custom_widgets.dart';

class ParentDashboard extends StatefulWidget {
  final MockDatabase db;

  const ParentDashboard({super.key, required this.db});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedChildIndex = 0;
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final parent = widget.db.parents.firstWhere(
      (p) => p.userId == widget.db.currentUser?.id,
      orElse: () => widget.db.parents.isNotEmpty ? widget.db.parents.first : Parent(
        id: 'par_tmp',
        userId: widget.db.currentUser?.id ?? '',
        fullName: widget.db.currentUser?.name ?? 'Parent',
        surname: widget.db.currentUser?.surname ?? '',
        phone: '0840000000',
        email: widget.db.currentUser?.email ?? '',
        linkedLearnerIds: widget.db.learners.map((l) => l.id).toList(),
      ),
    );

    final linkedLearners = widget.db.learners.where((l) => parent.linkedLearnerIds.contains(l.id)).toList();

    if (linkedLearners.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.family_restroom_rounded, size: 64, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text('No Authorized Children Linked', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'You currently do not have any registered learners linked to your parent profile.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedChildIndex >= linkedLearners.length) {
      _selectedChildIndex = 0;
    }
    final selectedChild = linkedLearners[_selectedChildIndex];

    // Child-specific records
    final childSubmissions = widget.db.submissions.where((s) => s.learnerId == selectedChild.id).toList();
    final childAttendance = widget.db.attendanceRecords.where((r) => r.learnerId == selectedChild.id).toList();
    final childAchievements = widget.db.achievements.where((a) => a.learnerId == selectedChild.id).toList();
    final childTasks = widget.db.assignments.where((a) => a.className == selectedChild.className).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Parent App Bar & Header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryNavy, AppTheme.secondaryNavy],
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
                          child: Text(
                            parent.fullName.isNotEmpty ? parent.fullName[0] : 'P',
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parent Portal',
                                style: GoogleFonts.outfit(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                              Text(
                                '${parent.fullName} ${parent.surname}',
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Connected Learner Academic & Well-being Hub',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION: CHILD SELECTOR (Requirement: Support multiple children)
                  Text(
                    'SELECT CHILD TO MONITOR',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(linkedLearners.length, (index) {
                        final child = linkedLearners[index];
                        final isSelected = _selectedChildIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () => setState(() => _selectedChildIndex = index),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryNavy : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryGreen : AppTheme.cardBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
                                    child: Text(
                                      child.fullName[0],
                                      style: GoogleFonts.outfit(
                                        color: isSelected ? Colors.white : AppTheme.primaryNavy,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        child.completeName,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : AppTheme.textDark,
                                        ),
                                      ),
                                      Text(
                                        '${child.grade} • ${child.className}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: isSelected ? AppTheme.accentGreen : AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 18),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AUTOMATED PROACTIVE INTELLIGENCE FEED
                  if (selectedChild.overallAverage >= 80)
                    InsightCard(
                      title: 'Academic Excellence Detected',
                      message: '${selectedChild.fullName} is performing strongly with an overall aggregate of ${selectedChild.overallAverage}%.',
                      icon: Icons.star_rounded,
                      color: AppTheme.primaryGreen,
                    ),

                  if (selectedChild.attendancePercentage < 90)
                    InsightCard(
                      title: 'Attendance Concern Threshold',
                      message: '${selectedChild.fullName}\'s attendance is at ${selectedChild.attendancePercentage}%. Please ensure regular class attendance.',
                      icon: Icons.warning_amber_rounded,
                      color: AppTheme.dangerRed,
                    ),

                  const SizedBox(height: 12),

                  // STATS SUMMARY CARDS (Dynamic calculations)
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Overall Average',
                          value: '${selectedChild.overallAverage}%',
                          subtitle: selectedChild.overallAverage >= 75 ? 'Top Quartile' : 'Satisfactory',
                          icon: Icons.analytics_rounded,
                          iconColor: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Attendance',
                          value: '${selectedChild.attendancePercentage}%',
                          subtitle: '${childAttendance.length} Recorded Days',
                          icon: Icons.fact_check_rounded,
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
                          title: 'Active Tasks',
                          value: '${childTasks.length}',
                          subtitle: '${childTasks.where((t) => t.dueDate.isAfter(DateTime.now())).length} Pending Deadlines',
                          icon: Icons.assignment_rounded,
                          iconColor: AppTheme.warningOrange,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Achievements',
                          value: '${childAchievements.length}',
                          subtitle: 'Earned Badges',
                          icon: Icons.emoji_events_rounded,
                          iconColor: AppTheme.purpleAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // TABS: ACADEMIC TASKS / RECENT RESULTS / ATTENDANCE / SCHOOL NEWS
                  DefaultTabController(
                    length: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          labelColor: AppTheme.primaryNavy,
                          indicatorColor: AppTheme.primaryGreen,
                          indicatorWeight: 3,
                          isScrollable: true,
                          tabs: const [
                            Tab(text: 'Upcoming Tasks'),
                            Tab(text: 'Recent Marks'),
                            Tab(text: 'Attendance Log'),
                            Tab(text: 'School News'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 380,
                          child: TabBarView(
                            children: [
                              // 1. UPCOMING TASKS
                              _buildTasksList(childTasks, childSubmissions),
                              // 2. RECENT MARKS
                              _buildMarksList(childSubmissions),
                              // 3. ATTENDANCE LOG
                              _buildAttendanceList(childAttendance),
                              // 4. SCHOOL NEWS
                              _buildSchoolNews(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Assignment> tasks, List<Submission> submissions) {
    if (tasks.isEmpty) {
      return Center(
        child: Text('No active assignments found.', style: GoogleFonts.outfit(color: AppTheme.textMuted)),
      );
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (ctx, i) {
        final task = tasks[i];
        final sub = submissions.firstWhere((s) => s.assignmentId == task.id, orElse: () => Submission(id: '', assignmentId: task.id, learnerId: '', learnerName: ''));
        final isSubmitted = sub.status == SubmissionStatus.submitted || sub.status == SubmissionStatus.marked;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSubmitted ? AppTheme.primaryGreen.withOpacity(0.15) : AppTheme.warningOrange.withOpacity(0.15),
              child: Icon(
                isSubmitted ? Icons.check_circle_outline : Icons.pending_actions_rounded,
                color: isSubmitted ? AppTheme.primaryGreen : AppTheme.warningOrange,
              ),
            ),
            title: Text(task.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${task.subjectName} • Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Text(
                  isSubmitted ? 'Status: SUBMITTED' : 'Status: PENDING SUBMISSION',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSubmitted ? AppTheme.primaryGreen : AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
            trailing: isSubmitted && sub.mark != null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(8)),
                    child: Text('${sub.mark}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildMarksList(List<Submission> submissions) {
    final marked = submissions.where((s) => s.mark != null).toList();
    if (marked.isEmpty) {
      return Center(child: Text('No graded assessments yet.', style: GoogleFonts.outfit(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      itemCount: marked.length,
      itemBuilder: (ctx, i) {
        final sub = marked[i];
        final asg = widget.db.assignments.firstWhere((a) => a.id == sub.assignmentId, orElse: () => widget.db.assignments.first);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(asg.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (sub.mark ?? 0) >= 80 ? AppTheme.primaryGreen : AppTheme.secondaryNavy,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${sub.mark}%', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(asg.subjectName, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                if (sub.feedback != null && sub.feedback!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text('Teacher Feedback: "${sub.feedback}"', style: GoogleFonts.outfit(fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList(List<AttendanceRecord> attendance) {
    if (attendance.isEmpty) {
      return Center(child: Text('No attendance records logged.', style: GoogleFonts.outfit(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      itemCount: attendance.length,
      itemBuilder: (ctx, i) {
        final rec = attendance[i];
        final isPresent = rec.status == AttendanceStatus.present;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isPresent ? AppTheme.primaryGreen : AppTheme.dangerRed,
            ),
            title: Text('${rec.date.day}/${rec.date.month}/${rec.date.year}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Status: ${rec.status.name.toUpperCase()}${rec.reason != null ? " (${rec.reason})" : ""}',
              style: GoogleFonts.outfit(fontSize: 12, color: isPresent ? AppTheme.primaryGreen : AppTheme.dangerRed),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSchoolNews() {
    return ListView.builder(
      itemCount: widget.db.announcements.length,
      itemBuilder: (ctx, i) {
        final anc = widget.db.announcements[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(anc.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy)),
                    ),
                    if (anc.priority == AnnouncementPriority.high)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.dangerRed.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('HIGH PRIORITY', style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.dangerRed, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(anc.content, style: GoogleFonts.outfit(fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Text('Published by ${anc.authorName} • Audience: ${anc.audience}', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        );
      },
    );
  }
}
