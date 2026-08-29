import 'package:flutter/material.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _items = <AppNotification>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<AppNotification> items =
        await NotificationService.instance.readInbox();
    await NotificationService.instance.markAllRead();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    await NotificationService.instance.clearInbox();
    if (!mounted) return;
    setState(() => _items = <AppNotification>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clear,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'Nothing here yet',
                  message:
                      'Booking confirmations, print order updates and course '
                      'announcements will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int i) {
                      final AppNotification n = _items[i];
                      return AppCard(
                        onTap: n.route == null
                            ? null
                            : () => Navigator.of(context).pushNamed(n.route!),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: AppColors.softBg(
                                  AppColors.primary,
                                  dark: context.isDark,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 17,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    n.title,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: context.inkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    n.body,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.45,
                                      color: context.mutedColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    Fmt.relative(n.receivedAt),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: context.mutedColor,
                                    ),
                                  ),
                                ],
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
