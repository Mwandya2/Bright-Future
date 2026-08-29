import '../../core/network/api_client.dart';
import '../../core/storage/app_prefs.dart';
import '../models/enums.dart';
import '../models/json.dart';
import '../models/lab_booking.dart';

class BookingRepository {
  BookingRepository(this._api);

  final ApiClient _api;

  Future<List<LabBooking>> mine() async {
    final dynamic data = await _api.get('/bookings/my');
    final List<LabBooking> items =
        J.list(data).map(LabBooking.fromJson).toList();
    await AppPrefs.instance.cacheJson(
      AppPrefs.cacheMyBookings,
      items.map((LabBooking b) => b.toJson()).toList(),
    );
    return items;
  }

  List<LabBooking> cached() => AppPrefs.instance
      .readJsonList(AppPrefs.cacheMyBookings)
      .map(LabBooking.fromJson)
      .toList();

  Future<LabBooking> create({
    required WorkstationType workstationType,
    required String bookingDate, // yyyy-MM-dd
    required String startTime, // HH:mm:ss
    required int durationHours,
    String? notes,
  }) async {
    final dynamic data = await _api.post(
      '/bookings',
      body: <String, dynamic>{
        'workstationType': workstationType.api,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'durationHours': durationHours,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return LabBooking.fromJson(J.map(data));
  }

  Future<LabBooking> cancel(String id) async {
    final dynamic data = await _api.patch('/bookings/$id/cancel');
    return LabBooking.fromJson(J.map(data));
  }

  // ── Admin ───────────────────────────────────────────────────
  Future<List<LabBooking>> all() async {
    final dynamic data = await _api.get('/bookings');
    return J.list(data).map(LabBooking.fromJson).toList();
  }

  Future<LabBooking> updateStatus(String id, BookingStatus status) async {
    final dynamic data = await _api.patch(
      '/bookings/$id/status',
      body: <String, dynamic>{'status': status.api},
    );
    return LabBooking.fromJson(J.map(data));
  }
}
