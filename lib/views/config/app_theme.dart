// lib/config/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF52B69A);
  static const Color secondary = Color(0xFFFFA92C);
  static const Color neutral = Color(0xFF0C0C20);
  static const Color background = Color(0xFFF6FAF9);

  // Text Styles
  static TextStyle display1 = GoogleFonts.merriweather(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: primary,
    shadows: [
      Shadow(
        offset: Offset(0, 4),
        blurRadius: 8,
        color: Colors.black.withOpacity(0.15),
      ),
    ],
  );

  static TextStyle heading1 = GoogleFonts.merriweather(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: Color(0xFF76C893),
    shadows: [
      Shadow(
        offset: Offset(0, 4),
        blurRadius: 8,
        color: Colors.black.withOpacity(0.10),
      ),
    ],
  );

  static TextStyle heading2 = GoogleFonts.merriweather(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: secondary,
    shadows: [
      Shadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        color: Colors.black.withOpacity(0.10),
      ),
    ],
  );

  static TextStyle heading3 = GoogleFonts.merriweather(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Color(0xFFFFC570),
  );

  static TextStyle heading4 = GoogleFonts.merriweather(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: neutral,
  );

  static TextStyle heading4Uppercase = GoogleFonts.merriweather(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: neutral,
    textStyle: TextStyle(letterSpacing: 1.5),
  );

  static TextStyle paragraph1 = GoogleFonts.merriweather(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: neutral,
  );

  static TextStyle paragraph2 = GoogleFonts.merriweather(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: neutral,
  );

  static TextStyle button = GoogleFonts.merriweather(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle hyperlink = GoogleFonts.merriweather(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primary,
    decoration: TextDecoration.underline,
  );

  // ThemeData
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: heading1,
        headlineLarge: heading2,
        headlineMedium: heading3,
        headlineSmall: heading4,
        bodyLarge: paragraph1,
        bodyMedium: paragraph2,
        labelLarge: button,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          textStyle: button,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}