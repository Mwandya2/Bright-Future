import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/storage/app_prefs.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'ui/screens/admin/admin_bookings_screen.dart';
import 'ui/screens/admin/admin_courses_screen.dart';
import 'ui/screens/admin/admin_dashboard_screen.dart';
import 'ui/screens/admin/admin_messages_screen.dart';
import 'ui/screens/admin/admin_orders_screen.dart';
import 'ui/screens/admin/admin_users_screen.dart';
import 'ui/screens/auth/admin_login_screen.dart';
import 'ui/screens/auth/lock_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/signup_screen.dart';
import 'ui/screens/bookings/bookings_screen.dart';
import 'ui/screens/bookings/new_booking_screen.dart';
import 'ui/screens/courses/courses_screen.dart';
import 'ui/screens/courses/my_courses_screen.dart';
import 'ui/screens/home/home_shell.dart';
import 'ui/screens/misc/about_screen.dart';
import 'ui/screens/misc/contact_screen.dart';
import 'ui/screens/misc/notifications_screen.dart';
import 'ui/screens/misc/onboarding_screen.dart';
import 'ui/screens/misc/settings_screen.dart';
import 'ui/screens/misc/splash_screen.dart';
import 'ui/screens/modules/ecosystem_screen.dart';
import 'ui/screens/printing/new_print_order_screen.dart';
import 'ui/screens/printing/print_orders_screen.dart';
import 'ui/screens/profile/profile_screen.dart';

class BrightFutureApp extends StatelessWidget {
  const BrightFutureApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const RootGate(),
      routes: <String, WidgetBuilder>{
        Routes.onboarding: (_) => const OnboardingScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.signup: (_) => const SignupScreen(),
        Routes.adminLogin: (_) => const AdminLoginScreen(),
        Routes.home: (_) => const HomeShell(),
        Routes.courses: (_) => const CoursesScreen(),
        Routes.myCourses: (_) => const MyCoursesScreen(),
        Routes.bookings: (_) => const BookingsScreen(),
        Routes.newBooking: (_) => const NewBookingScreen(),
        Routes.printing: (_) => const PrintOrdersScreen(),
        Routes.newPrintOrder: (_) => const NewPrintOrderScreen(),
        Routes.ecosystem: (_) => const EcosystemScreen(),
        Routes.contact: (_) => const ContactScreen(),
        Routes.about: (_) => const AboutScreen(),
        Routes.profile: (_) => const ProfileScreen(),
        Routes.settings: (_) => const SettingsScreen(),
        Routes.notifications: (_) => const NotificationsScreen(),
        Routes.admin: (_) => const AdminDashboardScreen(),
        Routes.adminUsers: (_) => const AdminUsersScreen(),
        Routes.adminCourses: (_) => const AdminCoursesScreen(),
        Routes.adminBookings: (_) => const AdminBookingsScreen(),
        Routes.adminOrders: (_) => const AdminOrdersScreen(),
        Routes.adminMessages: (_) => const AdminMessagesScreen(),
      },
      builder: (BuildContext context, Widget? child) {
        // Keep text legible regardless of an extreme system font scale.
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.35,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Decides which screen the app opens on, based on the restored session.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    switch (auth.state) {
      case AuthState.unknown:
        return const SplashScreen();
      case AuthState.locked:
        return const LockScreen();
      case AuthState.signedIn:
        return const HomeShell();
      case AuthState.signedOut:
        return AppPrefs.instance.hasOnboarded
            ? const LoginScreen()
            : OnboardingScreen(onDone: () => setState(() {}));
    }
  }
}
