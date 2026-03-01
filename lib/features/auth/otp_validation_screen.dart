import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/otp_second_screen.dart';
import 'package:ride_karo/features/home/home_activity.dart';

/// Phone number entry and Google Sign-In screen.
///
/// Mirrors the Kotlin [OTPValidation] activity which provides:
/// - Phone number input with Continue button for OTP flow
/// - Google Sign-In button for OAuth flow
/// - Facebook and Apple sign-in buttons (UI only, matching original)
class OTPValidationScreen extends StatefulWidget {
  /// Creates the OTP validation screen.
  const OTPValidationScreen({super.key});

  @override
  State<OTPValidationScreen> createState() => _OTPValidationScreenState();
}

class _OTPValidationScreenState extends State<OTPValidationScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // App branding
              const Icon(
                Icons.two_wheeler,
                size: 80,
                color: AppTheme.primaryYellow,
              ),
              const SizedBox(height: 16),
              const Text(
                'Login or Register',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              // Phone number input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Country code
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: const Text(
                        '🇮🇳 +91',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 8),
                    // Phone input field
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Enter Mobile Number',
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Continue button with long-press OTP bypass for debug/testing
              SizedBox(
                width: double.infinity,
                height: 50,
                child: GestureDetector(
                  onLongPress: _bypassLoginForTesting,
                  child: ElevatedButton(
                    onPressed: _onContinueWithPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
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
              const SizedBox(height: 24),
              // OR divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              // Google Sign-In button
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                color: Colors.white,
                textColor: Colors.black,
                borderColor: Colors.grey.shade300,
                onTap: _onGoogleSignIn,
              ),
              const SizedBox(height: 12),
              // Facebook Sign-In button (UI only)
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Continue with Facebook',
                color: const Color(0xFF1877F2),
                textColor: Colors.white,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Facebook login coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Apple Sign-In button (UI only)
              _buildSocialButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                color: Colors.black,
                textColor: Colors.white,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apple login coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'By continuing you will agree to our terms and\nprivacy policy of Rapido',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor, size: 24),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  /// DEBUG/TESTING ONLY: Bypasses phone number + OTP flow on long-press.
  ///
  /// Skips phone validation and OTP entirely, saves login state, and
  /// navigates directly to [HomeActivity]. Similar to the Connected_Living
  /// Kotlin debug long-press Continue behavior.
  void _bypassLoginForTesting() async {
    await PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(
      AppConstants.keyDisplayName,
      'Test User (OTP Bypass)',
    );

    if (!mounted) return;

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

  void _onContinueWithPhone() {
    final phone = _phoneController.text.trim();
    if (phone.length == 10) {
      PreferenceHelper.writeBool(AppConstants.userPhoneLogin, true);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OTPSecondScreen(mobileNumber: phone),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter 10 digits mobile number')),
      );
    }
  }

  void _onGoogleSignIn() async {
    // Simulate Google Sign-In (Firebase integration would be added later)
    // For now, save preferences and navigate to home
    await PreferenceHelper.writeBool(AppConstants.keyLoginWithOAuth, true);
    await PreferenceHelper.writeBool(AppConstants.keyUserLoggedIn, true);
    await PreferenceHelper.writeString(AppConstants.keyDisplayName, 'User');
    await PreferenceHelper.writeString(
      AppConstants.keyUserGoogleGmail,
      'user@gmail.com',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome!')),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeActivity(
          userName: 'User',
          userEmail: 'user@gmail.com',
        ),
      ),
      (route) => false,
    );
  }
}
