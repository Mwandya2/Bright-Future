import 'app_user.dart';
import 'enums.dart';
import 'json.dart';

/// Mirrors `BookingDto` on the backend.
///
/// `bookingDate` arrives as an ISO `LocalDate` (`2026-09-01`) and `startTime`
/// as an ISO `LocalTime` (`09:00:00`), so the raw time is kept as a string.
class LabBooking {
  const LabBooking({
    required this.id,
    this.user,
    this.workstationType = WorkstationType.computer,
    this.bookingDate,
    this.startTime = '',
    this.durationHours = 1,
    this.status = BookingStatus.pending,
    this.notes,
    this.createdAt,
  });

  final String id;
  final AppUser? user;
  final WorkstationType workstationType;
  final DateTime? bookingDate;
  final String startTime;
  final int durationHours;
  final BookingStatus status;
  final String? notes;
  final DateTime? createdAt;

  bool get isCancellable =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;

  bool get isUpcoming {
    final DateTime? d = bookingDate;
    if (d == null) return false;
    final DateTime today = DateTime.now();
    return !d.isBefore(DateTime(today.year, today.month, today.day));
  }

  factory LabBooking.fromJson(Map<String, dynamic> json) => LabBooking(
        id: J.str(json['id']),
        user: json['user'] == null
            ? null
            : AppUser.fromJson(J.map(json['user'])),
        workstationType: WorkstationTypeX.parse(
          json['workstationType'] ?? json['workstation_type'],
        ),
        bookingDate: J.date(json['bookingDate'] ?? json['booking_date']),
        startTime: J.str(json['startTime'] ?? json['start_time']),
        durationHours:
            J.intVal(json['durationHours'] ?? json['duration_hours'], 1),
        status: BookingStatusX.parse(json['status']),
        notes: J.strOrNull(json['notes']),
        createdAt: J.date(json['createdAt'] ?? json['created_at']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user': user?.toJson(),
        'workstationType': workstationType.api,
        'bookingDate': bookingDate?.toIso8601String(),
        'startTime': startTime,
        'durationHours': durationHours,
        'status': status.api,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
      };
}
