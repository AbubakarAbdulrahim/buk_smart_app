import 'package:flutter/material.dart';

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
      iconTheme: const IconThemeData(color: Color(AppColors.primary)),
      cardTheme: CardThemeData(
        color: const Color(AppColors.card),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.primary),
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppColors.primary),
          iconColor: const Color(AppColors.primary),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(AppColors.primary)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.background),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.w700, fontSize: 18),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: Color(AppColors.textPrimary), fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: Color(AppColors.textPrimary)),
        bodySmall: TextStyle(color: Color(AppColors.textSecondary)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppColors.surface),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(AppColors.primary), width: 1.2),
        ),
      ),
    );
  }
}
