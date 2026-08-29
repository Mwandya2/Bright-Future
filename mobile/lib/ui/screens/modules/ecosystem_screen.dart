import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ecosystem_module.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gradient_cover.dart';
import '../../widgets/status_chip.dart';
import 'module_detail_screen.dart';

class EcosystemScreen extends StatelessWidget {
  const EcosystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our ecosystem')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        itemCount: kEcosystemModules.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (BuildContext context, int i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Bright Future is more than a training centre. Here is '
                'everything we are building for the community.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: context.mutedColor,
                ),
              ),
            );
          }
          final EcosystemModule m = kEcosystemModules[i - 1];
          return AppCard(
            padding: const EdgeInsets.all(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ModuleDetailScreen(module: m),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GradientCover(
                  gradientKey: m.cover,
                  height: 84,
                  radius: 10,
                  icon: Icons.auto_awesome_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        m.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: context.inkColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: m.isLive ? 'Live' : 'Coming soon',
                      color: m.isLive ? AppColors.success : AppColors.muted,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  m.summary,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: context.mutedColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
