import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../data/models/course.dart';
import '../data/models/enrollment.dart';
import '../data/repositories/course_repository.dart';
import 'load_state.dart';

class CourseProvider extends ChangeNotifier with LoadState {
  CourseProvider(this._repo);

  final CourseRepository _repo;

  List<Course> _courses = <Course>[];
  List<Enrollment> _enrollments = <Enrollment>[];
  String _search = '';
  String? _category;
  bool _loadedOnce = false;

  List<Course> get courses => _courses;
  List<Enrollment> get enrollments => _enrollments;
  String get search => _search;
  String? get category => _category;
  bool get loadedOnce => _loadedOnce;

  List<Course> get visibleCourses {
    final String q = _search.trim().toLowerCase();
    return _courses.where((Course c) {
      final bool matchesCategory =
          _category == null || _category!.isEmpty || c.category == _category;
      if (!matchesCategory) return false;
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          (c.summary ?? '').toLowerCase().contains(q) ||
          (c.instructorName ?? '').toLowerCase().contains(q) ||
          c.categoryLabel.toLowerCase().contains(q);
    }).toList();
  }

  List<Enrollment> get activeEnrollments =>
      _enrollments.where((Enrollment e) => !e.isComplete).toList();

  List<Enrollment> get completedEnrollments =>
      _enrollments.where((Enrollment e) => e.isComplete).toList();

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _category = value;
    notifyListeners();
  }

  Enrollment? enrollmentFor(String courseId) {
    for (final Enrollment e in _enrollments) {
      if (e.course?.id == courseId) return e;
    }
    return null;
  }

  bool isEnrolled(String courseId) => enrollmentFor(courseId) != null;

  Future<void> loadCatalogue({bool refresh = false}) async {
    beginLoad(refresh: refresh);
    try {
      _courses = await _repo.published();
      _loadedOnce = true;
      endLoad();
    } on ApiException catch (e) {
      final List<Course> cached = _repo.cachedCourses();
      if (cached.isNotEmpty) {
        _courses = cached;
        _loadedOnce = true;
        endLoad(fromCache: true);
      } else {
        endLoad(error: e.message);
      }
    } catch (_) {
      endLoad(error: 'Could not load courses. Please try again.');
    }
  }

  Future<void> loadEnrollments({bool refresh = false}) async {
    beginLoad(refresh: refresh);
    try {
      _enrollments = await _repo.myEnrollments();
      endLoad();
    } on ApiException catch (e) {
      final List<Enrollment> cached = _repo.cachedEnrollments();
      if (cached.isNotEmpty) {
        _enrollments = cached;
        endLoad(fromCache: true);
      } else {
        endLoad(error: e.message);
      }
    } catch (_) {
      endLoad(error: 'Could not load your courses.');
    }
  }

  Future<void> loadAll({bool refresh = false}) async {
    await loadCatalogue(refresh: refresh);
    await loadEnrollments(refresh: refresh);
  }

  /// Returns null on success, or a message describing the failure.
  Future<String?> enroll(String courseId) async {
    try {
      final Enrollment created = await _repo.enroll(courseId);
      final int index =
          _enrollments.indexWhere((Enrollment e) => e.id == created.id);
      if (index >= 0) {
        _enrollments[index] = created;
      } else {
        _enrollments = <Enrollment>[created, ..._enrollments];
      }
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not complete the enrolment. Please try again.';
    }
  }

  Future<String?> setProgress(String enrollmentId, int progress) async {
    try {
      final Enrollment updated =
          await _repo.updateProgress(enrollmentId, progress);
      final int index =
          _enrollments.indexWhere((Enrollment e) => e.id == enrollmentId);
      if (index >= 0) {
        _enrollments[index] = updated;
        notifyListeners();
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not save your progress.';
    }
  }

  Future<Course?> fetchCourse(String slugOrId) async {
    try {
      return await _repo.bySlugOrId(slugOrId);
    } catch (_) {
      for (final Course c in _courses) {
        if (c.id == slugOrId || c.slug == slugOrId) return c;
      }
      return null;
    }
  }

  void reset() {
    _courses = <Course>[];
    _enrollments = <Enrollment>[];
    _loadedOnce = false;
    _search = '';
    _category = null;
    notifyListeners();
  }
}
