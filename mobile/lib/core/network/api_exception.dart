/// A single, user-presentable error type for everything the API layer can fail
/// with. UI code should never need to know about sockets or status codes.
class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;
  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  /// The backend answers 403 when the password was right but the account's
  /// phone has not been confirmed, so the app can send the user to the code
  /// screen instead of making them retype a password that was correct.
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  factory ApiException.network([String? detail]) => ApiException(
        detail ??
            'Cannot reach the Bright Future server. Check your internet '
                'connection and try again.',
        isNetworkError: true,
      );

  factory ApiException.timeout() => ApiException(
        'The server took too long to respond. Please try again.',
        isNetworkError: true,
      );

  @override
  String toString() => message;
}
