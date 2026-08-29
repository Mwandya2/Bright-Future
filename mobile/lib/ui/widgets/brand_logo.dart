import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 34,
    this.showWordmark = true,
    this.wordmarkColor,
  });

  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.primary, AppColors.mint],
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'BF',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (showWordmark) ...<Widget>[
          const SizedBox(width: 10),
          Text(
            AppConfig.appName,
            style: TextStyle(
              fontSize: size * 0.47,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: wordmarkColor ?? context.inkColor,
            ),
          ),
        ],
      ],
    );
  }
}
