import '../../../shared/models/profile_summary.dart';

abstract interface class ProfileRepository {
  Future<ProfileSummary?> loadProtectedProfile();
}
