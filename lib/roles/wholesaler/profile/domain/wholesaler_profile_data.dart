import '../../../../shared/withdrawals/domain/withdrawal_method.dart';

class WholesalerProfileData {
  const WholesalerProfileData({
    required this.ownerName,
    required this.phone,
    required this.area,
    required this.pointsBalance,
    this.payoutMethod,
    this.shopName,
    this.address,
    this.cnic,
    this.photoUrl,
    this.adminWhatsappNumber,
    this.payoutAccountTitle,
    this.payoutAccountNumber,
  });

  final String ownerName;
  final String phone;
  final String area;
  final String? shopName;
  final String? address;
  final String? cnic;

  /// How this wholesaler wants to receive withdrawals -- set via
  /// set_payout_method(), snapshotted onto each withdrawal at
  /// request_withdrawal() time. Null means not configured yet --
  /// request_withdrawal() blocks with a clear error until this is set.
  final WithdrawalMethod? payoutMethod;
  final String? payoutAccountTitle;
  final String? payoutAccountNumber;

  /// Whole rupees, despite the database column's "points" name --
  /// credited automatically the moment a mechanic scans a QR code tied
  /// to one of this wholesaler's invoices. Never summed client-side;
  /// this is the same running total the database itself maintains,
  /// guarded against any direct edit.
  final int pointsBalance;

  /// Signed URL into the private wholesaler-photos bucket -- time-limited,
  /// not something to cache past this session (see the repository).
  final String? photoUrl;

  /// SGX's support WhatsApp number, from app_settings. Nullable only
  /// because staff could theoretically leave it blank; the DB column
  /// itself is NOT NULL.
  final String? adminWhatsappNumber;
}
