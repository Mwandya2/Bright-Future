import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/lab_booking.dart';
import '../../../providers/booking_provider.dart';
import '../../../routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/info_row.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/skeletons.dart';
import '../../widgets/status_chip.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BookingProvider p = context.read<BookingProvider>();
      if (p.bookings.isEmpty) p.load();
    });
  }

  Future<void> _confirmCancel(LabBooking booking) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: Text(
          '${booking.workstationType.label} on '
          '${Fmt.date(booking.bookingDate)} at ${Fmt.time(booking.startTime)}.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );

    if (yes != true || !mounted) return;
    final String? error = await context.read<BookingProvider>().cancel(booking.id);
    if (!mounted) return;
    if (error == null) {
      AppSnack.success(context, 'Booking cancelled.');
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BookingProvider provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Computer lab'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(Routes.newBooking),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          const OfflineBanner(),
          Expanded(child: _body(context, provider)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, BookingProvider provider) {
    if (provider.loading && provider.bookings.isEmpty) {
      return const SkeletonList(count: 3);
    }
    if (provider.error != null && provider.bookings.isEmpty) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => provider.load(),
      );
    }
    if (provider.bookings.isEmpty) {
      return EmptyState(
        icon: Icons.desktop_windows_outlined,
        title: 'No bookings yet',
        message:
            'Reserve a computer, gaming or research workstation and it will '
            'show up here.',
        actionLabel: 'Book a workstation',
        onAction: () => Navigator.of(context).pushNamed(Routes.newBooking),
      );
    }

    final List<LabBooking> upcoming = provider.upcoming;
    final List<LabBooking> past = provider.past;

    return RefreshIndicator(
      onRefresh: () => provider.load(refresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
        children: <Widget>[
          if (upcoming.isNotEmpty) ...<Widget>[
            _label(context, 'Upcoming'),
            ...upcoming.map(
              (LabBooking b) => _BookingCard(
                booking: b,
                onCancel: () => _confirmCancel(b),
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (past.isNotEmpty) ...<Widget>[
            _label(context, 'History'),
            ...past.map((LabBooking b) => _BookingCard(booking: b)),
          ],
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: context.mutedColor,
          ),
        ),
      );
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, this.onCancel});

  final LabBooking booking;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.softBg(AppColors.mint, dark: context.isDark),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.event_seat_outlined,
                  size: 19,
                  color: AppColors.mint,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  booking.workstationType.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.inkColor,
                  ),
                ),
              ),
              StatusChip.booking(booking.status),
            ],
          ),
          const SizedBox(height: 10),
          InfoRow(
            label: 'Date',
            value: Fmt.dateLong(booking.bookingDate),
          ),
          InfoRow(
            label: 'Time',
            value:
                '${Fmt.time(booking.startTime)} for ${booking.durationHours}h',
          ),
          if ((booking.notes ?? '').isNotEmpty)
            InfoRow(label: 'Notes', value: booking.notes!),
          if (onCancel != null && booking.isCancellable) ...<Widget>[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Cancel booking'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
