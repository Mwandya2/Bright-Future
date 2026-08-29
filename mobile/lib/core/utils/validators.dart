/// Form validators kept in one place so error copy stays consistent.
class Validators {
  const Validators._();

  static final RegExp _email = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$',
  );

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Email is required';
    if (!_email.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 3) return 'Please enter your full name';
    return null;
  }

  static String? phone(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return null; // optional
    if (v.length < 9) return 'Enter a valid phone number';
    return null;
  }

  /// Normalises a Tanzanian mobile number to the 255XXXXXXXXX form ClickPesa
  /// requires. Accepts the shapes people actually type: 0712..., +255712...,
  /// 255712... and 712...
  ///
  /// Returns null when the value cannot be a Tanzanian mobile. Mirrors
  /// ClickPesaService.normalizeTzPhone on the server.
  static String? normalizeTzMobile(String? value) {
    final String digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    // Tanzanian mobile numbers are nine digits starting 6 or 7 (06x / 07x).
    // Anything else - a landline, a typo, another country - is rejected here
    // rather than after a failed round trip to ClickPesa.
    if (digits.startsWith('255') && digits.length == 12) {
      return _isMobileBody(digits.substring(3)) ? digits : null;
    }
    if (digits.startsWith('0') && digits.length == 10) {
      final String body = digits.substring(1);
      return _isMobileBody(body) ? '255$body' : null;
    }
    if (digits.length == 9) {
      return _isMobileBody(digits) ? '255$digits' : null;
    }
    return null;
  }

  static bool _isMobileBody(String body) =>
      body.length == 9 && (body.startsWith('6') || body.startsWith('7'));

  /// Form validator for a mobile money number. Required, unlike [phone].
  static String? tzMobile(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Enter your mobile money number';
    }
    return normalizeTzMobile(value) == null
        ? 'Enter a Tanzanian number, e.g. 0712 345 678'
        : null;
  }

  static String? minLength(String? value, int min, {String field = 'This'}) {
    final String v = (value ?? '').trim();
    if (v.length < min) return '$field must be at least $min characters';
    return null;
  }
}
