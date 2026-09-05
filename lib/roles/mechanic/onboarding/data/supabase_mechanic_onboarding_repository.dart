import 'package:flutter_riverpod/flutter_riverpod.dart';
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
///
/// Note: `mechanics` has no "workshop name" column (only wholesalers
/// do); `draft.workshopName` is not persisted here.
class SupabaseMechanicOnboardingRepository
    implements MechanicOnboardingRepository {
  SupabaseMechanicOnboardingRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> completeProfile(MechanicOnboardingDraft draft) async {
    await _client.rpc(
      'complete_mechanic_onboarding',
      params: {'p_full_name': draft.fullName, 'p_area': draft.city},
    );
  }
}
