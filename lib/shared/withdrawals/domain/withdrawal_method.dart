enum WithdrawalMethod {
  easyPaisa,
  jazzCash,
  bankTransfer,
  cashCollection;

  String get label => switch (this) {
    easyPaisa => 'EasyPaisa',
    jazzCash => 'JazzCash',
    bankTransfer => 'Bank transfer',
    cashCollection => 'Cash collection from SGX',
  };
}
