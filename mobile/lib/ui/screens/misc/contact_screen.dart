import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final AuthProvider auth = context.read<AuthProvider>();
    _name = TextEditingController(text: auth.user?.displayName ?? '');
    _email = TextEditingController(text: auth.user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);

    try {
      await context.read<ContactRepository>().submit(
            name: _name.text,
            email: _email.text,
            subject: _subject.text,
            message: _message.text,
          );
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.success(context, 'Message sent. We will be in touch soon.');
      _subject.clear();
      _message.clear();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppSnack.error(context, 'Could not send your message. Please try again.');
    }
  }

  Future<void> _launch(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _ContactTile(
                  icon: Icons.call_outlined,
                  label: 'Call',
                  value: AppConfig.supportPhone,
                  onTap: () => _launch(
                    Uri(scheme: 'tel', path: AppConfig.supportPhone),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: AppConfig.supportEmail,
                  onTap: () => _launch(
                    Uri(scheme: 'mailto', path: AppConfig.supportEmail),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Send us a message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.inkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Questions about courses, the lab or a print job - we read every '
            'message.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: context.mutedColor,
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                AppTextField(
                  label: 'Your name',
                  controller: _name,
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalizationWords: true,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      Validators.required(v, field: 'Name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email address',
                  controller: _email,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Subject (optional)',
                  controller: _subject,
                  hint: 'What is this about?',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Message',
                  controller: _message,
                  hint: 'Tell us how we can help',
                  maxLines: 6,
                  minLines: 4,
                  maxLength: 1000,
                  validator: (String? v) =>
                      Validators.minLength(v, 10, field: 'Your message'),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Send message',
                  busy: _busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: context.mutedColor),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: context.inkColor,
            ),
          ),
        ],
      ),
    );
  }
}
