import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/services/biometric_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/payment_service.dart';
import 'core/storage/app_prefs.dart';
import 'core/storage/secure_store.dart';
import 'core/storage/session.dart';
import 'data/repositories/admin_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/contact_repository.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/print_order_repository.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/course_provider.dart';
import 'providers/print_order_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AppPrefs.init();

  // ── Wiring ────────────────────────────────────────────────
  final SecureStore secureStore = SecureStore();
  final ApiClient api = ApiClient(
    tokenProvider: () async => Session.token,
    onUnauthorized: () async {
      final Future<void> Function()? handler = Session.onExpired;
      if (handler != null) await handler();
    },
  );

  final AuthRepository authRepo = AuthRepository(api);
  final CourseRepository courseRepo = CourseRepository(api);
  final BookingRepository bookingRepo = BookingRepository(api);
  final PrintOrderRepository orderRepo = PrintOrderRepository(api);
  final ContactRepository contactRepo = ContactRepository(api);
  final AdminRepository adminRepo = AdminRepository(api);

  final PaymentService payments = PaymentService(api: api);
  final AuthProvider authProvider = AuthProvider(
    repository: authRepo,
    store: secureStore,
    biometrics: BiometricService(),
  );

  Session.onExpired = () => authProvider.signOut(keepCache: true);

  // Best-effort: the app must still start when push has not been configured.
  // Payments need no start-up step - ClickPesa is driven entirely by the
  // backend, so there is no client SDK to initialise here.
  unawaited(NotificationService.instance.init());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(ConnectivityService()),
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<CourseProvider>(
          create: (_) => CourseProvider(courseRepo),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(bookingRepo),
        ),
        ChangeNotifierProvider<PrintOrderProvider>(
          create: (_) => PrintOrderProvider(orderRepo),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(
            admin: adminRepo,
            courses: courseRepo,
            bookings: bookingRepo,
            orders: orderRepo,
            contact: contactRepo,
          ),
        ),
        Provider<PaymentService>.value(value: payments),
        Provider<ContactRepository>.value(value: contactRepo),
      ],
      child: const BrightFutureApp(),
    ),
  );
}
