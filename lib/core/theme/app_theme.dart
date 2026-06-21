import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _textTheme(colorScheme),
      appBarTheme: _appBarTheme(colorScheme),
      cardTheme: _cardThemeData(colorScheme),
      bottomNavigationBarTheme: _bottomNavTheme(colorScheme),
      dividerTheme: _dividerTheme(colorScheme),
      iconTheme: _iconTheme(colorScheme),
      inputDecorationTheme: _inputTheme(colorScheme),
      snackBarTheme: _snackBarTheme(colorScheme),
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primaryDark,
      secondary: AppColors.primary,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: _textTheme(colorScheme),
      appBarTheme: _appBarTheme(colorScheme),
      cardTheme: _cardThemeData(colorScheme),
      bottomNavigationBarTheme: _bottomNavTheme(colorScheme),
      dividerTheme: _dividerTheme(colorScheme),
      iconTheme: _iconTheme(colorScheme),
      inputDecorationTheme: _inputTheme(colorScheme),
      snackBarTheme: _snackBarTheme(colorScheme),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final secondaryColor = isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
      ),
    );
  }

  static CardThemeData _cardThemeData(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return CardThemeData(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
    );
  }

  static DividerThemeData _dividerTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return DividerThemeData(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      thickness: 0.5,
      space: 0,
    );
  }

  static IconThemeData _iconTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return IconThemeData(
      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
      size: 24,
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textDarkPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    );
  }
}
