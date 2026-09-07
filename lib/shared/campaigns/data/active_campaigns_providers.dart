import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_controller.dart';
import '../domain/active_campaign.dart';

/// Fetches the signed-in partner's own currently-active campaigns once
/// and caches them for the rest of the session -- same shape as
/// mechanicProfileDataProvider / wholesalerProfileDataProvider.
///
/// Deliberately NOT `.autoDispose`, for the same reason those two
/// aren't: Home is reached through a plain ShellRoute that fully
/// unmounts the previous tab's screen widget on every switch, so an
/// autoDispose provider would refetch on every single visit instead of
/// caching for the session.
///
/// Refetches automatically on sign-out/sign-in-as-someone-else (watches
/// authControllerProvider, same as the profile providers) since a
/// different partner can be targeted by different campaigns.
final activeCampaignsProvider = FutureProvider<List<ActiveCampaign>>((
  ref,
) async {
  ref.watch(authControllerProvider);
  final client = Supabase.instance.client;

  // get_active_campaigns() already filters to status = 'active' and
  // audience = the caller's own role server-side (SECURITY DEFINER,
  // bypassing campaigns'/campaign_audiences' own staff-only RLS just
  // for that narrow, vetted read) -- nothing further to filter here.
  final rows = await client.rpc('get_active_campaigns') as List<dynamic>;

  final campaigns = <ActiveCampaign>[];
  for (final row in rows) {
    final map = row as Map<String, dynamic>;
    final imagePath = map['image_storage_path'] as String?;

    String? imageUrl;
    if (imagePath != null) {
      try {
        // Private bucket -- a signed URL, not a public one.
        imageUrl = await client.storage
            .from('campaign-images')
            .createSignedUrl(imagePath, 60 * 60 * 24);
      } catch (_) {
        // A broken image link shouldn't hide an otherwise-valid
        // campaign -- same defensive fallback used for profile photos.
        imageUrl = null;
      }
    }

    campaigns.add(
      ActiveCampaign(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        prizeNote: map['prize_note'] as String?,
        startDate: map['start_date'] != null
            ? DateTime.parse(map['start_date'] as String)
            : null,
        endDate: map['end_date'] != null
            ? DateTime.parse(map['end_date'] as String)
            : null,
        imageUrl: imageUrl,
      ),
    );
  }

  return campaigns;
});
