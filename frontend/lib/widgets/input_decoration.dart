import 'package:flutter/material.dart';

InputDecoration customInputDecoration({
  required String label,
  String? hint,
  required IconData prefixIcon,
  String? suffix,
  String? helper,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    helperText: helper,
    helperStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
    suffixText: suffix,
    suffixStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.normal),
    prefixIcon: Icon(prefixIcon, color: const Color(0xFF0F766E), size: 20),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE11D48), width: 2),
    ),
  );
}
