import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static const primary = AppColors.primary;
  static const surfaceDark = AppColors.surfaceDark;
  static const textMuted = AppColors.textMuted;

  static ThemeData _baseTheme(Brightness brightness, Color primaryColor) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      colorSchemeSeed: primaryColor,
      useMaterial3: true,
      scaffoldBackgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFFF5F5FA),
      textTheme: isDark ? _darkTextTheme : _lightTextTheme,
      cardTheme: CardTheme(
        color: isDark ? AppColors.surfaceCard : Colors.white,
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? null : Colors.black.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme => _baseTheme(Brightness.dark, AppColors.primary).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surfaceCard,
        ),
        scaffoldBackgroundColor: AppColors.surfaceDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );

  static ThemeData get lightTheme => _baseTheme(Brightness.light, AppColors.primary).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1A1A2E),
        ),
      );

  static const TextTheme _darkTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textSecondary,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.3,
    ),
  );

  static const TextTheme _lightTextTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: Color(0xFF1A1A2E),
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A2E),
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A2E),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A2E),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFF444466),
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF444466),
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A2E),
      letterSpacing: 0.3,
    ),
  );
}
