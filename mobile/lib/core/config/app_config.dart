import 'package:flutter/foundation.dart';

/// Central, build-time configuration for the Bright Future mobile app.
///
/// Nothing secret is hard-coded here. Values are injected at build time with
/// `--dart-define`, e.g.
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.brightfuture.best/api
/// ```
class AppConfig {
  const AppConfig._();

  // ── Branding ────────────────────────────────────────────────
  static const String appName = 'Bright Future';
  static const String longName = 'Bright Future Digital Hub';
  static const String tagline = 'Learn. Build. Print. Grow.';
  static const String websiteUrl = 'https://brightfuture.best';
  static const String supportEmail = 'hello@brightfuture.best';
  static const String supportPhone = '+255700000000';
  static const String privacyUrl = 'https://brightfuture.best/privacy';
  static const String termsUrl = 'https://brightfuture.best/terms';

  /// Prices in the backend are stored as whole units of Tanzanian Shilling.
  static const String currencyCode = 'TZS';
  static const String currencySymbol = 'TSh';

  // ── Build-time injected values ──────────────────────────────
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Network timeout for every request.
  ///
  /// Deliberately generous. A free-tier server sleeps after fifteen minutes
  /// idle and can take the better part of a minute to wake, and a twenty
  /// second timeout turned that wait into "cannot reach the server" - a
  /// failure the user cannot act on for a server that was merely starting.
  ///
  /// Drop this back to about twenty seconds once the API runs on an instance
  /// that does not sleep; until then a slow first request beats a false error.
  static const Duration requestTimeout = Duration(seconds: 60);

  /// Resolved API base URL, including the `/api` prefix.
  ///
  /// Falls back to a sensible localhost default so the app runs out of the box:
  /// Android emulators reach the host machine on 10.0.2.2, everything else on
  /// localhost.
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _stripTrailingSlash(_apiBaseUrlOverride);
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static String _stripTrailingSlash(String value) {
    var v = value.trim();
    while (v.endsWith('/')) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }
}
