import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';

/// Shown in place of the camera preview when mobile_scanner's own
/// `errorBuilder` reports the camera couldn't start -- almost always a
/// denied/not-yet-granted CAMERA permission (already declared in
/// AndroidManifest.xml / Info.plist), occasionally an in-use or
/// missing camera on very old hardware. [onRetry] just asks the
/// controller to start again, which is enough for the common case: the
/// OS's own permission dialog reappears the first time, and re-grants
/// after "Allow" resolve on this same retry without needing a deep
/// link into system Settings.
class ScannerPermissionView extends StatelessWidget {
  const ScannerPermissionView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C0C0E),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.no_photography_outlined,
            color: Colors.white70,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Camera access is needed to scan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Allow camera access, or enter the code from the sticker manually below.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
