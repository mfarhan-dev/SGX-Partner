import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_controller.dart';
import '../domain/mechanic_profile_data.dart';

/// Fetches the signed-in mechanic's own profile once and caches it for
/// the rest of the session.
///
/// Deliberately NOT `.autoDispose`: the Settings screen is reached
/// through a plain ShellRoute (MechanicShell's `body: child`), which
/// fully unmounts the previous tab's screen widget on every switch —
/// so an autoDispose provider would lose its only listener and get
/// thrown away the instant you leave the tab, defeating the "fetch
/// once per session" requirement (it was silently refetching on every
/// single visit to Settings). A plain FutureProvider stays alive for
/// the app's session regardless of listener count.
///
/// Refetch only when something has actually changed:
/// - automatically, because this watches authControllerProvider — sign
///   out, or sign in as a DIFFERENT mechanic, changes profile.id, which
///   reruns this provider. (Bug fixed here previously: the old version
///   read Supabase's current user id once with no such dependency, so
///   after switching accounts it kept serving the first mechanic's
///   cached data forever.)
/// - explicitly, by calling `ref.invalidate(mechanicProfileDataProvider)`
///   right after a successful profile edit.
final mechanicProfileDataProvider = FutureProvider<MechanicProfileData>((
  ref,
) async {
  final uid = ref.watch(authControllerProvider).profile?.id;
  if (uid == null) {
    throw StateError('No authenticated session.');
  }

  final client = Supabase.instance.client;

  // mechanics_select_self RLS policy: profile_id = auth.uid() only.
  final row = await client
      .from('mechanics')
      .select(
        'full_name, phone, area, workshop_name, address, cnic, photo_storage_path, points_balance',
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
          .from('mechanic-photos')
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

  return MechanicProfileData(
    fullName: row['full_name'] as String,
    phone: row['phone'] as String,
    area: row['area'] as String,
    pointsBalance: (row['points_balance'] as num).toInt(),
    workshopName: row['workshop_name'] as String?,
    address: row['address'] as String?,
    cnic: row['cnic'] as String?,
    photoUrl: photoUrl,
    adminWhatsappNumber: whatsapp,
  );
});
