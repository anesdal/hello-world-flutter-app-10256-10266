import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/language_screen.dart';
import 'package:ride_karo/features/auth/otp_validation_screen.dart';
import 'package:ride_karo/features/home/home_activity.dart';

/// Splash/routing screen shown after first run is complete.
///
/// Mirrors the Kotlin [SecondScreenActivity] and its layout
/// `activity_second_screen.xml` — features a centered bike icon,
/// "Ride Karo" text, horizontal progress bar, and "Made in India" at bottom.
class SecondScreen extends StatefulWidget {
  /// Creates the second screen widget.
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  void initState() {
    super.initState();
    _routeAfterDelay();
  }

  Future<void> _routeAfterDelay() async {
    // Matches Kotlin Handler().postDelayed(1000)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final bool languageFlag =
        PreferenceHelper.getBool(AppConstants.languageBoolean);

    String destination = 'otp'; // default

    if (languageFlag) {
      destination = 'language';
    } else {
      final bool phoneLogin =
          PreferenceHelper.getLoginBool(AppConstants.userPhoneLogin);
      final bool oauthLogin =
          PreferenceHelper.getLoginBool(AppConstants.keyLoginWithOAuth);

      if (phoneLogin || oauthLogin) {
        destination = 'home';
      } else {
        destination = 'otp';
      }
    }

    if (!mounted) return;

    Widget nextScreen;
    switch (destination) {
      case 'language':
        nextScreen = const LanguageScreen();
        break;
      case 'home':
        nextScreen = const HomeActivity();
        break;
      case 'otp':
      default:
        nextScreen = const OTPValidationScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen matching activity_second_screen.xml:
    // White background, centered icon, app name, progress bar, "Made in India"
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Centered bike icon — matches ivSplashScreenImage
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.splashBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.two_wheeler,
                  size: 80,
                  color: AppTheme.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // App name text — matches tvRideKaro
            const Text(
              'Ride Karo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 16),
            // Progress indicator — matches ProgressBar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 80),
              child: LinearProgressIndicator(
                color: AppTheme.black,
                backgroundColor: AppTheme.backgroundGrey,
              ),
            ),
            const Spacer(),
            // "Made in India" text at bottom — matches tvMadeInIndia
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Made in India 🇮🇳',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'ProductSans',
                  color: AppTheme.gray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
