import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive preferences plus a tiny JSON snapshot cache that gives the app
/// a usable offline mode.
class AppPrefs {
  AppPrefs._(this._prefs);

  final SharedPreferences _prefs;

  static AppPrefs? _instance;
  static AppPrefs get instance {
    final AppPrefs? i = _instance;
    if (i == null) {
      throw StateError('AppPrefs.init() must be awaited before use.');
    }
    return i;
  }

  static Future<AppPrefs> init() async {
    _instance ??= AppPrefs._(await SharedPreferences.getInstance());
    return _instance!;
  }

  // ── Keys ────────────────────────────────────────────────────
  static const String _kThemeMode = 'pref_theme_mode';
  static const String _kOnboarded = 'pref_onboarded';
  static const String _kBiometric = 'pref_biometric_lock';
  static const String _kNotifications = 'pref_notifications_enabled';
  static const String _kLastEmail = 'pref_last_email';
  static const String _cachePrefix = 'cache_';
  static const String _cacheStampPrefix = 'cache_at_';

  // ── Simple preferences ──────────────────────────────────────
  /// 'system' | 'light' | 'dark'
  String get themeMode => _prefs.getString(_kThemeMode) ?? 'system';
  Future<void> setThemeMode(String value) =>
      _prefs.setString(_kThemeMode, value);

  bool get hasOnboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded(bool value) => _prefs.setBool(_kOnboarded, value);

  bool get biometricLock => _prefs.getBool(_kBiometric) ?? false;
  Future<void> setBiometricLock(bool value) =>
      _prefs.setBool(_kBiometric, value);

  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_kNotifications, value);

  String get lastEmail => _prefs.getString(_kLastEmail) ?? '';
  Future<void> setLastEmail(String value) =>
      _prefs.setString(_kLastEmail, value);

  // ── Offline snapshot cache ──────────────────────────────────
  Future<void> cacheJson(String key, Object value) async {
    try {
      await _prefs.setString('$_cachePrefix$key', jsonEncode(value));
      await _prefs.setInt(
        '$_cacheStampPrefix$key',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  dynamic readJson(String key) {
    final String? raw = _prefs.getString('$_cachePrefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> readJsonList(String key) {
    final dynamic value = readJson(key);
    if (value is List) {
      return value
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> e) => e.cast<String, dynamic>())
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  DateTime? cachedAt(String key) {
    final int? ms = _prefs.getInt('$_cacheStampPrefix$key');
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> clearCache() async {
    final Set<String> keys = _prefs.getKeys().toSet();
    for (final String key in keys) {
      if (key.startsWith(_cachePrefix) || key.startsWith(_cacheStampPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Cache keys used across the app.
  static const String cacheCourses = 'courses';
  static const String cacheMyEnrollments = 'my_enrollments';
  static const String cacheMyBookings = 'my_bookings';
  static const String cacheMyOrders = 'my_orders';
  static const String cacheNotifications = 'notifications';
}
