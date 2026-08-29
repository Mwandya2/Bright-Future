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

  Future<AppUser> me() async {
    final dynamic data = await _api.get('/auth/me');
    return AppUser.fromJson(J.map(data));
  }
}
