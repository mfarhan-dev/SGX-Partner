/// One row from get_khata_ledger() -- a real khata_entries row, always
/// exactly one of debit/credit (never both, enforced by the database),
/// with the running balance already computed server-side. Debit =
/// increases what the wholesaler owes SGX (a purchase); credit =
/// decreases it (a payment or return) -- which one applies is read
/// straight off which column is non-null, never assumed from
/// entryType, so this never has to guess at a business rule.
class KhataEntry {
  const KhataEntry({
    required this.id,
    required this.entryType,
    required this.entryDate,
    required this.balanceAfter,
    this.reference,
    this.note,
    this.paymentMethod,
    this.debit,
    this.credit,
  });

  final String id;
  final String entryType;
  final DateTime entryDate;
  final String? reference;
  final String? note;
  final String? paymentMethod;
  final double? debit;
  final double? credit;
  final double balanceAfter;

  bool get isDebit => debit != null;
  double get amount => debit ?? credit ?? 0;

  /// Plain-language label instead of the raw entry_type/reference --
  /// what actually happened to the account, not an internal code.
  String get description {
    return switch (entryType) {
      'opening_balance' => 'Opening balance',
      'invoice' => 'Purchase',
      'payment' => 'Payment received',
      'sales_return' => 'Return',
      'invoice_cancelled' => 'Purchase cancelled',
      'cash_refund' => 'Cash refund',
      _ => entryType,
    };
  }
}
