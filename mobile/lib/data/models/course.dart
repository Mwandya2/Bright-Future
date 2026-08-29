import 'enums.dart';
import 'json.dart';

/// Mirrors `CourseDto` on the backend.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.description,
    this.category,
    this.level = CourseLevel.beginner,
    this.price = 0,
    this.durationWeeks,
    this.instructorName,
    this.coverGradient,
    this.isPublished = true,
    this.deliveryMode = DeliveryMode.inPerson,
    this.createdAt,
  });

  final String id;
  final String title;
  final String slug;
  final String? summary;
  final String? description;
  final String? category;
  final CourseLevel level;
  final int price;
  final int? durationWeeks;
  final String? instructorName;
  final String? coverGradient;
  final bool isPublished;
  final DeliveryMode deliveryMode;
  final DateTime? createdAt;

  bool get isFree => price <= 0;

  String get categoryLabel => CourseCategories.label(category);

  String get durationLabel {
    final int? w = durationWeeks;
    if (w == null || w <= 0) return 'Self-paced';
    return w == 1 ? '1 week' : '$w weeks';
  }

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: J.str(json['id']),
        title: J.str(json['title'], 'Untitled course'),
        slug: J.str(json['slug']),
        summary: J.strOrNull(json['summary']),
        description: J.strOrNull(json['description']),
        category: J.strOrNull(json['category']),
        level: CourseLevelX.parse(json['level']),
        price: J.intVal(json['price']),
        durationWeeks:
            J.intOrNull(json['durationWeeks'] ?? json['duration_weeks']),
        instructorName:
            J.strOrNull(json['instructorName'] ?? json['instructor_name']),
        coverGradient:
            J.strOrNull(json['coverGradient'] ?? json['cover_gradient']),
        isPublished:
            J.boolVal(json['isPublished'] ?? json['is_published'], true),
        deliveryMode: DeliveryModeX.parse(
          json['deliveryMode'] ?? json['delivery_mode'],
        ),
        createdAt: J.date(json['createdAt'] ?? json['created_at']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'slug': slug,
        'summary': summary,
        'description': description,
        'category': category,
        'level': level.api,
        'price': price,
        'durationWeeks': durationWeeks,
        'instructorName': instructorName,
        'coverGradient': coverGradient,
        'deliveryMode': deliveryMode.api,
        'isPublished': isPublished,
        'createdAt': createdAt?.toIso8601String(),
      };
}
