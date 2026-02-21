import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF009929);
  static const Color primaryLight = Color(0xFF5CCB5F);
  static const Color accent = Color(0xFF006414);
  static const Color background = Color(0xFF121212);
  static const Color darkGrey = Color(0xFF666264);
  static const Color grey = Color(0xFF969595);

  static const MaterialColor primarySwatch = MaterialColor(
    0xFF009929,
    <int, Color>{
      50: Color(0xFFE0F3E6),
      100: Color(0xFFB3E0C3),
      200: Color(0xFF80CC9D),
      300: Color(0xFF4DB877),
      400: Color(0xFF26A85A),
      500: primary,
      600: Color(0xFF008D24),
      700: Color(0xFF007F1E),
      800: Color(0xFF007118),
      900: Color(0xFF005A0F),
    },
  );
}