import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../storage/app_prefs.dart';

/// Fired by the OS when a push arrives while the app is terminated.
///
/// Must stay a top-level function with the entry-point pragma.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Nothing to do here beyond letting the OS display the notification. The
  // inbox is refreshed from the payload the next time the app is opened.
}

/// A locally stored notification, shown in the in-app inbox.
class AppNotification {
  AppNotification({
    required this.title,
    required this.body,
    required this.receivedAt,
    this.route,
    this.read = false,
  });

  final String title;
  final String body;
  final DateTime receivedAt;
  final String? route;
  final bool read;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
        'route': route,
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        title: (json['title'] ?? '') as String,
        body: (json['body'] ?? '') as String,
        receivedAt:
            DateTime.tryParse((json['receivedAt'] ?? '') as String) ??
                DateTime.now(),
        route: json['route'] as String?,
        read: (json['read'] ?? false) as bool,
      );

  AppNotification copyWith({bool? read}) => AppNotification(
        title: title,
        body: body,
        receivedAt: receivedAt,
        route: route,
        read: read ?? this.read,
      );
}

/// Push + local notifications.
///
/// Every call is defensive: if Firebase has not been configured yet (no
/// `google-services.json` / `GoogleService-Info.plist`) the app still runs, it
/// simply has no remote push. Local notifications work either way.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _localReady = false;
  bool firebaseReady = false;
  String? fcmToken;

  final StreamController<AppNotification> _incoming =
      StreamController<AppNotification>.broadcast();
  Stream<AppNotification> get onNotification => _incoming.stream;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'bright_future_default',
    'Bright Future alerts',
    channelDescription:
        'Booking confirmations, print order updates and course announcements.',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const DarwinNotificationDetails _iosDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  Future<void> init() async {
    await _initLocal();
    await _initFirebase();
  }

  Future<void> _initLocal() async {
    if (_localReady) return;
    try {
      const AndroidInitializationSettings android =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const InitializationSettings settings =
          InitializationSettings(android: android, iOS: ios);
      await _local.initialize(settings);
      _localReady = true;
    } catch (e) {
      debugPrint('Local notifications unavailable: $e');
    }
  }

  Future<void> _initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      fcmToken = await messaging.getToken();
      firebaseReady = true;

      FirebaseMessaging.onMessage.listen(_handleRemote);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemote);
    } catch (e) {
      firebaseReady = false;
      debugPrint(
        'Firebase push not configured yet - the app runs without it. ($e)',
      );
    }
  }

  /// Asks the OS for notification permission. Safe to call more than once.
  Future<bool> requestPermission() async {
    bool granted = false;
    try {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission();
      granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {}

    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _local.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? androidGranted = await android?.requestNotificationsPermission();
      granted = granted || (androidGranted ?? false);
    } catch (_) {}

    return granted;
  }

  void _handleRemote(RemoteMessage message) {
    final RemoteNotification? n = message.notification;
    final AppNotification item = AppNotification(
      title: n?.title ?? message.data['title']?.toString() ?? 'Bright Future',
      body: n?.body ?? message.data['body']?.toString() ?? '',
      receivedAt: DateTime.now(),
      route: message.data['route']?.toString(),
    );
    unawaited(_store(item));
    _incoming.add(item);
    unawaited(showLocal(title: item.title, body: item.body));
  }

  /// Shows a notification raised by the app itself (booking created, order
  /// status changed, and so on).
  Future<void> showLocal({
    required String title,
    required String body,
    String? route,
    bool record = false,
  }) async {
    if (!AppPrefs.instance.notificationsEnabled) return;
    await _initLocal();
    if (record) {
      await _store(AppNotification(
        title: title,
        body: body,
        receivedAt: DateTime.now(),
        route: route,
      ));
    }
    try {
      await _local.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(android: _androidDetails, iOS: _iosDetails),
        payload: route,
      );
    } catch (e) {
      debugPrint('Could not show notification: $e');
    }
  }

  /// Records an entry in the in-app inbox without buzzing the device.
  Future<void> record({
    required String title,
    required String body,
    String? route,
  }) =>
      _store(AppNotification(
        title: title,
        body: body,
        receivedAt: DateTime.now(),
        route: route,
      ));

  Future<void> _store(AppNotification item) async {
    try {
      final List<AppNotification> all = await readInbox();
      all.insert(0, item);
      final List<AppNotification> trimmed =
          all.length > 50 ? all.sublist(0, 50) : all;
      await AppPrefs.instance.cacheJson(
        AppPrefs.cacheNotifications,
        trimmed.map((AppNotification n) => n.toJson()).toList(),
      );
    } catch (_) {}
  }

  Future<List<AppNotification>> readInbox() async {
    try {
      final List<Map<String, dynamic>> raw =
          AppPrefs.instance.readJsonList(AppPrefs.cacheNotifications);
      return raw.map(AppNotification.fromJson).toList();
    } catch (_) {
      return <AppNotification>[];
    }
  }

  Future<void> markAllRead() async {
    final List<AppNotification> all = await readInbox();
    await AppPrefs.instance.cacheJson(
      AppPrefs.cacheNotifications,
      all
          .map((AppNotification n) => n.copyWith(read: true).toJson())
          .toList(),
    );
  }

  Future<void> clearInbox() =>
      AppPrefs.instance.cacheJson(AppPrefs.cacheNotifications, <dynamic>[]);

  /// Subscribes the device to a broadcast topic (e.g. course announcements).
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (_) {}
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (_) {}
  }

  /// Debug helper - prints the device token so you can send a test push.
  String describeToken() =>
      fcmToken == null ? 'Not registered' : jsonEncode(fcmToken);
}
