/// In-memory holder for the active JWT.
///
/// [ApiClient] reads from here on every request, and [AuthProvider] keeps it in
/// sync with the secure store. Keeping it separate avoids a circular dependency
/// between the network layer and the state layer.
class Session {
  Session._();

  static String? token;

  /// Invoked by the API client whenever the server rejects the token, so the
  /// app can drop straight back to the sign-in screen.
  static Future<void> Function()? onExpired;

  static bool get isSignedIn => (token ?? '').isNotEmpty;

  static void clear() => token = null;
}
