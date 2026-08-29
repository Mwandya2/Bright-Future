import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/course.dart';
import '../../data/models/enrollment.dart';
import 'app_card.dart';
import 'gradient_cover.dart';
import 'status_chip.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.enrollment,
  });

  final Course course;
  final VoidCallback? onTap;
  final Enrollment? enrollment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GradientCover(
            gradientKey: course.coverGradient,
            height: 92,
            radius: 10,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              StatusChip.level(course.level),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  course.categoryLabel,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: context.mutedColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // The title and summary share whatever height is left in the grid
          // cell. Without this the card is a fixed-height column and overflows
          // as soon as the cell is short - at a large system font scale, or on
          // a narrow phone.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.25,
                      color: context.inkColor,
                    ),
                  ),
                ),
                if ((course.summary ?? '').isNotEmpty) ...<Widget>[
                  const SizedBox(height: 5),
                  Flexible(
                    child: Text(
                      course.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: context.mutedColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (enrollment != null) ...<Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: enrollment!.progressFraction,
                minHeight: 5,
                backgroundColor: context.hairlineColor,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '${enrollment!.progress}% complete',
              style: TextStyle(fontSize: 12, color: context.mutedColor),
            ),
          ] else
            // A long price like "TSh 450,000" plus "8 weeks" is wider than a
            // two-column card. Scaling the whole row down keeps both values
            // fully readable, where ellipsis would hide the price.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    Fmt.price(course.price),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: context.inkColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: context.mutedColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    course.durationLabel,
                    maxLines: 1,
                    style: TextStyle(fontSize: 12, color: context.mutedColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
