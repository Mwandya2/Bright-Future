import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

/// The single button used across the app, so every screen inherits the same
/// radius, height and pressed state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.busy = false,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool busy;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || busy;
    final bool dark = context.isDark;

    late final Color background;
    late final Color foreground;
    late final Color border;

    switch (variant) {
      case AppButtonVariant.primary:
        background = AppColors.primary;
        foreground = Colors.white;
        border = AppColors.primary;
        break;
      case AppButtonVariant.secondary:
        background = dark ? AppColors.darkSurfaceElevated : Colors.white;
        foreground = dark ? AppColors.onDark : AppColors.ink;
        border = dark ? AppColors.darkHairline : AppColors.hairline;
        break;
      case AppButtonVariant.ghost:
        background = Colors.transparent;
        foreground = dark ? AppColors.onDark : AppColors.primary;
        border = Colors.transparent;
        break;
      case AppButtonVariant.danger:
        background = AppColors.error;
        foreground = Colors.white;
        border = AppColors.error;
        break;
    }

    final Widget content = busy
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: compact ? 14 : 15.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: disabled && !busy ? 0.5 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            height: compact ? 42 : 52,
            width: expand ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
