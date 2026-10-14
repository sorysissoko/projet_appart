import 'package:flutter/services.dart';

class PriceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) return newValue;

    final String cleaned = newValue.text.replaceAll(RegExp(r'\s'), '');
    if (cleaned.isEmpty) return newValue;

    final StringBuffer buffer = StringBuffer();
    final String reversed = cleaned.split('').reversed.join();

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(reversed[i]);
    }

    final String formatted = buffer.toString().split('').reversed.join();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}