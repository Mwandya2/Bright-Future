import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../data/models/admin_stats.dart';
import '../data/models/app_user.dart';
import '../data/models/contact_message.dart';
import '../data/models/course.dart';
import '../data/models/enums.dart';
import '../data/models/lab_booking.dart';
import '../data/models/print_order.dart';
import '../data/repositories/admin_repository.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/contact_repository.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/print_order_repository.dart';
import 'load_state.dart';

/// Backs the whole administrator area.
class AdminProvider extends ChangeNotifier with LoadState {
  AdminProvider({
    required AdminRepository admin,
    required CourseRepository courses,
    required BookingRepository bookings,
    required PrintOrderRepository orders,
    required ContactRepository contact,
  })  : _admin = admin,
        _courses = courses,
        _bookings = bookings,
        _orders = orders,
        _contact = contact;

  final AdminRepository _admin;
  final CourseRepository _courses;
  final BookingRepository _bookings;
  final PrintOrderRepository _orders;
  final ContactRepository _contact;

  AdminStats _stats = const AdminStats();
  List<AppUser> _users = <AppUser>[];
  List<Course> _allCourses = <Course>[];
  List<LabBooking> _allBookings = <LabBooking>[];
  List<PrintOrder> _allOrders = <PrintOrder>[];
  List<ContactMessage> _messages = <ContactMessage>[];

  AdminStats get stats => _stats;
  List<AppUser> get users => _users;
  List<Course> get allCourses => _allCourses;
  List<LabBooking> get allBookings => _allBookings;
  List<PrintOrder> get allOrders => _allOrders;
  List<ContactMessage> get messages => _messages;

  Future<void> loadDashboard({bool refresh = false}) async {
    beginLoad(refresh: refresh);
    try {
      _stats = await _admin.stats();
      endLoad();
    } on ApiException catch (e) {
      endLoad(error: e.message);
    } catch (_) {
      endLoad(error: 'Could not load the dashboard.');
    }
  }

  Future<void> loadUsers({bool refresh = false}) =>
      _guard(refresh, () async => _users = await _admin.users());

  Future<void> loadCourses({bool refresh = false}) =>
      _guard(refresh, () async => _allCourses = await _courses.allIncludingDrafts());

  Future<void> loadBookings({bool refresh = false}) =>
      _guard(refresh, () async => _allBookings = await _bookings.all());

  Future<void> loadOrders({bool refresh = false}) =>
      _guard(refresh, () async => _allOrders = await _orders.all());

  Future<void> loadMessages({bool refresh = false}) =>
      _guard(refresh, () async => _messages = await _contact.all());

  Future<void> _guard(bool refresh, Future<void> Function() action) async {
    beginLoad(refresh: refresh);
    try {
      await action();
      endLoad();
    } on ApiException catch (e) {
      endLoad(error: e.message);
    } catch (_) {
      endLoad(error: 'Something went wrong loading that list.');
    }
  }

  // ── Mutations ───────────────────────────────────────────────
  Future<String?> setUserRole(String userId, UserRole role) async {
    try {
      final AppUser updated = await _admin.updateRole(userId, role);
      final int i = _users.indexWhere((AppUser u) => u.id == userId);
      if (i >= 0) _users[i] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not update that role.';
    }
  }

  Future<String?> setBookingStatus(String id, BookingStatus status) async {
    try {
      final LabBooking updated = await _bookings.updateStatus(id, status);
      final int i = _allBookings.indexWhere((LabBooking b) => b.id == id);
      if (i >= 0) _allBookings[i] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not update that booking.';
    }
  }

  Future<String?> setOrderStatus(String id, OrderStatus status) async {
    try {
      final PrintOrder updated = await _orders.updateStatus(id, status);
      final int i = _allOrders.indexWhere((PrintOrder o) => o.id == id);
      if (i >= 0) _allOrders[i] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not update that order.';
    }
  }

  Future<String?> createCourse(Map<String, dynamic> form) async {
    try {
      final Course created = await _courses.create(
        title: form['title'] as String,
        slug: form['slug'] as String,
        summary: form['summary'] as String?,
        description: form['description'] as String?,
        category: (form['category'] as String?) ?? 'ict',
        level: (form['level'] as CourseLevel?) ?? CourseLevel.beginner,
        price: (form['price'] as int?) ?? 0,
        durationWeeks: (form['durationWeeks'] as int?) ?? 4,
        instructorName: form['instructorName'] as String?,
        coverGradient: (form['coverGradient'] as String?) ?? 'mint',
        isPublished: (form['isPublished'] as bool?) ?? false,
        deliveryMode:
            (form['deliveryMode'] as DeliveryMode?) ?? DeliveryMode.inPerson,
      );
      _allCourses = <Course>[created, ..._allCourses];
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not create the course.';
    }
  }

  Future<String?> updateCourse(String id, Map<String, dynamic> changes) async {
    try {
      final Course updated = await _courses.update(id, changes);
      final int i = _allCourses.indexWhere((Course c) => c.id == id);
      if (i >= 0) _allCourses[i] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not update the course.';
    }
  }

  Future<String?> togglePublish(Course course) async {
    try {
      final Course updated =
          await _courses.setPublished(course.id, !course.isPublished);
      final int i = _allCourses.indexWhere((Course c) => c.id == course.id);
      if (i >= 0) _allCourses[i] = updated;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not change the publication state.';
    }
  }

  Future<String?> deleteCourse(String id) async {
    try {
      await _courses.delete(id);
      _allCourses.removeWhere((Course c) => c.id == id);
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not delete the course.';
    }
  }

  void reset() {
    _stats = const AdminStats();
    _users = <AppUser>[];
    _allCourses = <Course>[];
    _allBookings = <LabBooking>[];
    _allOrders = <PrintOrder>[];
    _messages = <ContactMessage>[];
    notifyListeners();
  }
}
