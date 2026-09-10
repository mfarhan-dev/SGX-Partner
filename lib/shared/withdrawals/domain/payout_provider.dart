import 'package:flutter/material.dart';

enum PayoutProviderKind { wallet, bank }

/// One entry in the payout provider catalog -- a mobile wallet or a
/// bank a partner can get paid through. Replaces the old fixed
/// 3-value WithdrawalMethod enum: real logos where a verified source
/// exists (each bank/wallet's own Wikipedia infobox), a colored
/// monogram fallback otherwise. `id` is exactly what's stored in
/// `mechanics.payout_method` / `wholesalers.payout_method` /
/// `withdrawals.method` -- see the DB check constraints.
class PayoutProvider {
  const PayoutProvider({
    required this.id,
    required this.label,
    required this.kind,
    this.logoAsset,
    this.monogram,
    this.monogramColor,
  });

  final String id;
  final String label;
  final PayoutProviderKind kind;

  /// Path under assets/images/payout_providers/ -- null means no
  /// verified logo was found, fall back to [monogram]/[monogramColor].
  final String? logoAsset;
  final String? monogram;
  final Color? monogramColor;

  bool get isSvgLogo => logoAsset?.endsWith('.svg') ?? false;

  /// Every wallet is phone-number-addressed, so they all ask for the
  /// same thing; a bank account isn't, so it needs its own number.
  String get accountFieldLabel => kind == PayoutProviderKind.bank
      ? 'Account Number / IBAN *'
      : 'Mobile Number *';

  static const String _assetDir = 'assets/images/payout_providers';

  static const List<PayoutProvider> wallets = [
    PayoutProvider(
      id: 'easy_paisa',
      label: 'EasyPaisa',
      kind: PayoutProviderKind.wallet,
      logoAsset: '$_assetDir/easy_paisa.png',
    ),
    PayoutProvider(
      id: 'jazz_cash',
      label: 'JazzCash',
      kind: PayoutProviderKind.wallet,
      logoAsset: '$_assetDir/jazz_cash.png',
    ),
    PayoutProvider(
      id: 'sada_pay',
      label: 'SadaPay',
      kind: PayoutProviderKind.wallet,
      logoAsset: '$_assetDir/sada_pay.png',
    ),
    PayoutProvider(
      id: 'naya_pay',
      label: 'NayaPay',
      kind: PayoutProviderKind.wallet,
      logoAsset: '$_assetDir/naya_pay.svg',
    ),
    PayoutProvider(
      id: 'u_paisa',
      label: 'UPaisa',
      kind: PayoutProviderKind.wallet,
      logoAsset: '$_assetDir/u_paisa.png',
    ),
  ];

  static const List<PayoutProvider> banks = [
    PayoutProvider(
      id: 'meezan_bank',
      label: 'Meezan Bank',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/meezan_bank.svg',
    ),
    PayoutProvider(
      id: 'hbl',
      label: 'HBL',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/hbl.png',
    ),
    PayoutProvider(
      id: 'ubl',
      label: 'United Bank (UBL)',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/ubl.svg',
    ),
    PayoutProvider(
      id: 'mcb_bank',
      label: 'MCB Bank',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/mcb_bank.svg',
    ),
    PayoutProvider(
      id: 'bank_alfalah',
      label: 'Bank Alfalah',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/bank_alfalah.svg',
    ),
    PayoutProvider(
      id: 'allied_bank',
      label: 'Allied Bank',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/allied_bank.svg',
    ),
    PayoutProvider(
      id: 'askari_bank',
      label: 'Askari Bank',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/askari_bank.png',
    ),
    PayoutProvider(
      id: 'faysal_bank',
      label: 'Faysal Bank',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/faysal_bank.svg',
    ),
    PayoutProvider(
      id: 'bank_al_habib',
      label: 'Bank Al Habib',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/bank_al_habib.svg',
    ),
    PayoutProvider(
      id: 'nbp',
      label: 'National Bank of Pakistan',
      kind: PayoutProviderKind.bank,
      logoAsset: '$_assetDir/nbp.png',
    ),
  ];

  static const List<PayoutProvider> catalog = [...wallets, ...banks];

  /// Looks up a provider by its DB id. Falls back to a generic entry
  /// (instead of throwing) for an id that's in the DB but no longer in
  /// this catalog -- e.g. a provider SGX later removed from the list
  /// while a partner's already-saved method still names it.
  factory PayoutProvider.byId(String id) {
    for (final provider in catalog) {
      if (provider.id == id) return provider;
    }
    return PayoutProvider(
      id: id,
      label: id,
      kind: PayoutProviderKind.bank,
      monogram: '?',
      monogramColor: const Color(0xFF7A6F61),
    );
  }
}
