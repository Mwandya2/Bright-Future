import '../../core/network/api_client.dart';
import '../models/app_user.dart';
import '../models/auth_session.dart';
import '../models/json.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final dynamic data = await _api.post(
      '/auth/login',
      authenticated: false,
      body: <String, dynamic>{
        'email': email.trim(),
        'password': password,
      },
    );
    return AuthSession.fromJson(J.map(data));
  }

  /// Separate endpoint - the backend also checks the address against the
  /// configured administrator email.
  Future<AuthSession> adminLogin({
    required String email,
    required String password,
  }) async {
    final dynamic data = await _api.post(
      '/auth/admin-login',
      authenticated: false,
      body: <String, dynamic>{
        'email': email.trim(),
        'password': password,
      },
    );
    return AuthSession.fromJson(J.map(data));
  }

  Future<AuthSession> signup({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final dynamic data = await _api.post(
      '/auth/signup',
      authenticated: false,
      body: <String, dynamic>{
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );
    return AuthSession.fromJson(J.map(data));
  }

  /// Confirms the SMS code and completes signup, returning a usable session.
  Future<AuthSession> verifyPhone({
    required String email,
    required String code,
  }) async {
    final dynamic data = await _api.post(
      '/auth/verify-phone',
      authenticated: false,
      body: <String, dynamic>{'email': email.trim(), 'code': code.trim()},
    );
    return AuthSession.fromJson(J.map(data));
  }

  /// Confirms the emailed code. Does not affect sign-in.
  Future<AppUser> verifyEmail({
    required String email,
    required String code,
  }) async {
    final dynamic data = await _api.post(
      '/auth/verify-email',
      authenticated: false,
      body: <String, dynamic>{'email': email.trim(), 'code': code.trim()},
    );
    return AppUser.fromJson(J.map(data));
  }

  /// Asks for a fresh code. Rate limited on the server.
  Future<void> resendCode({
    required String email,
    String channel = 'PHONE',
  }) async {
    await _api.post(
      '/auth/resend-code',
      authenticated: false,
      body: <String, dynamic>{'email': email.trim(), 'channel': channel},
    );
  }

  Future<AppUser> me() async {
    final dynamic data = await _api.get('/auth/me');
    return AppUser.fromJson(J.map(data));
  }
}
