import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/enrollment.dart';
import '../../../providers/course_provider.dart';
import '../../../routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_chip.dart';
import 'course_detail_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadEnrollments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CourseProvider provider = context.watch<CourseProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My courses'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'In progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: provider.loading && provider.enrollments.isEmpty
            ? const SkeletonList(count: 3)
            : provider.error != null && provider.enrollments.isEmpty
                ? ErrorView(
                    message: provider.error!,
                    onRetry: () => provider.loadEnrollments(),
                  )
                : TabBarView(
                    children: <Widget>[
                      _EnrollmentList(
                        items: provider.activeEnrollments,
                        emptyTitle: 'Nothing in progress',
                        emptyMessage:
                            'Enrol in a course to start building your skills.',
                        onRefresh: () =>
                            provider.loadEnrollments(refresh: true),
                      ),
                      _EnrollmentList(
                        items: provider.completedEnrollments,
                        emptyTitle: 'No completed courses yet',
                        emptyMessage:
                            'Finish a course and it will appear here with your '
                            'certificate.',
                        onRefresh: () =>
                            provider.loadEnrollments(refresh: true),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _EnrollmentList extends StatelessWidget {
  const _EnrollmentList({
    required this.items,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
  });

  final List<Enrollment> items;
  final String emptyTitle;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.school_outlined,
        title: emptyTitle,
        message: emptyMessage,
        actionLabel: 'Browse courses',
        onAction: () => Navigator.of(context).pushNamed(Routes.courses),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int i) {
          final Enrollment e = items[i];
          return AppCard(
            onTap: e.course == null
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CourseDetailScreen(course: e.course!),
                      ),
                    ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        e.course?.title ?? 'Course',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: context.inkColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip.enrollment(e.status),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: e.progressFraction,
                    minHeight: 6,
                    backgroundColor: context.hairlineColor,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${e.progress}% complete',
                  style: TextStyle(fontSize: 12.5, color: context.mutedColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
