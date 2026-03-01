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
// PUBLIC_INTERFACE
class FirstScreen extends StatefulWidget {
  /// Creates the first screen widget.
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  /// Whether a permission request is currently in progress.
  bool _isRequesting = false;

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
                  onPressed: _isRequesting ? null : _handleAllowPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isRequesting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
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

  /// Builds a single permission description row with an icon and text.
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

  /// Handles the "Allow Permissions" button tap.
  ///
  /// Requests location permission via geolocator, then saves the first-run
  /// flag and navigates to [SecondScreen]. If the permission request fails
  /// (e.g., on web or emulator), navigation still proceeds to avoid blocking
  /// the user flow.
  void _handleAllowPermissions() {
    // Mark button as in-progress to prevent double taps
    setState(() {
      _isRequesting = true;
    });

    // Perform permission request and navigation in a separate async method.
    // We capture the NavigatorState before the async gap to avoid using
    // BuildContext across an async boundary.
    final NavigatorState navigator = Navigator.of(context);
    _requestPermissionsAndNavigate(navigator);
  }

  Future<void> _requestPermissionsAndNavigate(
    NavigatorState navigator,
  ) async {
    // Attempt to request location permission; catch any errors so the
    // user is never stuck on this screen.
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      // Permission request failed (e.g., missing manifest entry, web
      // platform, or emulator limitations). Log and proceed anyway.
      debugPrint('Permission request failed: $e');
    }

    // Save that first-run is complete regardless of permission outcome
    // (matching Kotlin behavior where navigation always occurs).
    try {
      await PreferenceHelper.writeBool(AppConstants.loginCheck, false);
    } catch (e) {
      debugPrint('Failed to save preference: $e');
    }

    // Navigate to SecondScreen (the splash/routing screen).
    // Using the pre-captured NavigatorState avoids BuildContext usage
    // after async gaps.
    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const SecondScreen()),
    );
  }
}
