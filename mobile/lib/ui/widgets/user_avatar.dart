import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.accent = AppColors.primary,
  });

  final String? name;
  final double size;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: AppColors.softBg(accent, dark: dark),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.softBorder(accent, dark: dark)),
      ),
      alignment: Alignment.center,
      child: Text(
        Fmt.initials(name),
        style: TextStyle(
          color: accent,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
