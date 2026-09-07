import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadedMechanicPhoto {
  const UploadedMechanicPhoto({
    required this.storagePath,
    required this.fileSizeBytes,
    required this.mimeType,
  });

  final String storagePath;
  final int fileSizeBytes;
  final String mimeType;
}

const _allowedMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};
const _maxPhotoBytes = 5 * 1024 * 1024; // matches the bucket limit

/// Shared by onboarding (create) and Edit Profile (update) — both write
/// into the same mechanic-photos bucket under the same `<uid>/...` path
/// convention that its self-upload storage policy requires. Returns
/// null if no photo was picked (caller decides what that means: skip
/// for onboarding, keep the existing photo for an edit).
Future<UploadedMechanicPhoto?> uploadMechanicPhoto(
  SupabaseClient client,
  File? photo,
) async {
  if (photo == null) return null;

  final uid = client.auth.currentUser?.id;
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
  // objects under their own "<uid>/..." folder.
  final objectPath = '$uid/${DateTime.now().millisecondsSinceEpoch}$extension';

  await client.storage
      .from('mechanic-photos')
      .uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );

  return UploadedMechanicPhoto(
    storagePath: objectPath,
    fileSizeBytes: bytes.length,
    mimeType: mimeType,
  );
}
