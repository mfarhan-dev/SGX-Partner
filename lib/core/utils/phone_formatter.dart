class PhoneFormatter {
  const PhoneFormatter._();

  static bool isValidPakistanMobile(String value) {
    return RegExp(r'^03\d{9}$').hasMatch(value);
  }

  /// mechanics/wholesalers store local Pakistani numbers (03XXXXXXXXX),
  /// but Supabase Auth needs E.164 -- same conversion used for sign-in
  /// (SupabaseAuthRepository._toE164), shared here so it isn't
  /// re-implemented at every phone-change call site.
  static String toE164(String localNumber) {
    final digits = localNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final national = digits.startsWith('0') ? digits.substring(1) : digits;
    return '+92$national';
  }
}
