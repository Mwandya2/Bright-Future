import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/course.dart';
import '../../../data/models/enums.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_chip.dart';
import 'admin_course_form_screen.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});

  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCourses();
    });
  }

  Future<void> _openForm({Course? course}) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AdminCourseFormScreen(course: course),
      ),
    );
    if (saved == true && mounted) {
      await context.read<AdminProvider>().loadCourses(refresh: true);
    }
  }

  Future<void> _confirmDelete(Course course) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete this course?'),
        content: Text(
          '"${course.title}" will be removed permanently. Existing enrolments '
          'may be affected.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (yes != true || !mounted) return;
    final String? error =
        await context.read<AdminProvider>().deleteCourse(course.id);
    if (!mounted) return;
    if (error == null) {
      AppSnack.success(context, 'Course deleted.');
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AdminProvider admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Course catalogue')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New course'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: admin.loading && admin.allCourses.isEmpty
          ? const SkeletonList(count: 4)
          : admin.error != null && admin.allCourses.isEmpty
              ? ErrorView(
                  message: admin.error!,
                  onRetry: () => admin.loadCourses(),
                )
              : admin.allCourses.isEmpty
                  ? EmptyState(
                      icon: Icons.school_outlined,
                      title: 'No courses yet',
                      message: 'Create the first course in the catalogue.',
                      actionLabel: 'New course',
                      onAction: () => _openForm(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => admin.loadCourses(refresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                        itemCount: admin.allCourses.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Course c = admin.allCourses[i];
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () => _openForm(course: c),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        c.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: context.inkColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusChip(
                                      label: c.isPublished
                                          ? 'Published'
                                          : 'Draft',
                                      color: c.isPublished
                                          ? AppColors.success
                                          : AppColors.muted,
                                      dense: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${c.categoryLabel} - ${c.level.label} - '
                                  '${Fmt.price(c.price)} - ${c.durationLabel}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: context.mutedColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: <Widget>[
                                    TextButton.icon(
                                      onPressed: () async {
                                        final String? error = await context
                                            .read<AdminProvider>()
                                            .togglePublish(c);
                                        if (!context.mounted) return;
                                        if (error != null) {
                                          AppSnack.error(context, error);
                                        }
                                      },
                                      icon: Icon(
                                        c.isPublished
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 16,
                                      ),
                                      label: Text(
                                        c.isPublished ? 'Unpublish' : 'Publish',
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () => _confirmDelete(c),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Delete'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
