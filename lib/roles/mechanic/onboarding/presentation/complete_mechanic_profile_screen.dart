import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/auth/auth_controller.dart';
import '../../profile/presentation/mechanic_profile_form.dart';
import '../data/supabase_mechanic_onboarding_repository.dart';
import '../domain/mechanic_onboarding_draft.dart';

/// One-time setup shown right after OTP verification when
/// `claim_partner_profile()` found no pre-created wholesaler/mechanic
/// record for this phone (see `otp_verification_screen.dart` routing).
/// Submitting calls `complete_mechanic_onboarding()`, which creates the
/// real `mechanics` row under this session's own profile id.
///
/// The actual form (photo, name, CNIC, workshop, area, location) is
/// shared with Edit Profile via MechanicProfileForm — same fields, same
/// validation. Only this screen's chrome and what happens on submit
/// differ (create vs. update, and where each one navigates next).
class CompleteMechanicProfileScreen extends ConsumerWidget {
  const CompleteMechanicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumber = ref.watch(authControllerProvider).phoneNumber;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // This is the very first screen after OTP verification — there is
    // nothing meaningful to go "back" to (Change number lives on the
    // OTP screen already gone from the stack). No app bar, no back
    // button: the system back gesture just exits, like a landing screen.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Text(
                'Complete your profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              MechanicProfileForm(
                phoneNumber: phoneNumber,
                submitLabel: 'Continue',
                submitIcon: Icons.arrow_forward,
                onSubmit: (result) async {
                  await ref
                      .read(mechanicOnboardingRepositoryProvider)
                      .completeProfile(
                        MechanicOnboardingDraft(
                          fullName: result.fullName,
                          city: result.area,
                          workshopName: result.workshopName,
                          cnic: result.cnic,
                          address: result.address,
                          latitude: result.latitude,
                          longitude: result.longitude,
                          photoFile: result.photoFile,
                        ),
                      );
                  if (context.mounted) context.go('/mechanic/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
