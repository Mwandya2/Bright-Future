import 'json.dart';

// ── Roles ─────────────────────────────────────────────────────
enum UserRole { student, instructor, admin }

extension UserRoleX on UserRole {
  String get api => name.toUpperCase();

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.instructor:
        return 'Instructor';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  bool get isAdmin => this == UserRole.admin;

  static UserRole parse(dynamic value) {
    switch (J.enumKey(value, 'STUDENT')) {
      case 'ADMIN':
        return UserRole.admin;
      case 'INSTRUCTOR':
        return UserRole.instructor;
      default:
        return UserRole.student;
    }
  }
}

// ── Course level ──────────────────────────────────────────────
/// How a course reaches the student. Decides whether iOS may take payment for
/// it in-app: Apple forbids third-party payment for content consumed inside an
/// app, but requires it for services consumed elsewhere - such as training
/// delivered in person at the hub.
enum DeliveryMode { inPerson, online }

extension DeliveryModeX on DeliveryMode {
  String get api => this == DeliveryMode.inPerson ? 'IN_PERSON' : 'ONLINE';

  String get label =>
      this == DeliveryMode.inPerson ? 'In person at the hub' : 'Online';

  static DeliveryMode parse(dynamic value) {
    // Defaults to in-person: that is the backend default, and the safe
    // reading if the field is ever missing from an older payload.
    return J.enumKey(value, 'IN_PERSON') == 'ONLINE'
        ? DeliveryMode.online
        : DeliveryMode.inPerson;
  }
}

enum CourseLevel { beginner, intermediate, advanced }

extension CourseLevelX on CourseLevel {
  String get api => name.toUpperCase();

  String get label {
    switch (this) {
      case CourseLevel.beginner:
        return 'Beginner';
      case CourseLevel.intermediate:
        return 'Intermediate';
      case CourseLevel.advanced:
        return 'Advanced';
    }
  }

  static CourseLevel parse(dynamic value) {
    switch (J.enumKey(value, 'BEGINNER')) {
      case 'INTERMEDIATE':
        return CourseLevel.intermediate;
      case 'ADVANCED':
        return CourseLevel.advanced;
      default:
        return CourseLevel.beginner;
    }
  }
}

// ── Enrollment status ─────────────────────────────────────────
enum EnrollmentStatus { active, completed, cancelled }

extension EnrollmentStatusX on EnrollmentStatus {
  String get api => name.toUpperCase();

