import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/wholesaler_profile_form.dart';
import 'wholesaler_photo_uploader.dart';

final wholesalerProfileUpdateRepositoryProvider =
    Provider<WholesalerProfileUpdateRepository>(
      (ref) => WholesalerProfileUpdateRepository(Supabase.instance.client),
    );

/// Saves changes from Edit Profile via `update_wholesaler_profile()` --
/// UPDATEs the caller's own already-claimed wholesalers row. photoFile
/// null means "no new photo picked, keep the existing one" -- the RPC
/// coalesces on the server side.
class WholesalerProfileUpdateRepository {
  WholesalerProfileUpdateRepository(this._client);

  final SupabaseClient _client;

  Future<void> updateProfile(WholesalerProfileFormResult result) async {
    final photo = await uploadWholesalerPhoto(_client, result.photoFile);

    await _client.rpc(
      'update_wholesaler_profile',
      params: {
        'p_owner_name': result.ownerName,
        'p_area': result.area,
        'p_address': result.address,
        'p_shop_name': result.shopName,
        'p_photo_storage_path': photo?.storagePath,
        'p_photo_file_size_bytes': photo?.fileSizeBytes,
        'p_photo_mime_type': photo?.mimeType,
        'p_cnic': result.cnic,
      },
    );
  }
}
