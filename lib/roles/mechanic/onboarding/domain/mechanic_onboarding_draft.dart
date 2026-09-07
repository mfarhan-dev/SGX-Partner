import 'dart:io';

class MechanicOnboardingDraft {
  const MechanicOnboardingDraft({
    required this.fullName,
    required this.city,
    this.workshopName,
    this.address,
    this.cnic,
    this.latitude,
    this.longitude,
    this.photoFile,
  });

  final String fullName;

  /// The KPK area/district — matches the DB's fixed area list.
  final String city;

  /// Required by the onboarding flow (validated by the screen before
  /// this draft is built) — nullable here only because the DB column
  /// itself stays optional for staff-created mechanic records.
  final String? workshopName;

  /// Free-text street/area detail beyond the district (e.g. "Main
  /// Bazar, near Chowk").
  final String? address;

  /// Optional, format 00000-0000000-0 — matches the DB check constraint.
  final String? cnic;

  final double? latitude;
  final double? longitude;

  /// Local file picked from camera/gallery; uploaded by the repository
  /// before the row is created.
  final File? photoFile;
}
