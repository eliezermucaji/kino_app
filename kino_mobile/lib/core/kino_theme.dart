import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KinoColors {
  static const background = Color(0xFFF6F2DF);
  static const field = Color(0xFFF5EFD9);
  static const redDark = Color(0xFFA80F10);
  static const orange = Color(0xFFF08200);
  static const eyeOrange = Color(0xFFE8580C);
  static const error = Color(0xFFE02424);

  static const gradient = LinearGradient(
    colors: [redDark, orange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientReversed = LinearGradient(
    colors: [orange, redDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class KinoTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: KinoColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KinoColors.redDark,
          primary: KinoColors.redDark,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      );
}