import 'package:bright_future_mobile/core/utils/formatters.dart';
import 'package:bright_future_mobile/core/utils/validators.dart';
import 'package:bright_future_mobile/data/models/course.dart';
import 'package:bright_future_mobile/data/models/enums.dart';
import 'package:bright_future_mobile/data/models/print_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Print order pricing', () {
    test('mirrors the backend formula for black and white', () {
      expect(
        PrintOrder.estimate(
          serviceType: ServiceType.document,
          copies: 10,
          color: false,
        ),
        2000, // 200 * 10
      );
    });

    test('applies the 1.5x colour multiplier', () {
      expect(
        PrintOrder.estimate(
          serviceType: ServiceType.document,
          copies: 10,
          color: true,
        ),
        3000, // 200 * 10 * 1.5
      );
    });

    test('treats zero or negative copies as one', () {
      expect(
        PrintOrder.estimate(
          serviceType: ServiceType.banner,
          copies: 0,
          color: false,
        ),
        25000,
      );
    });
  });

  group('Enum parsing', () {
    test('reads the Java uppercase form', () {
      expect(OrderStatusX.parse('IN_PROGRESS'), OrderStatus.inProgress);
      expect(
        WorkstationTypeX.parse('PRINTING_STATION'),
        WorkstationType.printingStation,
      );
      expect(UserRoleX.parse('ADMIN'), UserRole.admin);
    });

    test('also reads the web app lowercase form', () {
      expect(OrderStatusX.parse('in_progress'), OrderStatus.inProgress);
      expect(CourseLevelX.parse('advanced'), CourseLevel.advanced);
    });

    test('falls back safely on unknown values', () {
      expect(OrderStatusX.parse('nonsense'), OrderStatus.submitted);
      expect(BookingStatusX.parse(null), BookingStatus.pending);
    });

    test('round-trips back to the API form', () {
      expect(OrderStatus.inProgress.api, 'IN_PROGRESS');
      expect(ServiceType.businessCard.api, 'BUSINESS_CARD');
      expect(WorkstationType.printingStation.api, 'PRINTING_STATION');
    });
  });

  group('Course model', () {
    test('parses a backend payload', () {
      final Course c = Course.fromJson(<String, dynamic>{
        'id': 'abc',
        'title': 'Web Development Fundamentals',
        'slug': 'web-development-fundamentals',
        'level': 'INTERMEDIATE',
        'price': 45000,
        'durationWeeks': 8,
        'category': 'web',
        'isPublished': true,
        'createdAt': '2026-01-15T09:00:00Z',
      });

      expect(c.title, 'Web Development Fundamentals');
      expect(c.level, CourseLevel.intermediate);
      expect(c.isFree, isFalse);
      expect(c.categoryLabel, 'Web Development');
      expect(c.durationLabel, '8 weeks');
      expect(c.createdAt?.year, 2026);
    });

    test('survives a payload full of nulls', () {
      final Course c = Course.fromJson(<String, dynamic>{});
      expect(c.title, 'Untitled course');
      expect(c.price, 0);
      expect(c.isFree, isTrue);
      expect(c.durationLabel, 'Self-paced');
    });
  });

  group('Formatters', () {
    test('shows free courses as Free', () {
      expect(Fmt.price(0), 'Free');
      expect(Fmt.price(null), 'Free');
    });

    test('formats the ISO shapes Spring expects', () {
      expect(Fmt.isoDate(DateTime(2026, 9, 1)), '2026-09-01');
      expect(Fmt.isoTime(9, 5), '09:05:00');
    });

    test('builds initials from a name', () {
      expect(Fmt.initials('Amina Joseph'), 'AJ');
      expect(Fmt.initials('Peter'), 'P');
      expect(Fmt.initials(null), '?');
    });
  });

  group('Tanzanian mobile numbers', () {
    test('normalises every shape people type', () {
      expect(Validators.normalizeTzMobile('0712345678'), '255712345678');
      expect(Validators.normalizeTzMobile('+255 712 345 678'), '255712345678');
      expect(Validators.normalizeTzMobile('255712345678'), '255712345678');
      expect(Validators.normalizeTzMobile('712345678'), '255712345678');
      expect(Validators.normalizeTzMobile('0702279934'), '255702279934');
    });

    test('rejects what cannot be a Tanzanian mobile', () {
      expect(Validators.normalizeTzMobile('071234567'), isNull); // too short
      expect(Validators.normalizeTzMobile('07123456789'), isNull); // too long
      expect(Validators.normalizeTzMobile('0812345678'), isNull); // not 6 or 7
      expect(Validators.normalizeTzMobile(''), isNull);
      expect(Validators.normalizeTzMobile(null), isNull);
    });

    test('the form validator requires a number and explains why', () {
      expect(Validators.tzMobile('0712345678'), isNull);
      expect(Validators.tzMobile(''), isNotNull);
      expect(Validators.tzMobile('123'), isNotNull);
    });
  });

  group('Validators', () {
    test('accepts a normal email and rejects a broken one', () {
      expect(Validators.email('peter@example.com'), isNull);
      expect(Validators.email('peter@'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('enforces the backend minimum password length', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });
}
