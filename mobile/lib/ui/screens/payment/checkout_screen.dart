import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/course.dart';
import '../../../data/models/enums.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/info_row.dart';

/// Pops with `true` once the student is entitled to enrol - either because a
/// mobile money payment settled, or because they reserved a place to pay
/// elsewhere.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.course});

  final Course course;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();

  bool _busy = false;

  /// Set once the PIN prompt is on its way; the screen then shows the waiting
  /// state instead of the form.
  String? _orderReference;
  String _waitingMessage = '';
  Timer? _poll;
  int _elapsedSeconds = 0;

  /// Mobile money rarely takes longer than this. After it, the customer is
  /// offered the reference so the hub can confirm manually.
  static const int _timeoutSeconds = 150;
  static const Duration _pollInterval = Duration(seconds: 3);

  @override
  void dispose() {
    _poll?.cancel();
    _phone.dispose();
    super.dispose();
  }

  // ── Mobile money (Android) ───────────────────────────────────

  Future<void> _startPayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() => _busy = true);
    final PaymentResult result =
        await context.read<PaymentService>().startCoursePayment(
              courseId: widget.course.id,
              phoneNumber: _phone.text,
            );
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result.status) {
      case PaymentStatus.pending:
      case PaymentStatus.success:
        setState(() {
          _orderReference = result.orderReference;
          _waitingMessage =
              result.message ?? 'Check your phone and enter your PIN.';
          _elapsedSeconds = 0;
        });
        // A push can settle before the first poll, so handle that too.
        if (result.isSuccess) {
          _onPaid();
        } else {
          _startPolling();
        }
        break;
      case PaymentStatus.notConfigured:
        _showPayAtDeskSheet(result.message);
        break;
      case PaymentStatus.cancelled:
        AppSnack.info(context, result.message ?? 'Payment cancelled.');
        break;
      case PaymentStatus.failed:
        AppSnack.error(context, result.message ?? 'Payment failed.');
        break;
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(_pollInterval, (Timer timer) async {
      final String? reference = _orderReference;
      if (reference == null) {
        timer.cancel();
        return;
      }

      final PaymentResult result =
          await context.read<PaymentService>().checkStatus(reference);
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => _elapsedSeconds += _pollInterval.inSeconds);

      switch (result.status) {
        case PaymentStatus.success:
          timer.cancel();
          _onPaid();
          break;
        case PaymentStatus.failed:
          timer.cancel();
          setState(() => _orderReference = null);
          AppSnack.error(
            context,
            result.message ??
                'The payment did not go through. No money was taken.',
          );
          break;
        case PaymentStatus.cancelled:
          timer.cancel();
          setState(() => _orderReference = null);
          AppSnack.info(context, 'Payment cancelled on your phone.');
          break;
        case PaymentStatus.pending:
        case PaymentStatus.notConfigured:
          if (_elapsedSeconds >= _timeoutSeconds) {
            timer.cancel();
            setState(() {
              _waitingMessage =
                  'We have not had confirmation yet. If your PIN went through, '
                  'quote the reference below at the hub and we will confirm it.';
            });
          }
          break;
      }
    });
  }

  void _onPaid() {
    AppSnack.success(context, 'Payment received. You are enrolled.');
    Navigator.of(context).pop(true);
  }

  // ── Pay elsewhere ────────────────────────────────────────────

  Future<void> _openWebsiteCheckout() async {
    // The site has a /courses listing but no per-course page, so link to the
    // listing rather than a slug URL that 404s.
    final Uri uri = Uri.parse('${AppConfig.websiteUrl}/courses');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      AppSnack.error(context, 'Could not open the website.');
    }
  }

  void _showPayAtDeskSheet(String? reason) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Mobile money not enabled yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: sheetContext.inkColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reason ??
                  'You can still reserve your place and settle the fee at the '
                      'hub.',
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: sheetContext.mutedColor,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Call the hub',
              icon: Icons.call_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                final Uri uri = Uri(scheme: 'tel', path: AppConfig.supportPhone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Reserve my place',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final Course c = widget.course;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          PaymentService.canPayInApp ? 'Checkout' : 'Enrol',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: <Widget>[
          _summaryCard(c),
          const SizedBox(height: 16),
          if (!PaymentService.canPayInApp)
            ..._payOnWebsiteSection(c)
          else if (_orderReference != null)
            ..._waitingSection()
          else
            ..._mobileMoneySection(c),
        ],
      ),
    );
  }

  Widget _summaryCard(Course c) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              c.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.inkColor,
              ),
            ),
            const SizedBox(height: 12),
            InfoRow(label: 'Course fee', value: Fmt.price(c.price)),
            InfoRow(label: 'Level', value: c.level.label),
            InfoRow(label: 'Duration', value: c.durationLabel),
            const Divider(height: 24),
            InfoRow(
              label: 'Total due',
              value: Fmt.money(c.price),
              valueColor: AppColors.primary,
            ),
          ],
        ),
      );

  /// iOS: enrolment is free in the app, the fee is settled on the website.
  /// Apple requires in-app purchase for digital content bought in-app, so a
  /// third-party gateway here would risk the build being rejected.
  List<Widget> _payOnWebsiteSection(Course c) => <Widget>[
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
                  'Reserve your place now at no charge. A member of the team '
                  'will confirm your booking, and the ${Fmt.money(c.price)} fee '
                  'is settled at the hub.',
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
        const SizedBox(height: 24),
        AppButton(
          label: 'Reserve my place',
          icon: Icons.check_rounded,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Call the hub to pay',
          icon: Icons.call_outlined,
          variant: AppButtonVariant.secondary,
          onPressed: () async {
            final Uri uri = Uri(scheme: 'tel', path: AppConfig.supportPhone);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Browse courses on the website',
          icon: Icons.open_in_new_rounded,
          variant: AppButtonVariant.ghost,
          onPressed: _openWebsiteCheckout,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ];

  /// Android: mobile money, straight to the handset.
  List<Widget> _mobileMoneySection(Course c) => <Widget>[
        Form(
          key: _formKey,
          child: AppTextField(
            label: 'Mobile money number',
            controller: _phone,
            hint: '0712 345 678',
            prefixIcon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
            ],
            validator: Validators.tzMobile,
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: context.softCanvas,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: context.mutedColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You will get a prompt on your phone to approve '
                  '${Fmt.money(c.price)} with your mobile money PIN. Bright '
                  'Future never sees your PIN.',
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
        const SizedBox(height: 24),
        AppButton(
          label: 'Pay ${Fmt.money(c.price)}',
          icon: Icons.lock_outline_rounded,
          busy: _busy,
          onPressed: _startPayment,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ];

  List<Widget> _waitingSection() {
    final bool timedOut = _elapsedSeconds >= _timeoutSeconds;

    return <Widget>[
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (!timedOut)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: AppColors.peach,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    timedOut ? 'Still waiting' : 'Waiting for your approval',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: context.inkColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _waitingMessage,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: context.mutedColor,
              ),
            ),
            const Divider(height: 24),
            InfoRow(label: 'Reference', value: _orderReference ?? '-'),
          ],
        ),
      ),
      const SizedBox(height: 24),
      if (timedOut) ...<Widget>[
        AppButton(
          label: 'Call the hub',
          icon: Icons.call_outlined,
          variant: AppButtonVariant.secondary,
          onPressed: () async {
            final Uri uri = Uri(scheme: 'tel', path: AppConfig.supportPhone);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'Try again',
          variant: AppButtonVariant.ghost,
          onPressed: () {
            _poll?.cancel();
            setState(() {
              _orderReference = null;
              _elapsedSeconds = 0;
            });
          },
        ),
      ] else
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () {
            _poll?.cancel();
            Navigator.of(context).pop(false);
          },
        ),
    ];
  }

}
