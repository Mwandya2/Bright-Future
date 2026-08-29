import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/enums.dart';

/// Small coloured pill used for statuses, levels and categories.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  factory StatusChip.booking(BookingStatus status) {
    late Color c;
    switch (status) {
      case BookingStatus.pending:
        c = AppColors.warning;
        break;
      case BookingStatus.confirmed:
        c = AppColors.success;
        break;
      case BookingStatus.completed:
        c = AppColors.info;
        break;
      case BookingStatus.cancelled:
        c = AppColors.error;
        break;
    }
    return StatusChip(label: status.label, color: c);
  }

  factory StatusChip.order(OrderStatus status) {
    late Color c;
    switch (status) {
      case OrderStatus.submitted:
        c = AppColors.info;
        break;
      case OrderStatus.inProgress:
        c = AppColors.warning;
        break;
      case OrderStatus.ready:
        c = AppColors.success;
        break;
      case OrderStatus.collected:
        c = AppColors.muted;
        break;
      case OrderStatus.cancelled:
        c = AppColors.error;
        break;
    }
    return StatusChip(label: status.label, color: c);
  }

  factory StatusChip.enrollment(EnrollmentStatus status) {
    late Color c;
    switch (status) {
      case EnrollmentStatus.active:
        c = AppColors.primary;
        break;
      case EnrollmentStatus.completed:
        c = AppColors.success;
        break;
      case EnrollmentStatus.cancelled:
        c = AppColors.error;
        break;
    }
    return StatusChip(label: status.label, color: c);
  }

  factory StatusChip.level(CourseLevel level) {
    late Color c;
    switch (level) {
      case CourseLevel.beginner:
        c = AppColors.success;
        break;
      case CourseLevel.intermediate:
        c = AppColors.info;
        break;
      case CourseLevel.advanced:
        c = AppColors.ruby;
        break;
    }
    return StatusChip(label: level.label, color: c, dense: true);
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.softBg(color, dark: dark),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.softBorder(color, dark: dark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
