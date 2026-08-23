import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(AppColors.primary),
      brightness: Brightness.light,
      primary: const Color(AppColors.primary),
      secondary: const Color(AppColors.primaryDark),
      error: const Color(AppColors.danger),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(AppColors.background),
      splashFactory: InkSparkle.splashFactory,
      fontFamily: GoogleFonts.inter().fontFamily,
      iconTheme: const IconThemeData(color: Color(AppColors.primary)),
      cardTheme: CardThemeData(
        color: const Color(AppColors.card),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(AppColors.border), width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primary),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppColors.primary),
          iconColor: const Color(AppColors.primary),
          side: const BorderSide(color: Color(AppColors.border)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(AppColors.primary)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(AppColors.background),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          textStyle: const TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.3),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineSmall: TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.w800, letterSpacing: -0.5),
          titleMedium: TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.w700, letterSpacing: -0.2),
          bodyMedium: TextStyle(color: Color(AppColors.textPrimary), fontSize: 14),
          bodySmall: TextStyle(color: Color(AppColors.textSecondary), fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Premium Slate 100 background fill
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(AppColors.primary), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 14),
        hintStyle: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 14),
      ),
    );
  }
}
