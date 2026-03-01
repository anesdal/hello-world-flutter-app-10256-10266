import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ride_karo/shared/app_theme.dart';

/// Celebration screen shown after ride completion.
///
/// Mirrors the Kotlin [LetsCelebrate] activity which shows a Lottie
/// `celebrate.json` animation and a congratulatory message.
/// Uses the same Lottie animation asset from the original app's raw folder.
class LetsCelebrateScreen extends StatelessWidget {
  /// Creates the celebration screen widget.
  const LetsCelebrateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryYellow,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie celebration animation — matches the original
              // celebrate.json from res/raw/
              SizedBox(
                width: 200,
                height: 200,
                child: Lottie.asset(
                  'assets/animations/celebrate.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if Lottie fails
                    return const Icon(
                      Icons.celebration,
                      size: 120,
                      color: AppTheme.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // "Hurray!" text — matches the original
              const Text(
                'Hurray! 🎉',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ProductSans',
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 16),
              // Completion message — matches the original string resource
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Your ride is complete! Don't forget to rate us on playstore",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'ProductSans',
                    color: AppTheme.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              // Back to home button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.white,
                  foregroundColor: AppTheme.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Let's Ride Again!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
