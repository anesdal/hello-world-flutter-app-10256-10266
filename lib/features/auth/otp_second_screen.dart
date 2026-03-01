import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/home/home_activity.dart';

/// OTP code entry screen matching Kotlin [OTPSecondActivity].
///
/// The user enters the OTP code received via SMS and verifies it.
/// Currently simulates verification (Firebase Auth would be added later).
class OTPSecondScreen extends StatefulWidget {
  /// Creates the OTP second screen.
  const OTPSecondScreen({super.key, required this.mobileNumber});

  /// The phone number to verify.
  final String mobileNumber;

  @override
  State<OTPSecondScreen> createState() => _OTPSecondScreenState();
}

class _OTPSecondScreenState extends State<OTPSecondScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppTheme.primaryYellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter verification pin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seat back and relax while we verify your phone number\n+91 ${widget.mobileNumber}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            // OTP input
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for OTP...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            // Verify button with long-press OTP bypass for debug/testing
            SizedBox(
              width: double.infinity,
              height: 50,
              child: GestureDetector(
                onLongPress: _isVerifying ? null : _bypassOTPForTesting,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DEBUG/TESTING ONLY: Bypasses OTP verification on long-press of Continue.
  ///
  /// Skips the OTP code check and directly saves login state, then navigates
  /// to [HomeActivity]. Similar to the Connected_Living Kotlin debug
  /// long-press Continue behavior.
  void _bypassOTPForTesting() async {
    setState(() {
      _isVerifying = true;
    });

    // Save login state without actual OTP verification
    await PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(
      AppConstants.keyDisplayName,
      'Test User (OTP Bypass)',
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('DEBUG: OTP bypass activated'),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeActivity()),
      (route) => false,
    );
  }

  void _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate OTP verification delay
    await Future.delayed(const Duration(seconds: 1));

    // Save login state
    await PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(
      AppConstants.keyDisplayName,
      'Phone User',
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeActivity()),
      (route) => false,
    );
  }
}
