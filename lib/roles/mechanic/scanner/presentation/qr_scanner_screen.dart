import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050713),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.blueGrey.shade800, const Color(0xFF050713)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Row(
                children: [
                  _RoundButton(
                    icon: Icons.close,
                    onTap: () => context.go('/mechanic/home'),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Scan SGX QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const _RoundButton(icon: Icons.flashlight_on),
                ],
              ),
            ),
            Center(
              child: SizedBox.square(
                dimension: MediaQuery.sizeOf(context).width * 0.68,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 4),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Divider(
                      color: Color(0xFF60A5FA),
                      thickness: 3,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.xxl,
              child: Column(
                children: [
                  Text(
                    'Place the QR inside the frame',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Hold steady until the code is detected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => _showSuccess(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mock successful scan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFE8F6ED),
                child: Icon(Icons.check_circle, size: 56, color: Colors.green),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Reward added!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('Rs. 15 has been added to your wallet.'),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Scan Another'),
              ),
              TextButton(
                onPressed: () => context.go('/mechanic/wallet'),
                child: const Text('Open Wallet'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        foregroundColor: Colors.white,
      ),
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}
