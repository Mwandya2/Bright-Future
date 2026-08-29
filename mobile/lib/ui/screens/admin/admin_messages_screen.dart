import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/contact_message.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/user_avatar.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadMessages();
    });
  }

  Future<void> _reply(ContactMessage m) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: m.email,
      queryParameters: <String, String>{
        'subject': 'Re: ${m.subject ?? 'Your message to Bright Future'}',
      },
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final AdminProvider admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Contact messages')),
      body: admin.loading && admin.messages.isEmpty
          ? const SkeletonList(count: 4)
          : admin.error != null && admin.messages.isEmpty
              ? ErrorView(
                  message: admin.error!,
                  onRetry: () => admin.loadMessages(),
                )
              : admin.messages.isEmpty
                  ? const EmptyState(
                      icon: Icons.mark_email_read_outlined,
                      title: 'No messages',
                      message:
                          'Enquiries sent from the website and the app land here.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => admin.loadMessages(refresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                        itemCount: admin.messages.length,
                        itemBuilder: (BuildContext context, int i) {
                          final ContactMessage m = admin.messages[i];
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    UserAvatar(name: m.name, size: 38),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            m.name,
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: context.inkColor,
                                            ),
                                          ),
                                          Text(
                                            m.email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: context.mutedColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      Fmt.relative(m.createdAt),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: context.mutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if ((m.subject ?? '').isNotEmpty) ...<Widget>[
                                  Text(
                                    m.subject!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.inkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                                Text(
                                  m.message,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.55,
                                    color: context.bodyColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _reply(m),
                                    icon: const Icon(
                                      Icons.reply_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('Reply by email'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
