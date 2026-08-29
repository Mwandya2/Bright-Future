import 'json.dart';

/// Mirrors `ContactMessageDto` on the backend.
class ContactMessage {
  const ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    this.subject,
    required this.message,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? subject;
  final String message;
  final DateTime? createdAt;

  factory ContactMessage.fromJson(Map<String, dynamic> json) => ContactMessage(
        id: J.str(json['id']),
        name: J.str(json['name']),
        email: J.str(json['email']),
        subject: J.strOrNull(json['subject']),
        message: J.str(json['message']),
        createdAt: J.date(json['createdAt'] ?? json['created_at']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'createdAt': createdAt?.toIso8601String(),
      };
}
