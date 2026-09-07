import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_controller.dart';
import '../domain/wholesaler_profile_data.dart';

/// Fetches the signed-in wholesaler's own profile once and caches it for
/// the rest of the session -- same shape as mechanicProfileDataProvider.
///
/// Deliberately NOT `.autoDispose`: every tab screen (Home/Wallet/QR
/// Progress/Settings) is reached through a plain ShellRoute that fully
/// unmounts the previous tab's screen widget on every switch, so an
/// autoDispose provider would lose its only listener and get thrown
/// away the instant you leave the tab -- refetching on every single
/// visit instead of actually caching for the session. A plain
/// FutureProvider stays alive regardless of listener count.
///
/// Refetch only when something has actually changed:
/// - automatically, because this watches authControllerProvider -- sign
///   out, or sign in as a DIFFERENT wholesaler, changes profile.id,
///   which reruns this provider.
/// - explicitly, by calling `ref.invalidate(wholesalerProfileDataProvider)`
///   right after a successful profile edit.
final wholesalerProfileDataProvider = FutureProvider<WholesalerProfileData>((
  ref,
) async {
  final uid = ref.watch(authControllerProvider).profile?.id;
  if (uid == null) {
    throw StateError('No authenticated session.');
  }

  final client = Supabase.instance.client;

  // wholesalers_select_self RLS policy: profile_id = auth.uid() only.
  final row = await client
      .from('wholesalers')
      .select(
        'owner_name, phone, area, shop_name, address, cnic, photo_storage_path',
      )
      .eq('profile_id', uid)
      .single();

  String? photoUrl;
  final photoPath = row['photo_storage_path'] as String?;
  if (photoPath != null) {
    try {
      // Private bucket -- a signed URL, not a public one. 1 day is long
      // enough that it won't expire mid-session but short enough that a
      // leaked link doesn't stay valid indefinitely.
      photoUrl = await client.storage
          .from('wholesaler-photos')
          .createSignedUrl(photoPath, 60 * 60 * 24);
    } catch (_) {
      // A photo problem (e.g. a legacy staff-uploaded path storage
      // can't sign for some reason) should never take down the whole
      // profile -- name/phone/area are still perfectly loadable. Fall
      // back to no photo instead of failing the entire fetch.
      photoUrl = null;
    }
  }

  final whatsapp = await client.rpc('get_admin_whatsapp_number') as String?;

  return WholesalerProfileData(
    ownerName: row['owner_name'] as String,
    phone: row['phone'] as String,
    area: row['area'] as String,
    shopName: row['shop_name'] as String?,
    address: row['address'] as String?,
    cnic: row['cnic'] as String?,
    photoUrl: photoUrl,
    adminWhatsappNumber: whatsapp,
  );
});
