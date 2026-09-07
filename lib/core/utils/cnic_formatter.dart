import 'package:flutter/services.dart';

class CnicFormatter {
  const CnicFormatter._();

  /// Matches the mechanics/wholesalers DB check constraint:
  /// 00000-0000000-0 (13 digits, dashes at positions 5 and 12).
  static bool isValid(String value) {
    return RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(value);
  }
}

/// Live-formats CNIC input as the user types: 00000-0000000-0.
/// Digits only in, dashes inserted automatically, capped at 13 digits.
class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 13) digits = digits.substring(0, 13);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 4 || i == 11) buffer.write('-');
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
