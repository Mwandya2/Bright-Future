import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/enums.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_avatar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  Future<void> _changeRole(AppUser user) async {
    final UserRole? role = await showModalBottomSheet<UserRole>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Set role for ${user.displayName}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sheetContext.inkColor,
                ),
              ),
            ),
            // The backend guards the ADMIN role, so only these two are offered.
            ...<UserRole>[UserRole.student, UserRole.instructor].map(
              (UserRole r) => ListTile(
                leading: Icon(
                  r == user.role
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: r == user.role
                      ? AppColors.primary
                      : sheetContext.mutedColor,
                ),
                title: Text(r.label),
                onTap: () => Navigator.of(sheetContext).pop(r),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (role == null || role == user.role || !mounted) return;
    final String? error =
        await context.read<AdminProvider>().setUserRole(user.id, role);
    if (!mounted) return;
    if (error == null) {
      AppSnack.success(context, '${user.displayName} is now ${role.label}.');
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AdminProvider admin = context.watch<AdminProvider>();
    final String q = _query.trim().toLowerCase();
    final List<AppUser> users = admin.users
        .where((AppUser u) =>
            q.isEmpty ||
            u.displayName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Users & roles')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: TextField(
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: context.softCanvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.hairlineColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.hairlineColor),
                ),
              ),
            ),
          ),
          Expanded(
            child: admin.loading && admin.users.isEmpty
                ? const SkeletonList(count: 5, itemHeight: 70)
                : admin.error != null && admin.users.isEmpty
                    ? ErrorView(
                        message: admin.error!,
                        onRetry: () => admin.loadUsers(),
                      )
                    : users.isEmpty
                        ? const EmptyState(
                            icon: Icons.people_outline_rounded,
                            title: 'No users found',
                            message: 'Nobody matches that search.',
                          )
                        : RefreshIndicator(
                            onRefresh: () => admin.loadUsers(refresh: true),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 32),
                              itemCount: users.length,
                              itemBuilder: (BuildContext context, int i) {
                                final AppUser u = users[i];
                                return AppCard(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  onTap: () => _changeRole(u),
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: <Widget>[
                                      UserAvatar(name: u.displayName, size: 40),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              u.displayName,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600,
                                                color: context.inkColor,
                                              ),
                                            ),
                                            Text(
                                              u.email,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: context.mutedColor,
                                              ),
                                            ),
                                            Text(
                                              'Joined ${Fmt.date(u.createdAt)}',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: context.mutedColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusChip(
                                        label: u.role.label,
                                        color: u.isAdmin
                                            ? AppColors.ruby
                                            : AppColors.primary,
                                        dense: true,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
