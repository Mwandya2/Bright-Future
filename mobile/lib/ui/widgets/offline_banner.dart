import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/connectivity_provider.dart';

/// A slim strip that appears whenever the device loses connectivity.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final bool offline = context.watch<ConnectivityProvider>().isOffline;
    if (!offline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: <Widget>[
          Icon(Icons.cloud_off_rounded, size: 15, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are offline - showing your saved data.',
              style: TextStyle(color: Colors.white, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
