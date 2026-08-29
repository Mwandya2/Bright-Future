import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../providers/print_order_provider.dart';
import '../bookings/bookings_screen.dart';
import '../courses/courses_screen.dart';
import '../printing/print_orders_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Bottom-navigation container. Each tab keeps its own state via [IndexedStack].
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmUp());
  }

  Future<void> _warmUp() async {
    if (!mounted) return;
    final CourseProvider courses = context.read<CourseProvider>();
    final BookingProvider bookings = context.read<BookingProvider>();
    final PrintOrderProvider orders = context.read<PrintOrderProvider>();
    await courses.loadAll();
    if (!mounted) return;
    await bookings.load();
    if (!mounted) return;
    await orders.load();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final bool isAdmin = context.watch<AuthProvider>().isAdmin;

    final List<Widget> tabs = <Widget>[
      HomeScreen(onOpenTab: _goTo),
      const CoursesScreen(embedded: true),
      const BookingsScreen(embedded: true),
      const PrintOrdersScreen(embedded: true),
      const ProfileScreen(embedded: true),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : Colors.white,
          border: Border(top: BorderSide(color: context.hairlineColor)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _goTo,
            height: 66,
            backgroundColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: <NavigationDestination>[
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school_rounded),
                label: 'Courses',
              ),
              const NavigationDestination(
                icon: Icon(Icons.desktop_windows_outlined),
                selectedIcon: Icon(Icons.desktop_windows_rounded),
                label: 'Lab',
              ),
              const NavigationDestination(
                icon: Icon(Icons.print_outlined),
                selectedIcon: Icon(Icons.print_rounded),
                label: 'Print',
              ),
              NavigationDestination(
                icon: Icon(
                  isAdmin
                      ? Icons.shield_outlined
                      : Icons.person_outline_rounded,
                ),
                selectedIcon: Icon(
                  isAdmin ? Icons.shield_rounded : Icons.person_rounded,
                ),
                label: isAdmin ? 'Account' : 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goTo(int index) => setState(() => _index = index);
}
