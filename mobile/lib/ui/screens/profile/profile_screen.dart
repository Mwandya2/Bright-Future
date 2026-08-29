import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/print_order_provider.dart';
import '../../../routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final CourseProvider courses = context.watch<CourseProvider>();
    final BookingProvider bookings = context.watch<BookingProvider>();
    final PrintOrderProvider orders = context.watch<PrintOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        children: <Widget>[
          AppCard(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    UserAvatar(name: auth.user?.displayName, size: 58),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            auth.user?.displayName ?? 'Guest',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: context.inkColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            auth.user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.mutedColor,
                            ),
                          ),
                          const SizedBox(height: 7),
                          StatusChip(
                            label: auth.user?.role.label ?? 'Student',
                            color: auth.isAdmin
                                ? AppColors.ruby
                                : AppColors.primary,
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (auth.user?.phone != null &&
                    auth.user!.phone!.isNotEmpty) ...<Widget>[
                  const Divider(height: 26),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.phone_outlined,
                        size: 16,
                        color: context.mutedColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        auth.user!.phone!,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: context.bodyColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Joined ${Fmt.date(auth.user?.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniStat(
                  label: 'Courses',
                  value: '${courses.enrollments.length}',
                  accent: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Bookings',
                  value: '${bookings.bookings.length}',
                  accent: AppColors.mint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Print jobs',
                  value: '${orders.orders.length}',
                  accent: AppColors.peach,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          if (auth.isAdmin) ...<Widget>[
            _MenuTile(
              icon: Icons.shield_outlined,
              label: 'Hub administration',
              subtitle: 'Users, courses, bookings, orders, messages',
              accent: AppColors.ruby,
              onTap: () => Navigator.of(context).pushNamed(Routes.admin),
            ),
            const SizedBox(height: 10),
          ],

          _MenuTile(
            icon: Icons.school_outlined,
            label: 'My courses',
            onTap: () => Navigator.of(context).pushNamed(Routes.myCourses),
          ),
          _MenuTile(
            icon: Icons.event_seat_outlined,
            label: 'My lab bookings',
            onTap: () => Navigator.of(context).pushNamed(Routes.bookings),
          ),
          _MenuTile(
            icon: Icons.print_outlined,
            label: 'My print orders',
            onTap: () => Navigator.of(context).pushNamed(Routes.printing),
          ),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.notifications),
          ),
          const SizedBox(height: 14),
          _MenuTile(
            icon: Icons.apps_rounded,
            label: 'Our ecosystem',
            onTap: () => Navigator.of(context).pushNamed(Routes.ecosystem),
          ),
          _MenuTile(
            icon: Icons.mail_outline_rounded,
            label: 'Contact the hub',
            onTap: () => Navigator.of(context).pushNamed(Routes.contact),
          ),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            label: 'About Bright Future',
            onTap: () => Navigator.of(context).pushNamed(Routes.about),
          ),
          _MenuTile(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.of(context).pushNamed(Routes.settings),
          ),
          const SizedBox(height: 22),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            accent: AppColors.error,
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your saved offline data will be cleared from this device.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay signed in'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (yes != true || !context.mounted) return;
    context.read<CourseProvider>().reset();
    context.read<BookingProvider>().reset();
    context.read<PrintOrderProvider>().reset();
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.accent,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tone = accent ?? AppColors.primary;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: <Widget>[
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.softBg(tone, dark: context.isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: accent ?? context.inkColor,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style:
                        TextStyle(fontSize: 12.5, color: context.mutedColor),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.mutedColor,
          ),
        ],
      ),
    );
  }
}
