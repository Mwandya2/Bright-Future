import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/course.dart';
import '../../../data/models/enums.dart';
import '../../../providers/course_provider.dart';
import '../../../routes.dart';
import '../../widgets/course_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/skeletons.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, this.embedded = false});

  /// True when hosted inside the bottom-navigation shell (hides the back arrow).
  final bool embedded;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final CourseProvider p = context.read<CourseProvider>();
      if (!p.loadedOnce) p.loadCatalogue();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CourseProvider provider = context.watch<CourseProvider>();
    final List<Course> visible = provider.visibleCourses;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Courses'),
        actions: <Widget>[
          IconButton(
            tooltip: 'My courses',
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.myCourses),
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _search,
              onChanged: provider.setSearch,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: context.inkColor),
              decoration: InputDecoration(
                hintText: 'Search courses, topics or instructors',
                hintStyle: TextStyle(color: context.mutedColor, fontSize: 14.5),
                prefixIcon: Icon(Icons.search_rounded, color: context.mutedColor),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _search.clear();
                          provider.setSearch('');
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: context.softCanvas,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: context.hairlineColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: context.hairlineColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: <Widget>[
                _FilterChip(
                  label: 'All',
                  selected: provider.category == null,
                  onTap: () => provider.setCategory(null),
                ),
                ...CourseCategories.keys.map(
                  (String key) => _FilterChip(
                    label: CourseCategories.label(key),
                    selected: provider.category == key,
                    onTap: () => provider.setCategory(key),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _body(context, provider, visible),
          ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    CourseProvider provider,
    List<Course> visible,
  ) {
    if (provider.loading && provider.courses.isEmpty) {
      return const SkeletonList(count: 3, itemHeight: 120);
    }
    if (provider.error != null && provider.courses.isEmpty) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => provider.loadCatalogue(),
      );
    }
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No courses found',
        message: provider.search.isEmpty
            ? 'There are no published courses in this category yet.'
            : 'Nothing matched "${provider.search}". Try a different search.',
        actionLabel: 'Clear filters',
        onAction: () {
          _search.clear();
          provider.setSearch('');
          provider.setCategory(null);
          setState(() {});
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCatalogue(refresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemCount: visible.length,
        itemBuilder: (BuildContext context, int i) {
          final Course course = visible[i];
          return CourseCard(
            course: course,
            enrollment: provider.enrollmentFor(course.id),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CourseDetailScreen(course: course),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? AppColors.primary
            : (dark ? AppColors.darkSurfaceElevated : AppColors.canvasSoft),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.primary : context.hairlineColor,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : context.bodyColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
