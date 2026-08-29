import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ecosystem_module.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gradient_cover.dart';
import '../../widgets/status_chip.dart';

class ModuleDetailScreen extends StatelessWidget {
  const ModuleDetailScreen({super.key, required this.module});

  final EcosystemModule module;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(module.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: <Widget>[
          GradientCover(
            gradientKey: module.cover,
            height: 140,
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 18),
          StatusChip(
            label: module.isLive ? 'Live now' : 'Coming soon',
            color: module.isLive ? AppColors.success : AppColors.muted,
          ),
          const SizedBox(height: 12),
          Text(
            module.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
              height: 1.2,
              color: context.inkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            module.tagline,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.bodyColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            module.overview,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.65,
              color: context.bodyColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What you get',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.inkColor,
            ),
          ),
          const SizedBox(height: 12),
          ...module.features.map(
            (ModuleFeature f) => AppCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          f.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: context.inkColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          f.body,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: context.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (module.isLive && module.ctaRoute != null)
            AppButton(
              label: module.ctaLabel ?? 'Open',
              onPressed: () =>
                  Navigator.of(context).pushNamed(module.ctaRoute!),
            )
          else
            AppCard(
              color: context.softCanvas,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.hourglass_empty_rounded,
                    size: 18,
                    color: context.mutedColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This part of the ecosystem is on the way. We will let '
                      'you know the moment it opens.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: context.mutedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
