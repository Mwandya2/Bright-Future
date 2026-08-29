import 'app_user.dart';
import 'course.dart';
import 'enums.dart';
import 'json.dart';

/// Mirrors `EnrollmentDto` on the backend.
class Enrollment {
  const Enrollment({
    required this.id,
    this.user,
    this.course,
    this.status = EnrollmentStatus.active,
    this.progress = 0,
    this.createdAt,
  });

  final String id;
  final AppUser? user;
  final Course? course;
  final EnrollmentStatus status;
  final int progress;
  final DateTime? createdAt;

  double get progressFraction => (progress.clamp(0, 100)) / 100;

  bool get isComplete =>
      status == EnrollmentStatus.completed || progress >= 100;

  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
        id: J.str(json['id']),
        user: json['user'] == null
            ? null
            : AppUser.fromJson(J.map(json['user'])),
        course: json['course'] == null
            ? null
            : Course.fromJson(J.map(json['course'])),
        status: EnrollmentStatusX.parse(json['status']),
        progress: J.intVal(json['progress']),
        createdAt: J.date(json['createdAt'] ?? json['created_at']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user': user?.toJson(),
        'course': course?.toJson(),
        'status': status.api,
        'progress': progress,
        'createdAt': createdAt?.toIso8601String(),
      };
}
