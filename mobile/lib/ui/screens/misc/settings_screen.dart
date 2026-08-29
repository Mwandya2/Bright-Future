import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricService _biometrics = BiometricService();

  bool _biometricAvailable = false;
  String _biometricLabel = 'Biometric unlock';
  late bool _biometricEnabled = AppPrefs.instance.biometricLock;
  late bool _notificationsEnabled = AppPrefs.instance.notificationsEnabled;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final bool available = await _biometrics.isAvailable();
    final String label = await _biometrics.describeAvailable();
    String version = '';
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      version = '${info.version} (${info.buildNumber})';
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricLabel = label;
      _version = version;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final bool ok = await _biometrics.authenticate(
        reason: 'Confirm it is you to turn on app lock',
      );
      if (!ok) {
        if (!mounted) return;
        AppSnack.info(context, 'App lock was not enabled.');
        return;
      }
    }
    await AppPrefs.instance.setBiometricLock(value);
    if (!mounted) return;
    setState(() => _biometricEnabled = value);
  }

  Future<void> _toggleNotifications(bool value) async {
    await AppPrefs.instance.setNotificationsEnabled(value);
    if (value) {
      await NotificationService.instance.requestPermission();
    }
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _clearCache() async {
    await AppPrefs.instance.clearCache();
    if (!mounted) return;
    AppSnack.success(context, 'Offline data cleared.');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        children: <Widget>[
          const SectionHeader(
            title: 'Appearance',
            subtitle: 'How Bright Future looks on this device',
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: <Widget>[
                _themeOption(theme, ThemeMode.system, 'Match device',
                    Icons.brightness_auto_rounded),
                _themeOption(theme, ThemeMode.light, 'Light',
                    Icons.light_mode_outlined),
                _themeOption(theme, ThemeMode.dark, 'Dark',
                    Icons.dark_mode_outlined),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(
            title: 'Security',
            subtitle: 'Protect your account on this phone',
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: SwitchListTile(
              value: _biometricEnabled && _biometricAvailable,
              onChanged: _biometricAvailable ? _toggleBiometric : null,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Require $_biometricLabel',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: context.inkColor,
                ),
              ),
              subtitle: Text(
                _biometricAvailable
                    ? 'Ask for it every time the app is opened.'
                    : 'No biometric or device passcode is set up on this phone.',
                style: TextStyle(fontSize: 12.5, color: context.mutedColor),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(
            title: 'Notifications',
            subtitle: 'Booking confirmations and print order updates',
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: SwitchListTile(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Allow notifications',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: context.inkColor,
                ),
              ),
              subtitle: Text(
                NotificationService.instance.firebaseReady
                    ? 'Push notifications are active on this device.'
                    : 'Local alerts only - remote push is not configured yet.',
                style: TextStyle(fontSize: 12.5, color: context.mutedColor),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(
            title: 'Storage',
            subtitle: 'Data saved on this device for offline use',
          ),
          AppCard(
            onTap: _clearCache,
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.cleaning_services_outlined,
                  size: 19,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Clear offline data',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: context.inkColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.mutedColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'About this build'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _meta(context, 'App version', _version.isEmpty ? '-' : _version),
                _meta(context, 'API server', AppConfig.apiBaseUrl),
                _meta(
                  context,
                  'Payments',
                  // Whether a given course can be paid for in-app now depends
                  // on that course, so this reports the platform rule instead.
                  defaultTargetPlatform == TargetPlatform.iOS
                      ? 'Mobile money for hub courses'
                      : 'Mobile money',
                ),
                _meta(
                  context,
                  'Push notifications',
                  NotificationService.instance.firebaseReady
                      ? 'Connected'
                      : 'Not configured',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeOption(
    ThemeProvider theme,
    ThemeMode mode,
    String label,
    IconData icon,
  ) {
    final bool selected = theme.mode == mode;
    return ListTile(
      onTap: () => theme.setMode(mode),
      leading: Icon(
        icon,
        size: 20,
        color: selected ? AppColors.primary : context.mutedColor,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: context.inkColor,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, size: 19, color: AppColors.primary)
          : null,
    );
  }

  Widget _meta(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: context.mutedColor),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: context.inkColor,
                ),
              ),
            ),
          ],
        ),
      );
}
