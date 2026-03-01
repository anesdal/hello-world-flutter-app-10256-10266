import 'package:flutter/material.dart';

/// App theme configuration matching the original Kotlin app's themes.xml.
///
/// Primary color: Yellow (#F8CE52)
/// Secondary color: Teal (#FF03DAC5)
/// Light theme with NoActionBar equivalent.
class AppTheme {
  AppTheme._();

  /// Primary yellow color from the original app.
  static const Color primaryYellow = Color(0xFFF8CE52);

  /// Main theme yellow used in various UI elements.
  static const Color mainTheme = Color(0xFFF9D815);

  /// Secondary teal color.
  static const Color secondaryTeal = Color(0xFF03DAC5);

  /// Accent orange color used for highlights.
  static const Color accentOrange = Color(0xFFF7931E);

  /// Red color for polylines and route drawing.
  static const Color routeRed = Color(0xFFFF0000);

  /// Green color for various indicators.
  static const Color greenLight = Color(0xFF2ECC71);

  /// Background grey color.
  static const Color backgroundGrey = Color(0xFFE0E0E0);

  /// White color.
  static const Color white = Color(0xFFFFFFFF);

  /// Black color.
  static const Color black = Color(0xFF000000);

  // PUBLIC_INTERFACE
  /// Returns the main light theme for the app.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        primary: primaryYellow,
        secondary: secondaryTeal,
        surface: white,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryYellow,
        foregroundColor: black,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      fontFamily: 'LatoRegular',
    );
  }
}
