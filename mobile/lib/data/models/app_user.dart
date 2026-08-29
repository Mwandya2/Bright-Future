import 'enums.dart';
import 'json.dart';

/// Mirrors `UserDto` on the backend.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.role = UserRole.student,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final DateTime? createdAt;

  String get displayName {
    final String n = (fullName ?? '').trim();
    if (n.isNotEmpty) return n;
    final int at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  String get firstName => displayName.split(RegExp(r'\s+')).first;

  bool get isAdmin => role.isAdmin;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: J.str(json['id']),
        email: J.str(json['email']),
        fullName: J.strOrNull(json['fullName'] ?? json['full_name']),
        phone: J.strOrNull(json['phone']),
        role: UserRoleX.parse(json['role']),
        avatarUrl: J.strOrNull(json['avatarUrl'] ?? json['avatar_url']),
        createdAt: J.date(json['createdAt'] ?? json['created_at']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'role': role.api,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt?.toIso8601String(),
      };

  AppUser copyWith({String? fullName, String? phone, UserRole? role}) =>
      AppUser(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
      );
}
