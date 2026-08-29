import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';

/// Confirms the code sent by SMS, which is what finishes a signup.
///
/// The account exists at this point but holds no token: the server issues one
/// only once the code comes back, so an unconfirmed number cannot be used.
class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({
    super.key,
    required this.email,
    this.phone,
  });

  final String email;

  /// Shown so the user can see which handset to look at. Optional because
  /// sign-in reaches this screen knowing only the email.
  final String? phone;

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _code = TextEditingController();

  bool _busy = false;

  /// Counts down before "Send a new code" becomes available, so nobody taps
  /// it repeatedly and burns through the server's hourly limit.
  int _resendIn = 30;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _ticker?.cancel();
    setState(() => _resendIn = 30);
    _ticker = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() => _busy = true);
    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.verifyPhone(
      email: widget.email,
      code: _code.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (ok) {
      // The gate rebuilds into the app now that a session exists.
      Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
    } else {
      AppSnack.error(context, auth.error ?? 'That code was not accepted.');
    }
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    final String? error = await context
        .read<AuthProvider>()
        .resendCode(email: widget.email);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error == null) {
      AppSnack.success(context, 'A new code is on its way.');
      _startCountdown();
    } else {
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String target = widget.phone != null && widget.phone!.isNotEmpty
        ? _mask(widget.phone!)
        : 'your phone';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm your number')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: BrandLogo(size: 40)),
                    const SizedBox(height: 28),
                    Text(
                      'Enter your code',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                        color: context.inkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a six-digit code to $target. It expires in ten '
                      'minutes.',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: context.mutedColor,
                      ),
                    ),
                    const SizedBox(height: 26),
                    AppTextField(
                      label: 'Six-digit code',
                      controller: _code,
                      hint: '123456',
                      prefixIcon: Icons.sms_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onSubmitted: (_) => _submit(),
                      validator: (String? v) {
                        final String digits =
                            (v ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.isEmpty) return 'Enter the code we sent you';
                        if (digits.length != 6) return 'The code is six digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    AppButton(
                      label: 'Confirm',
                      busy: _busy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: _resendIn > 0
                          ? 'Send a new code in ${_resendIn}s'
                          : 'Send a new code',
                      variant: AppButtonVariant.ghost,
                      onPressed: _resendIn > 0 || _busy ? null : _resend,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wrong number? Go back and sign up again with the '
                      'correct one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: context.mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 255712345678 -> 2557 **** 678, so the user can recognise their own
  /// number without the whole thing being readable over their shoulder.
  static String _mask(String phone) {
    if (phone.length < 8) return phone;
    return '${phone.substring(0, 4)} **** ${phone.substring(phone.length - 3)}';
  }
}
