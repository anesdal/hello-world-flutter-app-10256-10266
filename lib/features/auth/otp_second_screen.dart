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
///
/// **Debug bypass**: Long-press OR triple-tap the Continue button to skip OTP
/// verification and navigate directly to [HomeActivity]. This dual-trigger
/// approach ensures the bypass works reliably in web previews, emulators
/// (e.g. Appetize.io), and physical devices where long-press may be
/// intercepted by the host browser.
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

  /// Tracks rapid consecutive taps for triple-tap bypass detection.
  int _tapCount = 0;

  /// Timestamp of the last tap, used to reset the counter after a pause.
  DateTime _lastTapTime = DateTime.now();

  /// Whether the bypass navigation has already been triggered, preventing
  /// duplicate navigations from concurrent gesture callbacks.
  bool _bypassTriggered = false;

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
            // Visible Skip OTP button for testing/preview environments
            // (e.g. Appetize.io) where long-press and triple-tap gestures
            // are intercepted by the host browser and never reach Flutter.
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _isVerifying ? null : _bypassOTPForTesting,
                icon: const Icon(Icons.skip_next, color: Colors.white),
                label: const Text(
                  'Skip OTP (Testing Only)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Verify button with long-press AND triple-tap OTP bypass for
            // debug/testing.
            //
            // We use a single GestureDetector with a styled Container instead
            // of wrapping an ElevatedButton, because ElevatedButton's internal
            // InkWell gesture recognizer wins the gesture arena and prevents
            // the parent GestureDetector from ever receiving the long-press.
            //
            // HitTestBehavior.opaque ensures that taps landing anywhere in
            // the bounding box are captured by *this* detector, even in web
            // preview environments where transparent regions might be ignored.
            //
            // The triple-tap fallback exists because Appetize.io and some
            // browser-based emulators intercept long-press as a context-menu
            // gesture and never forward it to the Flutter engine.
            SizedBox(
              width: double.infinity,
              height: 50,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isVerifying ? null : _onContinueTap,
                onLongPress: _isVerifying ? null : _bypassOTPForTesting,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isVerifying
                        ? AppTheme.primaryYellow.withAlpha(153)
                        : AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'CONTINUE',
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

  /// Handles a single tap on the Continue button.
  ///
  /// If three taps arrive within a 1-second window the bypass is triggered
  /// (triple-tap fallback for environments where long-press is unreliable).
  /// Otherwise the normal OTP verification flow runs.
  void _onContinueTap() {
    final now = DateTime.now();
    // Reset tap counter if more than 1 second has elapsed since the last tap.
    if (now.difference(_lastTapTime).inMilliseconds > 1000) {
      _tapCount = 0;
    }
    _lastTapTime = now;
    _tapCount++;

    if (_tapCount >= 3) {
      // Triple-tap detected — activate bypass.
      _tapCount = 0;
      _bypassOTPForTesting();
    } else {
      // Normal single tap — run standard OTP verification.
      _verifyOTP();
    }
  }

  /// DEBUG/TESTING ONLY: Bypasses OTP verification on long-press (or
  /// triple-tap) of the Continue button.
  ///
  /// Skips the OTP code check and directly saves login state, then navigates
  /// to [HomeActivity]. Similar to the Connected_Living Kotlin debug
  /// long-press Continue behavior.
  void _bypassOTPForTesting() async {
    // Guard against duplicate triggers from concurrent gesture callbacks.
    if (_bypassTriggered) return;
    _bypassTriggered = true;

    // Capture navigator and messenger *before* any async gap to avoid using
    // BuildContext across await boundaries.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isVerifying = true;
    });

    // Save login state without actual OTP verification.
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

    messenger.showSnackBar(
      const SnackBar(
        content: Text('DEBUG: OTP bypass activated'),
        duration: Duration(seconds: 1),
      ),
    );

    navigator.pushAndRemoveUntil(
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
