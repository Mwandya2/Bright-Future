import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/course.dart';
import '../../../data/models/enrollment.dart';
import '../../../data/models/enums.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/gradient_cover.dart';
import '../../widgets/info_row.dart';
import '../../widgets/status_chip.dart';
import '../payment/checkout_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.course});

  final Course course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _busy = false;
  double? _draftProgress;

  Course get course => widget.course;

  Future<void> _enrol() async {
    final AuthProvider auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) {
      AppSnack.info(context, 'Please sign in to enrol.');
      return;
    }

    // Administrators run the hub and are not charged for its courses - they
    // need to enrol to review content. The backend applies the same rule, so
    // this is a matching UI shortcut rather than the thing enforcing it.
    if (!course.isFree && !auth.isAdmin) {
      final bool? paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => CheckoutScreen(course: course),
        ),
      );
      if (paid != true) return;
      if (!mounted) return;
    }

    setState(() => _busy = true);
    final String? error =
        await context.read<CourseProvider>().enroll(course.id);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error == null) {
      AppSnack.success(context, 'You are enrolled in ${course.title}.');
    } else {
      AppSnack.error(context, error);
    }
  }

  Future<void> _saveProgress(Enrollment enrollment) async {
    final int value = (_draftProgress ?? enrollment.progress.toDouble()).round();
    setState(() => _busy = true);
    final String? error = await context
        .read<CourseProvider>()
        .setProgress(enrollment.id, value);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _draftProgress = null;
    });
    if (error == null) {
      AppSnack.success(context, 'Progress saved at $value%.');
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CourseProvider provider = context.watch<CourseProvider>();
    final Enrollment? enrollment = provider.enrollmentFor(course.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            actions: <Widget>[
              IconButton(
                tooltip: 'Copy link',
                icon: const Icon(Icons.link_rounded),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: '${AppConfig.websiteUrl}/courses/${course.slug}',
                    ),
                  );
                  if (!context.mounted) return;
                  AppSnack.success(context, 'Course link copied.');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GradientCover(
                gradientKey: course.coverGradient,
                height: 220,
                radius: 0,
                icon: Icons.school_outlined,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      StatusChip.level(course.level),
                      StatusChip(
                        label: course.categoryLabel,
                        color: AppColors.primary,
                        dense: true,
                      ),
                      if (enrollment != null)
                        StatusChip.enrollment(enrollment.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      height: 1.2,
                      color: context.inkColor,
                    ),
                  ),
                  if ((course.summary ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      course.summary!,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: context.bodyColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        InfoRow(
                          label: 'Price',
                          value: Fmt.price(course.price),
                          icon: Icons.sell_outlined,
                        ),
                        InfoRow(
                          label: 'Duration',
                          value: course.durationLabel,
                          icon: Icons.schedule_rounded,
                        ),
                        InfoRow(
                          label: 'Level',
                          value: course.level.label,
                          icon: Icons.signal_cellular_alt_rounded,
                        ),
                        InfoRow(
                          label: 'Instructor',
                          value: course.instructorName ?? 'Bright Future team',
                          icon: Icons.person_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                  if ((course.description ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: 24),
                    Text(
                      'About this course',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.inkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description!,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.65,
                        color: context.bodyColor,
                      ),
                    ),
                  ],
                  if (enrollment != null) ...<Widget>[
                    const SizedBox(height: 24),
                    Text(
                      'Your progress',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.inkColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Move the slider as you work through the material. Your '
                      'instructor sees the same number.',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: context.mutedColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _draftProgress ?? enrollment.progress.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label:
                          '${(_draftProgress ?? enrollment.progress.toDouble()).round()}%',
                      onChanged: (double v) =>
                          setState(() => _draftProgress = v),
                    ),
                    if (_draftProgress != null &&
                        _draftProgress!.round() != enrollment.progress)
                      AppButton(
                        label:
                            'Save progress at ${_draftProgress!.round()}%',
                        busy: _busy,
                        compact: true,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => _saveProgress(enrollment),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        decoration: BoxDecoration(
          color: context.cardColor,
          border: Border(top: BorderSide(color: context.hairlineColor)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    course.isFree ? 'Free course' : 'Total',
                    style: TextStyle(fontSize: 11.5, color: context.mutedColor),
                  ),
                  Text(
                    Fmt.price(course.price),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.inkColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: enrollment != null
                    ? const AppButton(
                        label: 'You are enrolled',
                        icon: Icons.check_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: null,
                      )
                    : AppButton(
                        label: course.isFree ? 'Enrol for free' : 'Enrol now',
                        busy: _busy,
                        onPressed: _enrol,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
