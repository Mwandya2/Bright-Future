import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/course.dart';
import '../../../data/models/enrollment.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/lab_booking.dart';
import '../../../data/models/print_order.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/print_order_provider.dart';
import '../../../routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_avatar.dart';
import '../courses/course_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenTab});

  /// Lets the dashboard jump to another bottom-navigation tab.
  final ValueChanged<int>? onOpenTab;

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final CourseProvider courses = context.watch<CourseProvider>();
    final BookingProvider bookings = context.watch<BookingProvider>();
    final PrintOrderProvider orders = context.watch<PrintOrderProvider>();

    final List<Enrollment> learning = courses.activeEnrollments;
    final List<LabBooking> upcoming = bookings.upcoming;
    final List<PrintOrder> activeOrders = orders.active;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await courses.loadAll(refresh: true);
            await bookings.load(refresh: true);
            await orders.load(refresh: true);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
            children: <Widget>[
              const OfflineBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: <Widget>[
                    UserAvatar(name: auth.user?.displayName, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _greeting(),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: context.mutedColor,
                            ),
                          ),
                          Text(
                            auth.user?.firstName ?? 'Welcome',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: context.inkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(Routes.notifications),
                      icon: const Icon(Icons.notifications_none_rounded),
                      tooltip: 'Notifications',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Quick actions ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.65,
                  children: <Widget>[
                    _QuickAction(
                      icon: Icons.desktop_windows_outlined,
                      label: 'Book a station',
                      accent: AppColors.mint,
                      onTap: () => Navigator.of(context)
                          .pushNamed(Routes.newBooking),
                    ),
                    _QuickAction(
                      icon: Icons.print_outlined,
                      label: 'Print something',
                      accent: AppColors.peach,
                      onTap: () => Navigator.of(context)
                          .pushNamed(Routes.newPrintOrder),
                    ),
                    _QuickAction(
                      icon: Icons.school_outlined,
                      label: 'Browse courses',
                      accent: AppColors.primary,
                      onTap: () => onOpenTab?.call(1),
                    ),
                    _QuickAction(
                      icon: Icons.apps_rounded,
                      label: 'Our ecosystem',
                      accent: AppColors.lavender,
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.ecosystem),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // ── Continue learning ──────────────────────────
              if (learning.isNotEmpty) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(
                    title: 'Continue learning',
                    subtitle: 'Pick up where you left off',
                    actionLabel: 'All',
                    onAction: () =>
                        Navigator.of(context).pushNamed(Routes.myCourses),
                  ),
                ),
                SizedBox(
                  height: 152,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: learning.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (BuildContext context, int i) =>
                        _LearningCard(enrollment: learning[i]),
                  ),
                ),
                const SizedBox(height: 26),
              ],

              // ── Upcoming lab booking ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(
                      title: 'Next in the lab',
                      subtitle: upcoming.isEmpty
                          ? 'No upcoming reservations'
                          : '${upcoming.length} upcoming',
                      actionLabel: 'Book',
                      onAction: () =>
                          Navigator.of(context).pushNamed(Routes.newBooking),
                    ),
                    if (upcoming.isEmpty)
                      AppCard(
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.newBooking),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.event_available_outlined,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Reserve a workstation for study, gaming or '
                                'research.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  color: context.mutedColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _BookingSummary(booking: upcoming.first),
                    const SizedBox(height: 26),

                    // ── Print orders ─────────────────────────
                    SectionHeader(
                      title: 'Printing',
                      subtitle: activeOrders.isEmpty
                          ? 'Nothing in the queue'
                          : '${activeOrders.length} order(s) in progress',
                      actionLabel: 'New',
                      onAction: () => Navigator.of(context)
                          .pushNamed(Routes.newPrintOrder),
                    ),
                    if (activeOrders.isEmpty)
                      AppCard(
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.newPrintOrder),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.description_outlined,
                              color: AppColors.peach,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Documents, posters, banners, business cards '
                                'and photos.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.4,
                                  color: context.mutedColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _OrderSummary(order: activeOrders.first),

                    // ── Admin shortcut ───────────────────────
                    if (auth.isAdmin) ...<Widget>[
                      const SizedBox(height: 26),
                      AppCard(
                        color: AppColors.ink,
                        borderColor: AppColors.ink,
                        onTap: () =>
                            Navigator.of(context).pushNamed(Routes.admin),
                        child: const Row(
                          children: <Widget>[
                            Icon(
                              Icons.shield_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Hub administration',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Users, courses, bookings, orders, messages',
                                    style: TextStyle(
                                      color: AppColors.onDarkSoft,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 26),

                    // ── Featured courses ─────────────────────
                    SectionHeader(
                      title: 'Popular right now',
                      subtitle: 'Fresh from the academy',
                      actionLabel: 'See all',
                      onAction: () => onOpenTab?.call(1),
                    ),
                  ],
                ),
              ),
              if (courses.courses.isNotEmpty)
                SizedBox(
                  height: 128,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount:
                        courses.courses.length > 6 ? 6 : courses.courses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (BuildContext context, int i) =>
                        _MiniCourseCard(course: courses.courses[i]),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppCard(
                    child: Text(
                      courses.loading
                          ? 'Loading the course catalogue...'
                          : 'The catalogue is empty right now. Check back soon.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: context.mutedColor,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  '${AppConfig.longName} - ${AppConfig.tagline}',
                  style: TextStyle(fontSize: 12, color: context.mutedColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColors.softBg(accent, dark: dark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: accent),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: context.inkColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({required this.enrollment});

  final Enrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final Course? course = enrollment.course;
    return SizedBox(
      width: 240,
      child: AppCard(
        onTap: course == null
            ? null
            : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CourseDetailScreen(course: course),
                  ),
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              course?.title ?? 'Course',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: 6),
            StatusChip.enrollment(enrollment.status),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: enrollment.progressFraction,
                minHeight: 6,
                backgroundColor: context.hairlineColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${enrollment.progress}% complete',
              style: TextStyle(fontSize: 12, color: context.mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCourseCard extends StatelessWidget {
  const _MiniCourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: AppCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CourseDetailScreen(course: course),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StatusChip.level(course.level),
            const SizedBox(height: 8),
            Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Fmt.price(course.price),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: context.mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({required this.booking});

  final LabBooking booking;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(Routes.bookings),
      child: Row(
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.softBg(AppColors.mint, dark: context.isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_seat_outlined,
              color: AppColors.mint,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  booking.workstationType.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.inkColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${Fmt.date(booking.bookingDate)} at '
                  '${Fmt.time(booking.startTime)} - '
                  '${booking.durationHours}h',
                  style: TextStyle(fontSize: 12.5, color: context.mutedColor),
                ),
              ],
            ),
          ),
          StatusChip.booking(booking.status),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final PrintOrder order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(Routes.printing),
      child: Row(
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.softBg(AppColors.peach, dark: context.isDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.print_outlined, color: AppColors.peach),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.serviceType.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.inkColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${order.copies} copies - ${Fmt.price(order.estimatedPrice)}',
                  style: TextStyle(fontSize: 12.5, color: context.mutedColor),
                ),
              ],
            ),
          ),
          StatusChip.order(order.status),
        ],
      ),
    );
  }
}
