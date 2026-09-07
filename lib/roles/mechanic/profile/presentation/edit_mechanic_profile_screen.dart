import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/sgx_screen.dart';
import '../data/mechanic_profile_providers.dart';
import '../data/mechanic_profile_update_repository.dart';
import 'mechanic_profile_form.dart';

/// Same fields as onboarding (MechanicProfileForm), prefilled with the
/// mechanic's current data, saving via update_mechanic_profile() instead
/// of the onboarding create path.
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
            submitLabel: 'Update',
            submitIcon: Icons.check,
            initialFullName: profile.fullName,
            initialCnic: profile.cnic,
            initialWorkshopName: profile.workshopName,
            initialArea: profile.area,
            initialAddress: profile.address,
            initialPhotoUrl: profile.photoUrl,
            onSubmit: (result) async {
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
}
