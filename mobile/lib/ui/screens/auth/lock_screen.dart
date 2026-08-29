import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/user_avatar.dart';

/// Shown when a saved session is protected by the biometric lock.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() => _busy = true);
    final bool ok = await context.read<AuthProvider>().unlock();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      AppSnack.info(context, 'Unlock cancelled. Try again to continue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const BrandLogo(size: 46, wordmarkColor: Colors.white),
              const SizedBox(height: 48),
              UserAvatar(
                name: auth.user?.displayName,
                size: 76,
                accent: AppColors.mint,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome back, ${auth.user?.firstName ?? 'there'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlock to continue',
                style: TextStyle(color: AppColors.onDarkSoft, fontSize: 14),
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'Unlock',
                icon: Icons.fingerprint_rounded,
                busy: _busy,
                onPressed: _unlock,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text(
                  'Sign in with a different account',
                  style: TextStyle(color: AppColors.onDarkSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
