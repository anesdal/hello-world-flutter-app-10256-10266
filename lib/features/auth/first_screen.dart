import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/second_screen.dart';

/// First screen shown to new users, requesting location permissions.
///
/// Mirrors the Kotlin [FirstScreenActivity] which requests fine location
/// permission and then routes to [SecondScreen].
class FirstScreen extends StatelessWidget {
  /// Creates the first screen widget.
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon / branding area
              const Icon(
                Icons.two_wheeler,
                size: 120,
                color: AppTheme.primaryYellow,
              ),
              const SizedBox(height: 24),
              const Text(
                "India's Beloved Bike Taxi Service",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'To have a comfortable ride experience with RideKaro,\nplease allow us the following permissions',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Permission descriptions
              _buildPermissionItem(
                Icons.location_on,
                'Location: To locate you and get rides easily',
              ),
              const SizedBox(height: 12),
              _buildPermissionItem(
                Icons.phone,
                'Phone: To verify your account and secure it',
              ),
              const SizedBox(height: 40),
              // Allow Permissions button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _requestPermissions(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Allow Permissions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Made in India 🇮🇳',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentOrange, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _requestPermissions(BuildContext context) async {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Save that first-run is complete
    await PreferenceHelper.writeBool(AppConstants.loginCheck, false);

    // Navigate to SecondScreen regardless (matching Kotlin behavior)
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SecondScreen()),
      );
    }
  }
}
