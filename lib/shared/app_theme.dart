import 'package:flutter/material.dart';

/// App theme configuration matching the original Connected_Living app's
/// themes.xml and colors.xml resources.
///
/// Primary color: Yellow (#F8CE52)
/// Main Theme: (#F9D815)
/// Accent/Selected: (#F7931E / #F7941D)
/// Splash BG: (#F7941D)
/// Light theme with NoActionBar equivalent.
class AppTheme {
  AppTheme._();

  /// Primary yellow color from the original app (colors.xml: "yellow").
  static const Color primaryYellow = Color(0xFFF8CE52);

  /// Main theme yellow used in buttons and highlights (colors.xml: "mainTheme").
  static const Color mainTheme = Color(0xFFF9D815);

  /// Accent orange color used for highlights (colors.xml: "colorAccent" / "selected_tab").
  static const Color accentOrange = Color(0xFFF7931E);

  /// Splash background color (colors.xml: "bg_splash").
  static const Color splashBg = Color(0xFFF7941D);

  /// Secondary teal color (colors.xml: "teal_200").
  static const Color secondaryTeal = Color(0xFF03DAC5);

  /// Red color for polylines and route drawing.
  static const Color routeRed = Color(0xFFFF0000);

  /// Green color for various indicators (colors.xml: "GreenLight").
  static const Color greenLight = Color(0xFF2ECC71);

  /// Background grey color (colors.xml: "background_gray").
  static const Color backgroundGrey = Color(0xFFE0E0E0);

  /// Dark grey background (colors.xml: "BgDarkGray") used for bottom bar.
  static const Color bgDarkGray = Color(0xFF2F3238);

  /// White color.
  static const Color white = Color(0xFFFFFFFF);

  /// Black color.
  static const Color black = Color(0xFF000000);

  /// Archive blue (colors.xml: "ArchiveBlue") - used for badges.
  static const Color archiveBlue = Color(0xFF1ABC9C);

  /// NPS background yellow (colors.xml: "nps_background" / "comp_child_background").
  static const Color lightYellowBg = Color(0xFFFFF8D9);

  /// Gray color for texts (colors.xml: "Gray").
  static const Color gray = Color(0xFF808080);

  /// Section text color (colors.xml: "section_text_color").
  static const Color sectionTextColor = Color(0xFFF7931E);

  /// Facebook blue (colors.xml: "com_facebook_button_login_background_color").
  static const Color facebookBlue = Color(0xFF4267B2);

  /// Continue button dark background matching rect_round_mob drawable.
  static const Color darkButtonBg = Color(0xFF2F3238);

  // PUBLIC_INTERFACE
  /// Returns the main light theme for the app, closely matching
  /// the Connected_Living Android app's Theme.RideKaro.
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
        elevation: 4,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF8CE52),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontFamily: 'ProductSans',
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
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'ProductSans'),
        bodyMedium: TextStyle(fontFamily: 'ProductSans'),
        bodySmall: TextStyle(fontFamily: 'ProductSans'),
        titleLarge: TextStyle(fontFamily: 'ProductSans'),
        titleMedium: TextStyle(fontFamily: 'ProductSans'),
        titleSmall: TextStyle(fontFamily: 'ProductSans'),
        labelLarge: TextStyle(fontFamily: 'ProductSans'),
        labelMedium: TextStyle(fontFamily: 'ProductSans'),
        labelSmall: TextStyle(fontFamily: 'ProductSans'),
      ),
      fontFamily: 'ProductSans',
    );
  }
}
