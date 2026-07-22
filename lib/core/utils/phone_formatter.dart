class PhoneFormatter {
  const PhoneFormatter._();

  static bool isValidPakistanMobile(String value) {
    return RegExp(r'^03\d{9}$').hasMatch(value);
  }
}
