import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the personal finance application.
/// Implements Contemporary Minimalist Finance design with Professional Depth Palette.
class AppTheme {
  AppTheme._();

  // ... [color definitions unchanged] ...

  /// Light theme configuration
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: primaryLight.withAlpha(26),
      onPrimaryContainer: primaryLight,
      secondary: secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: secondaryLight.withAlpha(26),
      onSecondaryContainer: secondaryLight,
      tertiary: accentLight,
      onTertiary: Colors.white,
      tertiaryContainer: accentLight.withAlpha(26),
      onTertiaryContainer: accentLight,
      error: errorLight,
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: borderLight,
      outlineVariant: borderLight.withAlpha(128),
      shadow: shadowLight,
      scrim: Colors.black54,
      inverseSurface: surfaceDark,
      onInverseSurface: textPrimaryDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,

    // AppBar Theme - Clean and professional
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      shadowColor: shadowLight,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight),
    ),

    // Card Theme - Subtle elevation with rounded corners
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ... [other themes unchanged] ...

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ... [rest unchanged] ...
    dialogTheme: DialogThemeData(backgroundColor: surfaceLight),
  );

  /// Dark theme configuration
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Colors.black,
      primaryContainer: primaryDark.withAlpha(51),
      onPrimaryContainer: primaryDark,
      secondary: secondaryDark,
      onSecondary: Colors.black,
      secondaryContainer: secondaryDark.withAlpha(51),
      onSecondaryContainer: secondaryDark,
      tertiary: accentDark,
      onTertiary: Colors.black,
      tertiaryContainer: accentDark.withAlpha(51),
      onTertiaryContainer: accentDark,
      error: errorDark,
      onError: Colors.black,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      onSurfaceVariant: textSecondaryDark,
      outline: borderDark,
      outlineVariant: borderDark.withAlpha(128),
      shadow: shadowDark,
      scrim: Colors.black54,
      inverseSurface: surfaceLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,

    // AppBar Theme - Dark variant
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      shadowColor: shadowDark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      iconTheme: IconThemeData(color: textPrimaryDark),
    ),

    // Card Theme - Dark variant
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ... [other themes unchanged] ...

    // Tab Bar Theme - Dark variant
    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textSecondaryDark,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ... [rest unchanged] ...
    dialogTheme: DialogThemeData(backgroundColor: surfaceDark),
  );

  // ... [helpers unchanged] ...
}
