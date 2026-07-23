import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/sgx_logo.dart';
import '../../../../shared/widgets/sgx_screen.dart';

class CompleteMechanicProfileScreen extends StatelessWidget {
  const CompleteMechanicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SgxScreen(
      title: 'Complete your profile',
      showBack: true,
      showNotifications: false,
      children: [
        const Center(child: SgxLogo(size: 48)),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Tell us a little about yourself so we can send your rewards to the right place.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          color: AppColors.successContainer,
          child: ListTile(
            leading: const Icon(Icons.verified, color: AppColors.success),
            title: const Text('Verified phone'),
            subtitle: const Text('0300-1234567'),
            trailing: const Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Workshop / Shop Name (optional)',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Area / City *',
            prefixIcon: Icon(Icons.location_on_outlined),
            suffixIcon: Icon(Icons.expand_more),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          color: AppColors.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'You do not need to choose a shop or wholesaler. Rewards come from the SGX QR you scan.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => context.go('/mechanic/home'),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continue'),
        ),
      ],
    );
  }
}
