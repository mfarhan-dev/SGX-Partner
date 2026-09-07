class MechanicProfileData {
  const MechanicProfileData({
    required this.fullName,
    required this.phone,
    required this.area,
    this.workshopName,
    this.address,
    this.cnic,
    this.photoUrl,
    this.adminWhatsappNumber,
  });

  final String fullName;
  final String phone;
  final String area;
  final String? workshopName;
  final String? address;
  final String? cnic;

  /// Signed URL into the private mechanic-photos bucket — time-limited,
  /// not something to cache past this session (see the repository).
  final String? photoUrl;

  /// SGX's support WhatsApp number, from app_settings. Nullable only
  /// because staff could theoretically leave it blank; the DB column
  /// itself is NOT NULL.
  final String? adminWhatsappNumber;
}
