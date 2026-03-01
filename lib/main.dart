import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/shared/ride_state.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/features/auth/first_screen.dart';
import 'package:ride_karo/features/auth/second_screen.dart';

/// Main entry point for the Ride Karo Flutter app.
///
/// This mirrors the Kotlin [MainActivity] which reads the loginCheck preference
/// and routes to either [FirstScreen] or [SecondScreen].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHelper.init();
  runApp(const RideKaroApp());
}

// PUBLIC_INTERFACE
/// Root widget of the Ride Karo application.
class RideKaroApp extends StatelessWidget {
  /// Creates the root app widget.
  const RideKaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RideState(),
      child: MaterialApp(
        title: 'Ride Karo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppRouter(),
      ),
    );
  }
}

/// Initial routing widget that checks login state and navigates accordingly.
/// Mirrors [MainActivity.onCreate] preference-based routing.
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    // Matches Kotlin: if loginCheck is true (default), go to FirstScreen
    // If false (already completed first run), go to SecondScreen
    final bool loginCheck = PreferenceHelper.getBool(AppConstants.loginCheck);

    if (loginCheck) {
      return const FirstScreen();
    } else {
      return const SecondScreen();
    }
  }
}
