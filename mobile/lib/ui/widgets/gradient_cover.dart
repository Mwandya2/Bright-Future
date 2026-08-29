import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The soft gradient panel used as course and module cover art.
class GradientCover extends StatelessWidget {
  const GradientCover({
    super.key,
    this.gradientKey,
    this.height = 120,
    this.radius = 16,
    this.child,
    this.icon,
  });

  final String? gradientKey;
  final double height;
  final double radius;
  final Widget? child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = AppColors.coverFor(gradientKey);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child ??
          (icon == null
              ? null
              : Center(
                  child: Icon(
                    icon,
                    size: height * 0.32,
                    color: AppColors.tint(Colors.white, colors.last, 0.15),
                  ),
                )),
    );
  }
}
