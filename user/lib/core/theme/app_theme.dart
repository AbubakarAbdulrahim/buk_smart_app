import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(AppColors.primary),
      brightness: Brightness.light,
      primary: const Color(AppColors.primary),
      secondary: const Color(AppColors.primaryDark),
      surface: const Color(AppColors.surface),
      onSurface: const Color(AppColors.textPrimary),
      error: const Color(AppColors.danger),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(AppColors.background),
      canvasColor: const Color(AppColors.background),
      cardColor: const Color(AppColors.card),
      splashFactory: InkSparkle.splashFactory,
      fontFamily: GoogleFonts.inter().fontFamily,
      iconTheme: const IconThemeData(color: Color(AppColors.primary)),
      dividerTheme: const DividerThemeData(
        color: Color(AppColors.border),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(AppColors.surface),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(AppColors.surface),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(AppColors.background),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(AppColors.background),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: const Color(0x1F0085D0),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? const Color(AppColors.primaryDeeper)
                : const Color(AppColors.textSecondary),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(AppColors.primaryDeeper)
                : const Color(AppColors.textSecondary),
          ),
        ),
      ),
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Color(AppColors.textPrimary)),
        titleTextStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Color(AppColors.textPrimary),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
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
        fillColor: const Color(AppColors.cardSubtle),
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

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(AppColors.primaryLight),
      brightness: Brightness.dark,
      primary: const Color(AppColors.primaryLight),
      secondary: const Color(AppColors.primary),
      surface: const Color(AppColors.darkCard),
      onSurface: const Color(AppColors.darkTextPrimary),
      error: const Color(AppColors.darkDanger),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(AppColors.darkBackground),
      canvasColor: const Color(AppColors.darkBackground),
      cardColor: const Color(AppColors.darkCard),
      splashFactory: InkSparkle.splashFactory,
      fontFamily: GoogleFonts.inter().fontFamily,
      iconTheme: const IconThemeData(color: Color(AppColors.darkTextPrimary)),
      dividerTheme: const DividerThemeData(
        color: Color(AppColors.darkBorder),
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(AppColors.darkCard),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(AppColors.darkCard),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(AppColors.darkBackground),
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(AppColors.darkBackground),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: const Color(0x3D0085D0),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? const Color(AppColors.primaryLight)
                : const Color(AppColors.darkTextSecondary),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(AppColors.primaryLight)
                : const Color(AppColors.darkTextSecondary),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(AppColors.darkCard),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(AppColors.darkBorder), width: 1.0),
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
          foregroundColor: const Color(AppColors.primaryLight),
          iconColor: const Color(AppColors.primaryLight),
          side: const BorderSide(color: Color(AppColors.darkBorder)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(AppColors.primaryLight)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(AppColors.darkBackground),
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: Color(AppColors.darkTextPrimary)),
        titleTextStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            color: Color(AppColors.darkTextPrimary),
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          headlineSmall: TextStyle(color: Color(AppColors.darkTextPrimary), fontWeight: FontWeight.w800, letterSpacing: -0.5),
          titleMedium: TextStyle(color: Color(AppColors.darkTextPrimary), fontWeight: FontWeight.w700, letterSpacing: -0.2),
          bodyMedium: TextStyle(color: Color(AppColors.darkTextPrimary), fontSize: 14),
          bodySmall: TextStyle(color: Color(AppColors.darkTextSecondary), fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppColors.darkCardSubtle),
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
          borderSide: const BorderSide(color: Color(AppColors.primaryLight), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(AppColors.darkTextSecondary), fontSize: 14),
        hintStyle: const TextStyle(color: Color(AppColors.darkTextSecondary), fontSize: 14),
      ),
    );
  }
}
