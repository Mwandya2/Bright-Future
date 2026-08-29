/// Defensive JSON readers.
///
/// The Spring Boot API is the source of truth, but a mobile client must never
/// crash because a field arrived as a number instead of a string, or was null.
class J {
  const J._();

  static Map<String, dynamic> map(dynamic value) {
    if (value is Map) return value.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> list(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> e) => e.cast<String, dynamic>())
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  static String str(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  static String? strOrNull(dynamic value) {
    if (value == null) return null;
    final String s = value.toString();
    return s.isEmpty ? null : s;
  }

  static int intVal(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool boolVal(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String v = value.toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes') return true;
      if (v == 'false' || v == '0' || v == 'no') return false;
    }
    return fallback;
  }

  /// Handles ISO-8601 strings (`Instant`, `LocalDate`) and epoch millis.
  static DateTime? date(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value > 100000000000 ? value : value * 1000,
      );
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is List && value.length >= 3) {
      // Jackson array form: [yyyy, MM, dd, ...]
      try {
        return DateTime(
          (value[0] as num).toInt(),
          (value[1] as num).toInt(),
          (value[2] as num).toInt(),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Normalises an enum coming back from Java (`IN_PROGRESS`) or from the web
  /// app's older lowercase form (`in_progress`).
  static String enumKey(dynamic value, String fallback) {
    if (value == null) return fallback;
    final String s = value.toString().trim();
    if (s.isEmpty) return fallback;
    return s.toUpperCase().replaceAll('-', '_');
  }
}
