import 'app_role.dart';

class ProfileSummary {
  const ProfileSummary({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.isComplete,
  });

  final String id;
  final String displayName;
  final String phoneNumber;
  final AppRole role;
  final bool isActive;
  final bool isComplete;
}
