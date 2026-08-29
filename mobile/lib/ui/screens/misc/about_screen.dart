import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/brand_logo.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = 'Version ${info.version} (${info.buildNumber})');
    } catch (_) {}
  }

  Future<void> _open(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 40),
        children: <Widget>[
          const Center(child: BrandLogo(size: 54)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppConfig.longName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.inkColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              _version,
              style: TextStyle(fontSize: 12.5, color: context.mutedColor),
            ),
          ),
          const SizedBox(height: 28),
          AppCard(
            child: Text(
              'Bright Future Digital Hub is a community technology centre: an '
              'ICT training academy, a computer lab with managed internet, and '
              'a digital printing and media service - with a freelance '
              'marketplace, business hub, career centre and tech community on '
              'the way.\n\nThis app puts all of it in your pocket: enrol in '
              'courses and track your progress, reserve a workstation, submit '
              'print jobs with a live price estimate, and stay in touch with '
              'the team.',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.65,
                color: context.bodyColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LinkTile(
            icon: Icons.language_rounded,
            label: 'Visit our website',
            onTap: () => _open(AppConfig.websiteUrl),
          ),
          _LinkTile(
            icon: Icons.mail_outline_rounded,
            label: 'Contact the hub',
            onTap: () => Navigator.of(context).pushNamed(Routes.contact),
          ),
          _LinkTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy policy',
            onTap: () => _open(AppConfig.privacyUrl),
          ),
          _LinkTile(
            icon: Icons.gavel_rounded,
            label: 'Terms of service',
            onTap: () => _open(AppConfig.termsUrl),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '(c) ${DateTime.now().year} ${AppConfig.longName}',
              style: TextStyle(fontSize: 12, color: context.mutedColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: context.inkColor,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: context.mutedColor,
          ),
        ],
      ),
    );
  }
}
