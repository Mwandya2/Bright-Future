import 'package:flutter/material.dart';

import '../core/storage/app_prefs.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _mode = _decode(AppPrefs.instance.themeMode);
  }

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  String get label {
    switch (_mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Match device';
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    await AppPrefs.instance.setThemeMode(_encode(mode));
  }

  ThemeMode _decode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
