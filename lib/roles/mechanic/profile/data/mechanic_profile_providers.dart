import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_controller.dart';
import '../domain/mechanic_profile_data.dart';

/// Fetches the signed-in mechanic's own profile once and caches it for
/// the rest of the session — Riverpod's default provider behavior does
/// this automatically: rebuilding the profile screen (switching tabs,
/// popping back from another screen, etc.) reuses the cached result
/// instead of hitting the network again.
///
/// Refetch only when something has actually changed:
/// - automatically, because this watches authControllerProvider — sign
///   out, or sign in as a DIFFERENT mechanic, changes profile.id, which
///   reruns this provider. (Bug fixed here: the previous version read
///   Supabase's current user id once with no such dependency, so after
///   switching accounts it kept serving the first mechanic's cached
///   data forever — logging out and back in as someone else showed the
///   wrong profile.)
/// - explicitly, by calling `ref.invalidate(mechanicProfileDataProvider)`
///   right after a successful profile edit.
final mechanicProfileDataProvider =
    FutureProvider.autoDispose<MechanicProfileData>((ref) async {
      final uid = ref.watch(authControllerProvider).profile?.id;
      if (uid == null) {
        throw StateError('No authenticated session.');
      }

      final client = Supabase.instance.client;

      // mechanics_select_self RLS policy: profile_id = auth.uid() only.
      final row = await client
          .from('mechanics')
          .select(
            'full_name, phone, area, workshop_name, address, cnic, photo_storage_path',
          )
          .eq('profile_id', uid)
          .single();

      String? photoUrl;
      final photoPath = row['photo_storage_path'] as String?;
      if (photoPath != null) {
        // Private bucket -- a signed URL, not a public one. 1 day is long
        // enough that it won't expire mid-session but short enough that a
        // leaked link doesn't stay valid indefinitely.
        photoUrl = await client.storage
            .from('mechanic-photos')
            .createSignedUrl(photoPath, 60 * 60 * 24);
      }

      final whatsapp = await client.rpc('get_admin_whatsapp_number') as String?;

      return MechanicProfileData(
        fullName: row['full_name'] as String,
        phone: row['phone'] as String,
        area: row['area'] as String,
        workshopName: row['workshop_name'] as String?,
        address: row['address'] as String?,
        cnic: row['cnic'] as String?,
        photoUrl: photoUrl,
        adminWhatsappNumber: whatsapp,
      );
    });
