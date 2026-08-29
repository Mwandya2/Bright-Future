import 'app_user.dart';
import 'json.dart';

/// Mirrors `AuthResponse` on the backend.
class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
    this.tokenType = 'Bearer',
  });

  final String token;
  final String tokenType;
  final AppUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: J.str(json['token']),
        tokenType: J.str(json['tokenType'], 'Bearer'),
        user: AppUser.fromJson(J.map(json['user'])),
      );
}
