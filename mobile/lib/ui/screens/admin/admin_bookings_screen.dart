import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/lab_booking.dart';
import '../../../providers/admin_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/info_row.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_chip.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  BookingStatus? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadBookings();
    });
  }

  Future<void> _changeStatus(LabBooking booking) async {
    final BookingStatus? status = await showModalBottomSheet<BookingStatus>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Update booking status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sheetContext.inkColor,
                ),
              ),
            ),
            ...BookingStatusX.all.map(
              (BookingStatus s) => ListTile(
                leading: Icon(
                  s == booking.status
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: s == booking.status
                      ? AppColors.primary
                      : sheetContext.mutedColor,
                ),
                title: Text(s.label),
                onTap: () => Navigator.of(sheetContext).pop(s),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (status == null || status == booking.status || !mounted) return;
    final String? error = await context
        .read<AdminProvider>()
        .setBookingStatus(booking.id, status);
    if (!mounted) return;
    if (error == null) {
      AppSnack.success(context, 'Booking marked ${status.label.toLowerCase()}.');
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AdminProvider admin = context.watch<AdminProvider>();
    final List<LabBooking> items = _filter == null
        ? admin.allBookings
        : admin.allBookings
            .where((LabBooking b) => b.status == _filter)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Lab bookings')),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                ),
                ...BookingStatusX.all.map(
                  (BookingStatus s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.label),
                      selected: _filter == s,
                      onSelected: (_) => setState(() => _filter = s),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: admin.loading && admin.allBookings.isEmpty
                ? const SkeletonList(count: 4)
                : admin.error != null && admin.allBookings.isEmpty
                    ? ErrorView(
                        message: admin.error!,
                        onRetry: () => admin.loadBookings(),
                      )
                    : items.isEmpty
                        ? const EmptyState(
                            icon: Icons.event_busy_outlined,
                            title: 'No bookings here',
                            message:
                                'Nothing matches this filter right now.',
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                admin.loadBookings(refresh: true),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 32),
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int i) {
                                final LabBooking b = items[i];
                                return AppCard(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  onTap: () => _changeStatus(b),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              b.user?.displayName ?? 'Member',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: context.inkColor,
                                              ),
                                            ),
                                          ),
                                          StatusChip.booking(b.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      InfoRow(
                                        label: 'Workstation',
                                        value: b.workstationType.label,
                                      ),
                                      InfoRow(
                                        label: 'When',
                                        value:
                                            '${Fmt.date(b.bookingDate)} at '
                                            '${Fmt.time(b.startTime)} '
                                            '(${b.durationHours}h)',
                                      ),
                                      if (b.user?.email != null)
                                        InfoRow(
                                          label: 'Email',
                                          value: b.user!.email,
                                        ),
                                      if ((b.notes ?? '').isNotEmpty)
                                        InfoRow(
                                          label: 'Notes',
                                          value: b.notes!,
                                        ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () => _changeStatus(b),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                          ),
                                          label: const Text('Change status'),
                                        ),
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
