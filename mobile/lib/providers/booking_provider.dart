import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/services/notification_service.dart';
import '../core/utils/formatters.dart';
import '../data/models/enums.dart';
import '../data/models/lab_booking.dart';
import '../data/repositories/booking_repository.dart';
import 'load_state.dart';

class BookingProvider extends ChangeNotifier with LoadState {
  BookingProvider(this._repo);

  final BookingRepository _repo;

  List<LabBooking> _bookings = <LabBooking>[];
  List<LabBooking> get bookings => _bookings;

  List<LabBooking> get upcoming => _bookings
      .where((LabBooking b) => b.isUpcoming && b.isCancellable)
      .toList();

  List<LabBooking> get past => _bookings
      .where((LabBooking b) => !(b.isUpcoming && b.isCancellable))
      .toList();

  Future<void> load({bool refresh = false}) async {
    beginLoad(refresh: refresh);
    try {
      _bookings = await _repo.mine();
      endLoad();
    } on ApiException catch (e) {
      final List<LabBooking> cached = _repo.cached();
      if (cached.isNotEmpty) {
        _bookings = cached;
        endLoad(fromCache: true);
      } else {
        endLoad(error: e.message);
      }
    } catch (_) {
      endLoad(error: 'Could not load your bookings.');
    }
  }

  Future<String?> create({
    required WorkstationType type,
    required DateTime date,
    required int hour,
    required int minute,
    required int durationHours,
    String? notes,
  }) async {
    try {
      final LabBooking created = await _repo.create(
        workstationType: type,
        bookingDate: Fmt.isoDate(date),
        startTime: Fmt.isoTime(hour, minute),
        durationHours: durationHours,
        notes: notes,
      );
      _bookings = <LabBooking>[created, ..._bookings];
      notifyListeners();
      await NotificationService.instance.showLocal(
        title: 'Booking requested',
        body:
            '${type.label} on ${Fmt.date(created.bookingDate ?? date)} at '
            '${Fmt.time(created.startTime)}. We will confirm shortly.',
        route: '/bookings',
        record: true,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not create the booking. Please try again.';
    }
  }

  Future<String?> cancel(String id) async {
    try {
      final LabBooking updated = await _repo.cancel(id);
      final int index = _bookings.indexWhere((LabBooking b) => b.id == id);
      if (index >= 0) {
        _bookings[index] = updated;
        notifyListeners();
      }
      await NotificationService.instance.record(
        title: 'Booking cancelled',
        body: '${updated.workstationType.label} booking was cancelled.',
        route: '/bookings',
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not cancel the booking.';
    }
  }

  void reset() {
    _bookings = <LabBooking>[];
    notifyListeners();
  }
}
