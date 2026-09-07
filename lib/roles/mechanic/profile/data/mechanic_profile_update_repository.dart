import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/mechanic_profile_form.dart';
import 'mechanic_photo_uploader.dart';

final mechanicProfileUpdateRepositoryProvider =
    Provider<MechanicProfileUpdateRepository>(
      (ref) => MechanicProfileUpdateRepository(Supabase.instance.client),
    );

/// Saves changes from Edit Profile via `update_mechanic_profile()` --
/// the counterpart to complete_mechanic_onboarding(), but UPDATEs the
/// caller's own already-claimed mechanics row instead of inserting a
/// new one. photoFile null means "no new photo picked, keep the
/// existing one" -- the RPC coalesces on the server side.
class MechanicProfileUpdateRepository {
  MechanicProfileUpdateRepository(this._client);

  final SupabaseClient _client;

  Future<void> updateProfile(MechanicProfileFormResult result) async {
    final photo = await uploadMechanicPhoto(_client, result.photoFile);

    await _client.rpc(
      'update_mechanic_profile',
      params: {
        'p_full_name': result.fullName,
        'p_area': result.area,
        'p_address': result.address,
        'p_workshop_name': result.workshopName,
        'p_latitude': result.latitude,
        'p_longitude': result.longitude,
        'p_photo_storage_path': photo?.storagePath,
        'p_photo_file_size_bytes': photo?.fileSizeBytes,
        'p_photo_mime_type': photo?.mimeType,
        'p_cnic': result.cnic,
      },
    );
  }
}
