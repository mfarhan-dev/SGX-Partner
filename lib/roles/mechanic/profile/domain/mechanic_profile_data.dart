class MechanicProfileData {
  const MechanicProfileData({
    required this.fullName,
    required this.phone,
    required this.area,
    required this.pointsBalance,
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

  /// Whole rupees, despite the database column's "points" name --
  /// credited automatically the moment this mechanic scans a QR code
  /// (see scan_qr_code()/credit_points_on_qr_scan trigger). Never
  /// summed client-side; this is the same running total the database
  /// itself maintains, guarded against any direct edit.
  final int pointsBalance;

  /// Signed URL into the private mechanic-photos bucket — time-limited,
  /// not something to cache past this session (see the repository).
  final String? photoUrl;

  /// SGX's support WhatsApp number, from app_settings. Nullable only
  /// because staff could theoretically leave it blank; the DB column
  /// itself is NOT NULL.
  final String? adminWhatsappNumber;
}
