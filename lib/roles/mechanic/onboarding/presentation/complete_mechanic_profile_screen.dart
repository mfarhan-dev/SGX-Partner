import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../../../shared/constants/kpk_areas.dart';
import '../../../../shared/widgets/sgx_logo.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../data/supabase_mechanic_onboarding_repository.dart';
import '../domain/mechanic_onboarding_draft.dart';

class CompleteMechanicProfileScreen extends ConsumerStatefulWidget {
  const CompleteMechanicProfileScreen({super.key});

  @override
  ConsumerState<CompleteMechanicProfileScreen> createState() =>
      _CompleteMechanicProfileScreenState();
}

class _CompleteMechanicProfileScreenState
    extends ConsumerState<CompleteMechanicProfileScreen> {
  final _fullNameController = TextEditingController();
  final _workshopNameController = TextEditingController();
  String? _area;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _fullNameController.dispose();
    _workshopNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = ref.watch(authControllerProvider).phoneNumber;

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
            subtitle: Text(phoneNumber ?? '—'),
            trailing: const Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _workshopNameController,
          decoration: const InputDecoration(
            labelText: 'Workshop / Shop Name (optional)',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: _area,
          decoration: const InputDecoration(
            labelText: 'Area / City *',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: kKpkAreas
              .map((area) => DropdownMenuItem(value: area, child: Text(area)))
              .toList(),
          onChanged: (value) => setState(() => _area = value),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_errorText!, style: const TextStyle(color: AppColors.error)),
        ],
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
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_forward),
          label: const Text('Continue'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.length < 2) {
      setState(() => _errorText = 'Enter your full name.');
      return;
    }
    if (_area == null) {
      setState(() => _errorText = 'Select your area / city.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await ref
          .read(mechanicOnboardingRepositoryProvider)
          .completeProfile(
            MechanicOnboardingDraft(
              fullName: fullName,
              workshopName: _workshopNameController.text.trim(),
              city: _area!,
            ),
          );
      if (!mounted) return;
      context.go('/mechanic/home');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = 'Could not save your profile. Please try again.';
      });
    }
  }
}
