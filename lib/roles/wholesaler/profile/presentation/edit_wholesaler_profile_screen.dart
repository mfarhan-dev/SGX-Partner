import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/phone_formatter.dart';
import '../../../../shared/widgets/phone_change_otp_sheet.dart';
import '../../../../shared/widgets/profile_form_skeleton.dart';
import '../../../../shared/widgets/sgx_screen.dart';
import '../data/wholesaler_profile_providers.dart';
import '../data/wholesaler_profile_update_repository.dart';
import 'wholesaler_profile_form.dart';

/// Mirrors edit_mechanic_profile_screen.dart -- prefilled with the
/// wholesaler's current data, saving via update_wholesaler_profile()
/// instead of the mechanic RPC. There is no wholesaler onboarding
/// screen (see WholesalerProfileForm's doc comment): staff always
/// create a complete wholesaler record first, so this Edit screen is
/// the only place a wholesaler ever fills in this form.
///
/// Same phone-change handling as mechanic: a new number goes through
/// Supabase Auth's phone-change flow (a fresh OTP to the NEW number)
/// before update_wholesaler_profile() ever runs -- that RPC always
/// syncs wholesalers.phone FROM the verified auth.users.phone, never
/// from anything the client typed.
class EditWholesalerProfileScreen extends ConsumerWidget {
  const EditWholesalerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(wholesalerProfileDataProvider);

    return SgxScreen(
      title: 'Edit Profile',
      showBack: true,
      showNotifications: false,
      children: [
        profileAsync.when(
          data: (profile) => WholesalerProfileForm(
            phoneNumber: profile.phone,
            allowPhoneEdit: true,
            submitLabel: 'Update',
            submitIcon: Icons.check,
            initialOwnerName: profile.ownerName,
            initialCnic: profile.cnic,
            initialShopName: profile.shopName,
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
                  .read(wholesalerProfileUpdateRepositoryProvider)
                  .updateProfile(result);
              // Refetch on next visit instead of showing stale cached
              // data -- this is the "whenever they've changed the
              // profile, fetch that time" invalidation point.
              ref.invalidate(wholesalerProfileDataProvider);
              if (context.mounted) context.go('/wholesaler/profile');
            },
          ),
          loading: () => const ProfileFormSkeleton(),
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
  /// WholesalerProfileFormCancelled on cancel, so the form treats it as
  /// "user chose not to continue" rather than a real error.
  Future<void> _verifyPhoneChange(
    BuildContext context,
    String newLocalNumber,
  ) async {
    final client = Supabase.instance.client;
    final newE164 = PhoneFormatter.toE164(newLocalNumber);

    await client.auth.updateUser(UserAttributes(phone: newE164));

    String? errorText;
    while (true) {
      if (!context.mounted) throw const WholesalerProfileFormCancelled();
      final code = await showPhoneChangeOtpSheet(
        context: context,
        newPhoneNumber: newLocalNumber,
        errorText: errorText,
      );
      if (code == null) {
        throw const WholesalerProfileFormCancelled();
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
}
