import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../providers/booking_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_header.dart';

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({super.key});

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  WorkstationType _type = WorkstationType.computer;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  int _duration = 1;
  final TextEditingController _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 120)),
      helpText: 'Choose your lab date',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Choose a start time',
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final String? error = await context.read<BookingProvider>().create(
          type: _type,
          date: _date,
          hour: _time.hour,
          minute: _time.minute,
          durationHours: _duration,
          notes: _notes.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (error == null) {
      AppSnack.success(context, 'Booking requested. We will confirm shortly.');
      Navigator.of(context).pop();
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a workstation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
        children: <Widget>[
          const SectionHeader(
            title: 'Workstation',
            subtitle: 'What do you need the machine for?',
          ),
          ...WorkstationTypeX.all.map(
            (WorkstationType t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => setState(() => _type = t),
                borderColor: _type == t ? AppColors.primary : null,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _type == t
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: _type == t
                          ? AppColors.primary
                          : context.mutedColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            t.label,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: context.inkColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.blurb,
                            style: TextStyle(
                              fontSize: 12.5,
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
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'When',
            subtitle: 'Pick a date, a start time and how long you need',
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _PickerTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: Fmt.date(_date),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PickerTile(
                  icon: Icons.schedule_rounded,
                  label: 'Start time',
                  value: _time.format(context),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Duration',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: context.inkColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List<Widget>.generate(8, (int i) {
              final int hours = i + 1;
              final bool selected = _duration == hours;
              return ChoiceChip(
                label: Text('${hours}h'),
                selected: selected,
                onSelected: (_) => setState(() => _duration = hours),
              );
            }),
          ),
          const SizedBox(height: 22),
          AppTextField(
            label: 'Notes (optional)',
            controller: _notes,
            hint: 'Anything the lab team should know',
            maxLines: 3,
            minLines: 2,
            maxLength: 240,
          ),
          const SizedBox(height: 22),
          AppCard(
            color: context.softCanvas,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: context.mutedColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bookings start as pending. The lab team confirms them and '
                    'you will get a notification.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: context.mutedColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          AppButton(
            label: 'Request booking',
            busy: _busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
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
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.inkColor,
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
