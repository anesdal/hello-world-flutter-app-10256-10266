import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/second_screen.dart';

/// First screen shown to new users, requesting location permissions.
///
/// Mirrors the Kotlin [FirstScreenActivity] and its layout
/// `activity_first_screen.xml` — featuring a bike icon at the top,
/// bold title "India's Beloved Bike Taxi Service", permission descriptions
/// with pin/phone icons, and a yellow "Allow Permissions" button.
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
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bike icon area — matches ivRideKaroImage in original layout
            // The original uses a custom drawable `ic_ride_karo_image` which is
            // a yellow bike on a golden card-like background.
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Container(
                  width: 180,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.two_wheeler,
                      size: 90,
                      color: AppTheme.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title text — matches tvIndia_beloved
            const Text(
              "India's Beloved Bike Taxi Service",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
                color: AppTheme.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Subtitle — matches tvComfortable + tvPleaseAllow
            const Text(
              'To have a comfortable ride experience with RideKaro,',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'please allow us the following permissions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'ProductSans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            // Permission items — matches location and phone LinearLayouts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildPermissionItem(
                    Icons.location_on,
                    Colors.orange,
                    'Location: To locate you and get rides easily',
                  ),
                  const SizedBox(height: 20),
                  _buildPermissionItem(
                    Icons.phone,
                    Colors.green,
                    'Phone: To verify your account and secure it',
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Allow Permissions button — matches btnAllowPermission with
            // ic_rectangle_button background (yellow rounded rectangle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _handleAllowPermissions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ProductSans',
                            color: AppTheme.black,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Builds a single permission description row with an icon and text,
  /// matching the original layout's LinearLayout with icon + TextView.
  Widget _buildPermissionItem(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
        ),
      ],
    );
  }

  /// Handles the "Allow Permissions" button tap.
  ///
  /// Requests location permission via geolocator, then saves the first-run
  /// flag and navigates to [SecondScreen].
  void _handleAllowPermissions() {
    setState(() {
      _isRequesting = true;
    });

    final NavigatorState navigator = Navigator.of(context);
    _requestPermissionsAndNavigate(navigator);
  }

  Future<void> _requestPermissionsAndNavigate(
    NavigatorState navigator,
  ) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint('Permission request failed: $e');
    }

    try {
      await PreferenceHelper.writeBool(AppConstants.loginCheck, false);
    } catch (e) {
      debugPrint('Failed to save preference: $e');
    }

    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const SecondScreen()),
    );
  }
}
