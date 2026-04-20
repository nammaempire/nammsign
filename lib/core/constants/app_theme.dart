import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Poppins';

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.dark(
        primary:      AppColors.primaryPurple,
        secondary:    AppColors.accentPurple,
        surface:      AppColors.darkSurface,
        onPrimary:    Colors.white,
        onSecondary:  Colors.white,
        onSurface:    AppColors.darkTextPrimary,
        error:        AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.darkBackground,
        foregroundColor:  AppColors.darkTextPrimary,
        elevation:        0,
        centerTitle:      true,
        titleTextStyle: TextStyle(
          fontFamily:  _fontFamily,
          fontSize:    18,
          fontWeight:  FontWeight.w600,
          color:       AppColors.darkTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.darkIcon),
      ),
      cardTheme: CardThemeData(
        color:        AppColors.darkCard,
        elevation:    0,
        shape:        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.primaryPurple,
          foregroundColor:  Colors.white,
          elevation:        0,
          minimumSize:      const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily:  _fontFamily,
            fontSize:    16,
            fontWeight:  FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side:            const BorderSide(color: AppColors.primaryPurple),
          minimumSize:     const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily:  _fontFamily,
            fontSize:    16,
            fontWeight:  FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   AppColors.darkCard,
        hintStyle:   const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
        labelStyle:  const TextStyle(color: AppColors.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor:        AppColors.primaryPurple,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 3),
        ),
        labelStyle: TextStyle(
          fontFamily:  _fontFamily,
          fontWeight:  FontWeight.w600,
          fontSize:    14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:    AppColors.darkSurface,
        selectedItemColor:  AppColors.primaryPurple,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color:     AppColors.darkDivider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        labelStyle: const TextStyle(color: AppColors.darkTextPrimary, fontFamily: _fontFamily),
        side: const BorderSide(color: AppColors.darkDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary:      AppColors.primaryPurple,
        secondary:    AppColors.accentPurple,
        surface:      AppColors.lightSurface,
        onPrimary:    Colors.white,
        onSecondary:  Colors.white,
        onSurface:    AppColors.lightTextPrimary,
        error:        AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.lightBackground,
        foregroundColor:  AppColors.lightTextPrimary,
        elevation:        0,
        centerTitle:      true,
        titleTextStyle: TextStyle(
          fontFamily:  _fontFamily,
          fontSize:    18,
          fontWeight:  FontWeight.w600,
          color:       AppColors.lightTextPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.lightIcon),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color:     AppColors.lightCard,
        elevation: 2,
        shadowColor: AppColors.primaryPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  AppColors.primaryPurple,
          foregroundColor:  Colors.white,
          elevation:        2,
          shadowColor:      AppColors.primaryPurple.withOpacity(0.4),
          minimumSize:      const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily:  _fontFamily,
            fontSize:    16,
            fontWeight:  FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side:            const BorderSide(color: AppColors.primaryPurple),
          minimumSize:     const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily:  _fontFamily,
            fontSize:    16,
            fontWeight:  FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   AppColors.lightSurface,
        hintStyle:   const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
        labelStyle:  const TextStyle(color: AppColors.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor:           AppColors.primaryPurple,
        unselectedLabelColor: AppColors.lightTextSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryPurple, width: 3),
        ),
        labelStyle: TextStyle(
          fontFamily:  _fontFamily,
          fontWeight:  FontWeight.w600,
          fontSize:    14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.lightSurface,
        selectedItemColor:   AppColors.primaryPurple,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color:     AppColors.lightDivider,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBackground,
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary, fontFamily: _fontFamily),
        side: const BorderSide(color: AppColors.lightDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
