import '../../core/network/api_client.dart';
import '../../core/storage/app_prefs.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/enums.dart';
import '../models/json.dart';

class CourseRepository {
  CourseRepository(this._api);

  final ApiClient _api;

  // ── Catalogue ───────────────────────────────────────────────
  Future<List<Course>> published({String? category}) async {
    final dynamic data = await _api.get(
      '/courses',
      authenticated: false,
      query: <String, dynamic>{
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );
    final List<Course> courses = J.list(data).map(Course.fromJson).toList();
    if (category == null || category.isEmpty) {
      await AppPrefs.instance.cacheJson(
        AppPrefs.cacheCourses,
        courses.map((Course c) => c.toJson()).toList(),
      );
    }
    return courses;
  }

  List<Course> cachedCourses() => AppPrefs.instance
      .readJsonList(AppPrefs.cacheCourses)
      .map(Course.fromJson)
      .toList();

  Future<Course> bySlugOrId(String slugOrId) async {
    final dynamic data =
        await _api.get('/courses/$slugOrId', authenticated: false);
    return Course.fromJson(J.map(data));
  }

  // ── Admin catalogue management ──────────────────────────────
  Future<List<Course>> allIncludingDrafts() async {
    final dynamic data = await _api.get('/courses/all');
    return J.list(data).map(Course.fromJson).toList();
  }

  Future<Course> create({
    required String title,
    required String slug,
    String? summary,
    String? description,
    String category = 'ict',
    CourseLevel level = CourseLevel.beginner,
    int price = 0,
    int durationWeeks = 4,
    String? instructorName,
    String coverGradient = 'mint',
    bool isPublished = false,
  }) async {
    final dynamic data = await _api.post(
      '/courses',
      body: <String, dynamic>{
        'title': title.trim(),
        'slug': slug.trim(),
        'summary': summary,
        'description': description,
        'category': category,
        'level': level.api,
        'price': price,
        'durationWeeks': durationWeeks,
        'instructorName': instructorName,
        'coverGradient': coverGradient,
        'isPublished': isPublished,
      },
    );
    return Course.fromJson(J.map(data));
  }

  Future<Course> update(String id, Map<String, dynamic> changes) async {
    final dynamic data = await _api.put('/courses/$id', body: changes);
    return Course.fromJson(J.map(data));
  }

  Future<Course> setPublished(String id, bool isPublished) async {
    final dynamic data = await _api.patch(
      '/courses/$id/publish',
      query: <String, dynamic>{'isPublished': isPublished},
    );
    return Course.fromJson(J.map(data));
  }

  Future<void> delete(String id) => _api.delete('/courses/$id');

  // ── Enrollments ─────────────────────────────────────────────
  Future<List<Enrollment>> myEnrollments() async {
    final dynamic data = await _api.get('/enrollments/my');
    final List<Enrollment> items =
        J.list(data).map(Enrollment.fromJson).toList();
    await AppPrefs.instance.cacheJson(
      AppPrefs.cacheMyEnrollments,
      items.map((Enrollment e) => e.toJson()).toList(),
    );
    return items;
  }

  List<Enrollment> cachedEnrollments() => AppPrefs.instance
      .readJsonList(AppPrefs.cacheMyEnrollments)
      .map(Enrollment.fromJson)
      .toList();

  Future<Enrollment> enroll(String courseId) async {
    final dynamic data = await _api.post(
      '/enrollments',
      body: <String, dynamic>{'courseId': courseId},
    );
    return Enrollment.fromJson(J.map(data));
  }

  Future<Enrollment> updateProgress(String enrollmentId, int progress) async {
    final int safe = progress < 0 ? 0 : (progress > 100 ? 100 : progress);
    final dynamic data = await _api.patch(
      '/enrollments/$enrollmentId/progress',
      body: <String, dynamic>{'progress': safe},
    );
    return Enrollment.fromJson(J.map(data));
  }
}
