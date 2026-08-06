import 'package:flutter/material.dart';

/// Tema dasar Material 3 — palet warna final mengikuti design system
/// Tahap 4 (satu warna brand + warna semantik income/expense).
class AppTheme {
  AppTheme._();

  static const _seedColor = Color(0xFF0F5132); // contoh: deep teal-green

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seedColor,
        brightness: Brightness.light,
        fontFamily: 'Inter',
      );
}
