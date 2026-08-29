import 'app_user.dart';
import 'enums.dart';
import 'json.dart';

/// Mirrors `PrintOrderDto` on the backend.
class PrintOrder {
  const PrintOrder({
    required this.id,
    this.user,
    this.serviceType = ServiceType.document,
    this.description,
    this.copies = 1,
    this.color = false,
    this.status = OrderStatus.submitted,
    this.estimatedPrice,
    this.attachmentUrl,
    this.createdAt,
  });

  final String id;
  final AppUser? user;
  final ServiceType serviceType;
  final String? description;
  final int copies;
  final bool color;
  final OrderStatus status;
  final int? estimatedPrice;
  final String? attachmentUrl;
  final DateTime? createdAt;

  bool get isActive =>
      status == OrderStatus.submitted || status == OrderStatus.inProgress;

  /// Same formula as `PrintOrderService.createOrder`.
  static int estimate({
    required ServiceType serviceType,
    required int copies,
    required bool color,
  }) {
    final int safeCopies = copies < 1 ? 1 : copies;
    final double raw = serviceType.unitPrice * safeCopies * (color ? 1.5 : 1.0);
    return raw.round();
  }

  factory PrintOrder.fromJson(Map<String, dynamic> json) => PrintOrder(
        id: J.str(json['id']),
        user: json['user'] == null
            ? null
            : AppUser.fromJson(J.map(json['user'])),
        serviceType:
            ServiceTypeX.parse(json['serviceType'] ?? json['service_type']),
        description: J.strOrNull(json['description']),
        copies: J.intVal(json['copies'], 1),
        color: J.boolVal(json['color']),
        status: OrderStatusX.parse(json['status']),
        estimatedPrice:
            J.intOrNull(json['estimatedPrice'] ?? json['estimated_price']),
        attachmentUrl:
            J.strOrNull(json['attachmentUrl'] ?? json['attachment_url']),
        createdAt: J.date(json['createdAt'] ?? json['created_at']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user': user?.toJson(),
        'serviceType': serviceType.api,
        'description': description,
        'copies': copies,
        'color': color,
        'status': status.api,
        'estimatedPrice': estimatedPrice,
        'attachmentUrl': attachmentUrl,
        'createdAt': createdAt?.toIso8601String(),
      };
}
