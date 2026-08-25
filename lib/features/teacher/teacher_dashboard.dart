import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validation/input_validators.dart';
import '../../data/mock_database.dart';
import '../../models/models.dart';
import '../../widgets/custom_widgets.dart';

class TeacherDashboard extends StatefulWidget {
  final MockDatabase db;

  const TeacherDashboard({super.key, required this.db});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  void _openCreateAssignmentModal() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final marksCtrl = TextEditingController(text: '100');
    String selectedSubject = widget.db.subjects.first.id;
    String selectedClass = widget.db.classes.first.id;
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 5));

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
                    Text('Create New Assignment', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                ValidatedTextField(
                  controller: titleCtrl,
                  label: 'Assignment Title',
                  hint: 'e.g. Euclidean Geometry Problem Set',
                  prefixIcon: Icons.title_rounded,
                ),
                ValidatedTextField(
                  controller: descCtrl,
                  label: 'Instructions & Description',
                  hint: 'Instructions for learners...',
                  maxLines: 3,
                  prefixIcon: Icons.description_outlined,
                ),
                ValidatedTextField(
                  controller: marksCtrl,
                  label: 'Maximum Marks',
                  hint: '100',
                  dataType: InputDataType.numberOnly,
                  prefixIcon: Icons.score_rounded,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSubject,
                        decoration: const InputDecoration(labelText: 'Subject'),
                        items: widget.db.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                        onChanged: (v) => setModalState(() => selectedSubject = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: const InputDecoration(labelText: 'Class'),
                        items: widget.db.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (v) => setModalState(() => selectedClass = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) return;
                      final maxM = double.tryParse(marksCtrl.text) ?? 100;
                      widget.db.createAssignment(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        subjectId: selectedSubject,
                        classId: selectedClass,
                        dueDate: selectedDueDate,
                        maxMarks: maxM,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Assignment published! Enrolled learners and parents notified.', style: GoogleFonts.outfit()),
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Publish Assignment & Dispatch Notifications'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMarkingModal(Submission submission) {
    final markCtrl = TextEditingController(text: submission.mark?.toString() ?? '');
    final feedbackCtrl = TextEditingController(text: submission.feedback ?? '');
    final assignment = widget.db.assignments.firstWhere((a) => a.id == submission.assignmentId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Grade Submission - ${submission.learnerName}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${assignment.title} (Max: ${assignment.maxMarks} marks)', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              ValidatedTextField(
                controller: markCtrl,
                label: 'Awarded Mark (0 - ${assignment.maxMarks})',
                hint: 'e.g. 85',
                dataType: InputDataType.numberOnly,
                minVal: 0,
                maxVal: assignment.maxMarks,
                prefixIcon: Icons.grade_rounded,
              ),
              ValidatedTextField(
                controller: feedbackCtrl,
                label: 'Teacher Constructive Feedback',
                hint: 'Comments on learner performance...',
                maxLines: 3,
                prefixIcon: Icons.comment_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final markVal = double.tryParse(markCtrl.text);
              if (markVal == null || markVal < 0 || markVal > assignment.maxMarks) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mark must be between 0 and ${assignment.maxMarks}.', style: GoogleFonts.outfit()), backgroundColor: AppTheme.dangerRed),
                );
                return;
              }
              widget.db.gradeSubmission(
                submissionId: submission.id,
                mark: markVal,
                feedback: feedbackCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mark stored! Averages recalculated & parent notified.', style: GoogleFonts.outfit()),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            child: const Text('Save & Trigger Automation'),
          ),
        ],
      ),
    );
  }

  void _openAttendanceRegister(SchoolClass schoolClass) {
    final Map<String, AttendanceStatus> attendanceState = {};
    for (final learnerId in schoolClass.learnerIds) {
      attendanceState[learnerId] = AttendanceStatus.present;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Daily Attendance Register • ${schoolClass.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: schoolClass.learnerIds.map((lId) {
                final learner = widget.db.learners.firstWhere((l) => l.id == lId);
                final currentStatus = attendanceState[lId] ?? AttendanceStatus.present;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(learner.completeName, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(learner.idNumber, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textMuted)),
                  trailing: DropdownButton<AttendanceStatus>(
                    value: currentStatus,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: AttendanceStatus.present, child: Text('Present', style: TextStyle(color: AppTheme.primaryGreen))),
                      DropdownMenuItem(value: AttendanceStatus.absent, child: Text('Absent', style: TextStyle(color: AppTheme.dangerRed))),
                      DropdownMenuItem(value: AttendanceStatus.late, child: Text('Late', style: TextStyle(color: AppTheme.warningOrange))),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => attendanceState[lId] = v);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                widget.db.recordClassAttendance(schoolClass.id, attendanceState);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Attendance recorded & parent alerts dispatched.', style: GoogleFonts.outfit()),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              child: const Text('Submit Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingSubmissions = widget.db.submissions.where((s) => s.status == SubmissionStatus.submitted || s.status == SubmissionStatus.late).toList();

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
                    colors: [AppTheme.primaryNavy, Color(0xFF133E60)],
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
                          child: const Icon(Icons.person_search_rounded, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TEACHER WORKSPACE',
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
                      'Department of Mathematics & Natural Sciences',
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
                  // QUICK ACTIONS
                  const SectionHeader(title: 'Teacher Quick Actions', subtitle: 'Trigger automated workflows directly'),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openCreateAssignmentModal,
                          icon: const Icon(Icons.add_task_rounded, size: 16),
                          label: const Text('Create Task'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (widget.db.classes.isNotEmpty) {
                              _openAttendanceRegister(widget.db.classes.first);
                            }
                          },
                          icon: const Icon(Icons.checklist_rounded, size: 16),
                          label: const Text('Mark Attendance'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // WORKLOAD METRICS
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Assigned Classes',
                          value: '${widget.db.classes.length}',
                          subtitle: 'Active Cohorts',
                          icon: Icons.groups_rounded,
                          iconColor: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Pending Marking',
                          value: '${pendingSubmissions.length}',
                          subtitle: 'Requires Evaluation',
                          icon: Icons.rate_review_rounded,
                          iconColor: pendingSubmissions.isNotEmpty ? AppTheme.dangerRed : AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // SUBMISSIONS TO MARK
                  SectionHeader(
                    title: 'Work Requiring Marking',
                    subtitle: 'Enter marks to automatically update learner and school statistics',
                    trailing: Text('${pendingSubmissions.length} Pending', style: GoogleFonts.outfit(color: AppTheme.dangerRed, fontWeight: FontWeight.bold)),
                  ),
                  if (pendingSubmissions.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.done_all_rounded, color: AppTheme.primaryGreen, size: 36),
                              const SizedBox(height: 8),
                              Text('All submissions marked!', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              Text('There are currently no unmarked learner submissions.', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...pendingSubmissions.map((sub) {
                      final asg = widget.db.assignments.firstWhere((a) => a.id == sub.assignmentId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.warningOrange.withOpacity(0.15),
                            child: const Icon(Icons.assignment_late_rounded, color: AppTheme.warningOrange),
                          ),
                          title: Text('${sub.learnerName} - ${asg.title}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('Submitted: ${sub.submittedAt != null ? "${sub.submittedAt!.hour}:${sub.submittedAt!.minute.toString().padLeft(2, '0')}" : "Pending"} • ${asg.className}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                          trailing: ElevatedButton(
                            onPressed: () => _openMarkingModal(sub),
                            child: const Text('Grade'),
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 24),

                  // MY CLASSES LIST
                  const SectionHeader(title: 'My Assigned Classes', subtitle: 'View enrolled learners & registers'),
                  ...widget.db.classes.map((cls) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryNavy.withOpacity(0.1),
                          child: Text(cls.name.substring(0, 2), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                        ),
                        title: Text(cls.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        subtitle: Text('${cls.learnerIds.length} Enrolled Learners • CAPS Grade 10', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textMuted)),
                        trailing: OutlinedButton(
                          onPressed: () => _openAttendanceRegister(cls),
                          child: const Text('Attendance'),
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
