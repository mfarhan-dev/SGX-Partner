import '../domain/mechanic_onboarding_draft.dart';

abstract interface class MechanicOnboardingRepository {
  Future<void> completeProfile(MechanicOnboardingDraft draft);
}
