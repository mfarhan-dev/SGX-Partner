import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/scan_result.dart';
import 'mechanic_scan_repository.dart';

/// Calls the real scan_qr_code(p_qr_id) RPC -- verified end-to-end
/// against a real QR code in an earlier session, but never wired to
/// any UI until now. It resolves the caller's mechanic row from
/// auth.uid() server-side and, in one statement, both validates the
/// code and credits the reward (guarded against re-scans and inactive
/// accounts) -- there is nothing else for this repository to check
/// client-side beyond reading which outcome came back.
///
/// [qrPayload] is used as-is, whether it came from the camera decoder
/// or the manual-entry fallback -- `qr_codes.qr_id` is matched with a
/// plain, case-sensitive `=`, so this never trims case, only
/// surrounding whitespace a manual typist might add.
class SupabaseMechanicScanRepository implements MechanicScanRepository {
  SupabaseMechanicScanRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<ScanResult> submitScan(String qrPayload) async {
    final trimmed = qrPayload.trim();
    if (trimmed.isEmpty) {
      return const ScanResult.failure(
        message: 'Enter the code printed under the QR sticker.',
        failureReason: ScanFailureReason.invalid,
      );
    }

    final Map<String, dynamic> row;
    try {
      row = await _client
          .rpc('scan_qr_code', params: {'p_qr_id': trimmed})
          .single();
    } on PostgrestException catch (error) {
      // scan_qr_code() only ever raises for "no active mechanic
      // profile" (errcode 28000) -- every other outcome (not found,
      // already scanned, not active) comes back as a normal row
      // handled below, precisely so a routine "already used" result
      // doesn't have to be parsed out of an exception message.
      if (error.code == '28000') {
        return const ScanResult.failure(
          message: 'Your account is not active for scanning right now.',
          failureReason: ScanFailureReason.inactiveAccount,
        );
      }
      return const ScanResult.failure(
        message: 'Could not reach SGX. Check your connection and try again.',
        failureReason: ScanFailureReason.network,
      );
    } catch (_) {
      return const ScanResult.failure(
        message: 'Could not reach SGX. Check your connection and try again.',
        failureReason: ScanFailureReason.network,
      );
    }

    final result = row['result'] as String;
    switch (result) {
      case 'success':
        final reward = row['reward'] as int;
        return ScanResult.success(
          message: 'Rs. $reward added to your wallet.',
          rewardAmount: reward,
        );
      case 'already_scanned':
        final claimedByYou = row['scanned_by_you'] as bool? ?? false;
        final claimedAt = row['scanned_at'] != null
            ? DateTime.parse(row['scanned_at'] as String)
            : null;
        return ScanResult.failure(
          message: claimedByYou
              ? 'You already scanned this code.'
              : 'This QR code has already been claimed.',
          failureReason: ScanFailureReason.alreadyScanned,
          code: trimmed,
          claimedByName: row['scanned_by_name'] as String?,
          claimedByWorkshop: row['scanned_by_workshop'] as String?,
          claimedAt: claimedAt,
          claimedByYou: claimedByYou,
        );
      case 'not_active':
        return const ScanResult.failure(
          message: 'This QR code is not active yet.',
          failureReason: ScanFailureReason.expired,
        );
      case 'not_found':
      default:
        return const ScanResult.failure(
          message: "This code isn't a recognized SGX QR code.",
          failureReason: ScanFailureReason.invalid,
        );
    }
  }
}
