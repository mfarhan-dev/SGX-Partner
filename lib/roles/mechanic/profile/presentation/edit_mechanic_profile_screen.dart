import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/widgets/sgx_screen.dart';
import '../data/mechanic_profile_providers.dart';
import '../data/mechanic_profile_update_repository.dart';
import 'mechanic_profile_form.dart';
import 'phone_change_otp_sheet.dart';

/// Same fields as onboarding (MechanicProfileForm), prefilled with the
/// mechanic's current data, saving via update_mechanic_profile() instead
/// of the onboarding create path.
///
/// Unlike onboarding, the mobile number is editable here. Changing a
/// phone number is a real identity change, not just another profile
/// field, so it goes through Supabase Auth's own phone-change flow
/// (a fresh OTP to the NEW number) before update_mechanic_profile()
/// ever runs -- that RPC always syncs mechanics.phone FROM the
/// verified auth.users.phone, never from anything the client typed.
class EditMechanicProfileScreen extends ConsumerWidget {
  const EditMechanicProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(mechanicProfileDataProvider);

    return SgxScreen(
      title: 'Edit Profile',
      showBack: true,
      showNotifications: false,
      children: [
        profileAsync.when(
          data: (profile) => MechanicProfileForm(
            phoneNumber: profile.phone,
            allowPhoneEdit: true,
            submitLabel: 'Update',
            submitIcon: Icons.check,
            initialFullName: profile.fullName,
            initialCnic: profile.cnic,
            initialWorkshopName: profile.workshopName,
            initialArea: profile.area,
            initialAddress: profile.address,
            initialPhotoUrl: profile.photoUrl,
            onSubmit: (result) async {
              final phoneChanged =
                  result.phone != null && result.phone != profile.phone;

              if (phoneChanged) {
                await _verifyPhoneChange(context, result.phone!);
              }

              await ref
                  .read(mechanicProfileUpdateRepositoryProvider)
                  .updateProfile(result);
              // Refetch on next visit instead of showing stale cached
              // data -- this is the "whenever they've changed the
              // profile, fetch that time" invalidation point.
              ref.invalidate(mechanicProfileDataProvider);
              if (context.mounted) context.go('/mechanic/profile');
            },
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text('Could not load your profile. Please try again.'),
            ),
          ),
        ),
      ],
    );
  }

  /// Sends a phone-change OTP to [newLocalNumber] and loops the entry
  /// sheet until the user confirms the right code or cancels. Throws
  /// MechanicProfileFormCancelled on cancel, so the form treats it as
  /// "user chose not to continue" rather than a real error.
  Future<void> _verifyPhoneChange(
    BuildContext context,
    String newLocalNumber,
  ) async {
    final client = Supabase.instance.client;
    final newE164 = _toE164(newLocalNumber);

    await client.auth.updateUser(UserAttributes(phone: newE164));

    String? errorText;
    while (true) {
      if (!context.mounted) throw const MechanicProfileFormCancelled();
      final code = await showPhoneChangeOtpSheet(
        context: context,
        newPhoneNumber: newLocalNumber,
        errorText: errorText,
      );
      if (code == null) {
        throw const MechanicProfileFormCancelled();
      }

      try {
        await client.auth.verifyOTP(
          type: OtpType.phoneChange,
          phone: newE164,
          token: code,
        );
        return;
      } on AuthException catch (error) {
        errorText = error.message;
      }
    }
  }

  /// mechanics/mechanics_select_self store local Pakistani numbers
  /// (03XXXXXXXXX), but Supabase Auth needs E.164 -- same conversion
  /// used for sign-in (SupabaseAuthRepository._toE164).
  String _toE164(String localNumber) {
    final digits = localNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final national = digits.startsWith('0') ? digits.substring(1) : digits;
    return '+92$national';
  }
}
