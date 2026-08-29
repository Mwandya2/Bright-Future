import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A hairline-bordered surface. Used instead of Material [Card] so styling is
/// identical on every Flutter version.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.radius = AppTheme.radiusLg,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius r = BorderRadius.circular(radius);
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.cardColor,
        borderRadius: r,
        border: Border.all(color: borderColor ?? context.hairlineColor),
      ),
      child: child,
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: r,
                child: content,
              ),
            ),
    );
  }
}
