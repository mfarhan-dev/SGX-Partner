import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/sgx_screen.dart';

class AccountUnavailableScreen extends StatelessWidget {
  const AccountUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: '',
      showBack: true,
      showNotifications: false,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_off,
              size: 56,
              color: AppColors.error,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Account inactive',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your SGX Partners account is currently inactive. Please contact SGX to reactivate it.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.support_agent),
          label: const Text('Contact SGX'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => context.go('/auth/phone'),
          icon: const Icon(Icons.refresh),
          label: const Text('Use another number'),
        ),
      ],
    );
  }
}