  String get label {
    switch (this) {
      case EnrollmentStatus.active:
        return 'In progress';
      case EnrollmentStatus.completed:
        return 'Completed';
      case EnrollmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  static EnrollmentStatus parse(dynamic value) {
    switch (J.enumKey(value, 'ACTIVE')) {
      case 'COMPLETED':
        return EnrollmentStatus.completed;
      case 'CANCELLED':
        return EnrollmentStatus.cancelled;
      default:
        return EnrollmentStatus.active;
    }
  }
}

// ── Workstation type ──────────────────────────────────────────
enum WorkstationType { computer, gaming, research, printingStation }

extension WorkstationTypeX on WorkstationType {
  String get api {
    switch (this) {
      case WorkstationType.printingStation:
        return 'PRINTING_STATION';
      default:
        return name.toUpperCase();
    }
  }

  String get label {
    switch (this) {
      case WorkstationType.computer:
        return 'Computer workstation';
      case WorkstationType.gaming:
        return 'Gaming station';
      case WorkstationType.research:
        return 'Research station';
      case WorkstationType.printingStation:
        return 'Printing station';
    }
  }

  String get blurb {
    switch (this) {
      case WorkstationType.computer:
        return 'General purpose PC with high-speed internet.';
      case WorkstationType.gaming:
        return 'High-performance rig for gaming and 3D work.';
      case WorkstationType.research:
        return 'Quiet desk for study, research and writing.';
      case WorkstationType.printingStation:
        return 'Self-service printing and scanning terminal.';
    }
  }

  static const List<WorkstationType> all = <WorkstationType>[
    WorkstationType.computer,
    WorkstationType.gaming,
    WorkstationType.research,
    WorkstationType.printingStation,
  ];

  static WorkstationType parse(dynamic value) {
    switch (J.enumKey(value, 'COMPUTER')) {
      case 'GAMING':
        return WorkstationType.gaming;
      case 'RESEARCH':
        return WorkstationType.research;
      case 'PRINTING_STATION':
        return WorkstationType.printingStation;
      default:
        return WorkstationType.computer;
    }
  }
}

// ── Booking status ────────────────────────────────────────────
enum BookingStatus { pending, confirmed, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get api => name.toUpperCase();

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  static const List<BookingStatus> all = <BookingStatus>[
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  static BookingStatus parse(dynamic value) {
    switch (J.enumKey(value, 'PENDING')) {
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

// ── Print service type ────────────────────────────────────────
enum ServiceType { document, poster, banner, businessCard, photo }

extension ServiceTypeX on ServiceType {
  String get api {
    switch (this) {
      case ServiceType.businessCard:
        return 'BUSINESS_CARD';
      default:
        return name.toUpperCase();
    }
  }

  String get label {
    switch (this) {
      case ServiceType.document:
        return 'Document printing';
      case ServiceType.poster:
        return 'Poster';
      case ServiceType.banner:
        return 'Banner';
      case ServiceType.businessCard:
        return 'Business cards';
      case ServiceType.photo:
        return 'Photo print';
    }
  }

  /// Mirrors `PrintOrderService.BASE_PRICES` so the app can show a live
  /// estimate before the order is submitted.
  int get unitPrice {
    switch (this) {
      case ServiceType.document:
        return 200;
      case ServiceType.poster:
        return 8000;
      case ServiceType.banner:
        return 25000;
      case ServiceType.businessCard:
        return 15000;
      case ServiceType.photo:
        return 1000;
    }
  }

  static const List<ServiceType> all = <ServiceType>[
    ServiceType.document,
    ServiceType.poster,
    ServiceType.banner,
    ServiceType.businessCard,
    ServiceType.photo,
  ];

  static ServiceType parse(dynamic value) {
    switch (J.enumKey(value, 'DOCUMENT')) {
      case 'POSTER':
        return ServiceType.poster;
      case 'BANNER':
        return ServiceType.banner;
      case 'BUSINESS_CARD':
        return ServiceType.businessCard;
      case 'PHOTO':
        return ServiceType.photo;
      default:
        return ServiceType.document;
    }
  }
}

// ── Print order status ────────────────────────────────────────
enum OrderStatus { submitted, inProgress, ready, collected, cancelled }

extension OrderStatusX on OrderStatus {
  String get api {
    switch (this) {
      case OrderStatus.inProgress:
        return 'IN_PROGRESS';
      default:
        return name.toUpperCase();
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.submitted:
        return 'Submitted';
      case OrderStatus.inProgress:
        return 'In progress';
      case OrderStatus.ready:
        return 'Ready for collection';
      case OrderStatus.collected:
        return 'Collected';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static const List<OrderStatus> all = <OrderStatus>[
    OrderStatus.submitted,
    OrderStatus.inProgress,
    OrderStatus.ready,
    OrderStatus.collected,
    OrderStatus.cancelled,
  ];

  static OrderStatus parse(dynamic value) {
    switch (J.enumKey(value, 'SUBMITTED')) {
      case 'IN_PROGRESS':
        return OrderStatus.inProgress;
      case 'READY':
        return OrderStatus.ready;
      case 'COLLECTED':
        return OrderStatus.collected;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.submitted;
    }
  }
}

/// Course categories, matching `CATEGORY_LABELS` in the web app.
class CourseCategories {
  const CourseCategories._();

  static const Map<String, String> labels = <String, String>{
    'ict': 'ICT Fundamentals',
    'web': 'Web Development',
    'design': 'Graphic Design',
    'data': 'Data & AI',
    'office': 'Office & Productivity',
    'networking': 'Networking',
  };

  static List<String> get keys => labels.keys.toList();

  static String label(String? key) =>
      labels[key ?? ''] ?? (key == null || key.isEmpty ? 'General' : key);
}
