import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_stats.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_tile.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final AdminProvider admin = context.watch<AdminProvider>();

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Administration')),
        body: const EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Administrators only',
          message: 'This area is limited to hub administrator accounts.',
        ),
      );
    }

    final AdminStats s = admin.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => admin.loadDashboard(refresh: true),
          ),
        ],
      ),
      body: admin.error != null
          ? ErrorView(
              message: admin.error!,
              onRetry: () => admin.loadDashboard(),
            )
          : RefreshIndicator(
              onRefresh: () => admin.loadDashboard(refresh: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                children: <Widget>[
                  const SectionHeader(
                    title: 'At a glance',
                    subtitle: 'Live numbers across the hub',
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: <Widget>[
                      StatTile(
                        label: 'Registered users',
                        value: '${s.totalUsers}',
                        icon: Icons.people_outline_rounded,
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.adminUsers),
                      ),
                      StatTile(
                        label: 'Courses',
                        value: '${s.totalCourses}',
                        caption: '${s.publishedCourses} published',
                        icon: Icons.school_outlined,
                        accent: AppColors.mint,
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.adminCourses),
                      ),
                      StatTile(
                        label: 'Lab bookings',
                        value: '${s.totalBookings}',
                        caption: '${s.pendingBookings} awaiting confirmation',
                        icon: Icons.event_seat_outlined,
                        accent: AppColors.lavender,
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.adminBookings),
                      ),
                      StatTile(
                        label: 'Print orders',
                        value: '${s.totalPrintOrders}',
                        caption: '${s.activePrintOrders} in the queue',
                        icon: Icons.print_outlined,
                        accent: AppColors.peach,
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.adminOrders),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Manage'),
                  _AdminLink(
                    icon: Icons.people_outline_rounded,
                    label: 'Users & roles',
                    subtitle: '${s.totalUsers} accounts',
                    route: Routes.adminUsers,
                  ),
                  const _AdminLink(
                    icon: Icons.school_outlined,
                    label: 'Course catalogue',
                    subtitle: 'Create, edit, publish and remove courses',
                    route: Routes.adminCourses,
                  ),
                  _AdminLink(
                    icon: Icons.event_seat_outlined,
                    label: 'Lab bookings',
                    subtitle: '${s.pendingBookings} pending',
                    route: Routes.adminBookings,
                  ),
                  _AdminLink(
                    icon: Icons.print_outlined,
                    label: 'Print orders',
                    subtitle: '${s.activePrintOrders} active',
                    route: Routes.adminOrders,
                  ),
                  _AdminLink(
                    icon: Icons.mark_email_unread_outlined,
                    label: 'Contact messages',
                    subtitle: '${s.totalContactMessages} received',
                    route: Routes.adminMessages,
                  ),
                ],
              ),
            ),
    );
  }
}

class _AdminLink extends StatelessWidget {
  const _AdminLink({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(route),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: <Widget>[
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.softBg(AppColors.primary, dark: context.isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
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
                    color: context.inkColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: context.mutedColor),
                ),
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
