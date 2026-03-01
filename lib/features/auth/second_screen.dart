import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/language_screen.dart';
import 'package:ride_karo/features/auth/otp_validation_screen.dart';
import 'package:ride_karo/features/home/home_activity.dart';

/// Splash/routing screen shown after first run is complete.
///
/// Mirrors the Kotlin [SecondScreenActivity] which evaluates language selection,
/// OAuth login, and phone login states with a 1-second delay before routing.
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

    final bool languageFlag = PreferenceHelper.getBool(AppConstants.languageBoolean);

    String destination = 'otp'; // default

    if (languageFlag) {
      // Language not yet selected
      destination = 'language';
    } else {
      final bool phoneLogin = PreferenceHelper.getLoginBool(AppConstants.userPhoneLogin);
      final bool oauthLogin = PreferenceHelper.getLoginBool(AppConstants.keyLoginWithOAuth);

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
    // Splash screen shown during the 1-second delay
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.two_wheeler,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Ride Karo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black.withAlpha(40),
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
