import 'package:intl/intl.dart';

import '../config/app_config.dart';

/// Formatting helpers shared by every screen.
class Fmt {
  const Fmt._();

  static final NumberFormat _money = NumberFormat.decimalPattern('en');
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateLong = DateFormat('EEEE, d MMMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, HH:mm');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  /// Backend prices are whole shillings. `0` renders as "Free".
  static String price(num? value) {
    if (value == null || value <= 0) return 'Free';
    return '${AppConfig.currencySymbol} ${_money.format(value)}';
  }

  static String money(num? value) =>
      '${AppConfig.currencySymbol} ${_money.format(value ?? 0)}';

  static String date(DateTime? value) =>
      value == null ? '-' : _date.format(value.toLocal());

  static String dateLong(DateTime? value) =>
      value == null ? '-' : _dateLong.format(value.toLocal());

  static String dateTime(DateTime? value) =>
      value == null ? '-' : _dateTime.format(value.toLocal());

  /// `yyyy-MM-dd`, the shape Spring's `LocalDate` expects.
  static String isoDate(DateTime value) => _isoDate.format(value);

  /// `HH:mm:ss`, the shape Spring's `LocalTime` expects.
  static String isoTime(int hour, int minute) {
    final String h = hour.toString().padLeft(2, '0');
    final String m = minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  static String time(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final List<String> parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  static String relative(DateTime? value) {
    if (value == null) return '';
    final Duration diff = DateTime.now().difference(value.toLocal());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(value);
  }

  /// `IN_PROGRESS` -> `In progress`
  static String enumLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final String lower = raw.toLowerCase().replaceAll('_', ' ');
    return lower[0].toUpperCase() + lower.substring(1);
  }

  static String initials(String? name) {
    final String value = (name ?? '').trim();
    if (value.isEmpty) return '?';
    final List<String> parts =
        value.split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
