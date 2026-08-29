import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';
import 'verify_phone_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _email =
      TextEditingController(text: AppPrefs.instance.lastEmail);
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.signIn(
      email: _email.text,
      password: _password.text,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
      return;
    }

    // Password was right, phone never confirmed: send them to finish rather
    // than showing an error they cannot do anything about.
    final String? pending = auth.pendingVerificationEmail;
    if (pending != null) {
      AppSnack.info(context, auth.error ?? 'Confirm your phone to continue.');
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VerifyPhoneScreen(email: pending),
        ),
      );
      return;
    }

    AppSnack.error(context, auth.error ?? 'Could not sign you in.');
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: BrandLogo(size: 44)),
                    const SizedBox(height: 34),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: context.inkColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to reach your courses, bookings and print orders.',
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: context.mutedColor,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Email address',
                      controller: _email,
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.email],
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      hint: 'Your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.password],
                      validator: Validators.password,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Sign in',
                      busy: auth.busy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    // Wrap, not Row: the prompt and the link together are wider
                    // than a 320dp screen, and a Row would overflow instead of
                    // moving the link onto its own line.
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          'New to Bright Future?',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.mutedColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.signup),
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(Routes.adminLogin),
                      icon: const Icon(Icons.shield_outlined, size: 18),
                      label: const Text('Administrator sign in'),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(Routes.contact),
                      child: const Text('Need help? Contact the hub'),
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
}
