import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';
import 'verify_phone_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      AppSnack.info(context, 'Please accept the terms to continue.');
      return;
    }
    FocusScope.of(context).unfocus();

    final AuthProvider auth = context.read<AuthProvider>();
    final SignUpOutcome outcome = await auth.signUp(
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
      phone: _phone.text,
    );

    if (!mounted) return;
    if (outcome == SignUpOutcome.needsPhoneVerification) {
      // The account exists but holds no session yet. Confirming the code is
      // what finishes signing up.
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VerifyPhoneScreen(
            email: _email.text.trim(),
            phone: _phone.text.trim(),
          ),
        ),
      );
    } else {
      AppSnack.error(context, auth.error ?? 'Could not create your account.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const BrandLogo(size: 30),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                        color: context.inkColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'One account for courses, the lab and printing.',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: context.mutedColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Full name',
                      controller: _name,
                      hint: 'e.g. Amina Joseph',
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalizationWords: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.name],
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: 16),
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
                      label: 'Phone number',
                      controller: _phone,
                      hint: '+255 7XX XXX XXX',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.tzMobile,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      hint: 'At least 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Confirm password',
                      controller: _confirm,
                      hint: 'Repeat your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      validator: (String? v) =>
                          Validators.confirmPassword(v, _password.text),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _acceptedTerms,
                      onChanged: (bool? v) =>
                          setState(() => _acceptedTerms = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        'I agree to the Bright Future terms of service and '
                        'privacy policy.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: context.mutedColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'Create account',
                      busy: auth.busy,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('I already have an account'),
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
}
