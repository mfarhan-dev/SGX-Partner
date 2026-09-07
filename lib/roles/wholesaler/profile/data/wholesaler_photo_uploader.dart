import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadedWholesalerPhoto {
  const UploadedWholesalerPhoto({
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

/// Mirrors mechanic_photo_uploader.dart -- same validation, same
/// `<uid>/...` path convention required by wholesaler-photos' self-upload
/// storage policy, just a different bucket. Returns null if no photo was
/// picked (caller decides what that means: skip for onboarding, keep
/// the existing photo for an edit).
Future<UploadedWholesalerPhoto?> uploadWholesalerPhoto(
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
  // Storage RLS on wholesaler-photos only allows a caller to touch
  // objects under their own "<uid>/..." folder.
  final objectPath = '$uid/${DateTime.now().millisecondsSinceEpoch}$extension';

  await client.storage
      .from('wholesaler-photos')
      .uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(contentType: mimeType, upsert: false),
      );

  return UploadedWholesalerPhoto(
    storagePath: objectPath,
    fileSizeBytes: bytes.length,
    mimeType: mimeType,
  );
}
