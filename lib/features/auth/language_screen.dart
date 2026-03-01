import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/otp_validation_screen.dart';

/// Language selection screen matching the Kotlin [LanguageScreenActivity].
///
/// Mirrors `activity_language_screen.xml` — allows user to choose from
/// English, Hindi, Kannada, Telugu, or Tamil.
/// Persists the selection and navigates to OTP validation.
class LanguageScreen extends StatefulWidget {
  /// Creates the language screen widget.
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int _selectedIndex = 0;

  /// Language options matching the Kotlin string-array resource.
  static const List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'हिंदी (Hindi)', 'code': 'hi'},
    {'name': 'ಕನ್ನಡ (Kannada)', 'code': 'kn'},
    {'name': 'తెలుగు (Telugu)', 'code': 'te'},
    {'name': 'தமிழ் (Tamil)', 'code': 'ta'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title — matches "Welcome to Ride Karo"
              const Text(
                'Welcome to Ride Karo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ProductSans',
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle — matches "Choose a language to get started"
              Text(
                'Choose a language to get started',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'ProductSans',
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              // Language list — matches item_layout_language style
              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryYellow.withAlpha(50)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryYellow
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                lang['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'ProductSans',
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryYellow,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // NEXT button — matches ic_rectangle_next style (yellow rounded)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ProductSans',
                      color: AppTheme.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() async {
    final lang = _languages[_selectedIndex];
    await PreferenceHelper.writeBool(AppConstants.languageBoolean, false);
    await PreferenceHelper.writeString(
      AppConstants.languagePreferenceString,
      lang['code']!,
    );
    await PreferenceHelper.writeInt(
      AppConstants.languagePreference,
      _selectedIndex,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OTPValidationScreen()),
    );
  }
}
