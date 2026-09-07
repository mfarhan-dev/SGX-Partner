import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/mechanic_onboarding_draft.dart';
import 'mechanic_onboarding_repository.dart';

final mechanicOnboardingRepositoryProvider =
    Provider<MechanicOnboardingRepository>(
      (ref) => SupabaseMechanicOnboardingRepository(Supabase.instance.client),
    );

/// Completes onboarding via `complete_mechanic_onboarding()` rather than
/// inserting into `mechanics` directly — that table's INSERT policy is
/// staff-only, so a mechanic can only create their own row through this
/// SECURITY DEFINER function, which fills in their own profile id and
/// verified phone server-side.
class SupabaseMechanicOnboardingRepository
    implements MechanicOnboardingRepository {
  SupabaseMechanicOnboardingRepository(this._client);

  final SupabaseClient _client;

  static const _allowedMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};
  static const _maxPhotoBytes = 5 * 1024 * 1024; // matches the bucket limit

  @override
  Future<void> completeProfile(MechanicOnboardingDraft draft) async {
    String? photoStoragePath;
    int? photoFileSizeBytes;
    String? photoMimeType;

    final photo = draft.photoFile;
    if (photo != null) {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) {
        throw StateError('No authenticated session.');
      }

      final bytes = await photo.readAsBytes();
      if (bytes.length > _maxPhotoBytes) {
        throw StateError('Photo must be 5 MB or smaller.');
      }

      final mimeType = lookupMimeType(photo.path) ?? 'image/jpeg';
      if (!_allowedMimeTypes.contains(mimeType)) {
        throw StateError('Photo must be a JPEG, PNG, or WebP image.');
      }

      final extension = p.extension(photo.path).isNotEmpty
          ? p.extension(photo.path)
          : '.jpg';
      // Storage RLS on mechanic-photos only allows a caller to touch
      // objects under their own "<uid>/..." folder — see
      // mechanic_photos_storage / self-upload policy migrations.
      final objectPath =
          '$uid/${DateTime.now().millisecondsSinceEpoch}$extension';

      await _client.storage
          .from('mechanic-photos')
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      photoStoragePath = objectPath;
      photoFileSizeBytes = bytes.length;
      photoMimeType = mimeType;
    }

    await _client.rpc(
      'complete_mechanic_onboarding',
      params: {
        'p_full_name': draft.fullName,
        'p_area': draft.city,
        'p_address': draft.address,
        'p_workshop_name': draft.workshopName,
        'p_latitude': draft.latitude,
        'p_longitude': draft.longitude,
        'p_photo_storage_path': photoStoragePath,
        'p_photo_file_size_bytes': photoFileSizeBytes,
        'p_photo_mime_type': photoMimeType,
        'p_cnic': draft.cnic,
      },
    );
  }
}
