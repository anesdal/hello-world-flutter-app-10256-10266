/// Application-wide constants for preference keys and configuration.
///
/// These mirror the SharedPreferences keys from the original Kotlin app
/// in [PreferenceHelper] and [Constants.kt].
library;

// PUBLIC_INTERFACE
/// Preference key constants matching the original Kotlin app.
class AppConstants {
  AppConstants._();

  /// Whether the user has completed first-run permission flow.
  static const String loginCheck = 'loginCheck';

  /// Whether user is logged in.
  static const String keyUserLoggedIn = 'DOESUSERLOGGEDIN';

  /// Cached display name.
  static const String keyDisplayName = 'KEY_DISPLAY_NAME';

  /// Cached Google account ID.
  static const String keyUserGoogleId = 'GOOGLEUSERID';

  /// Whether user authenticated via Google OAuth.
  static const String keyLoginWithOAuth = 'LOGINWITHOAUTH';

  /// Cached Google email.
  static const String keyUserGoogleGmail = 'GOOGLEUSERGMAIL';

  /// Whether user authenticated via phone OTP.
  static const String userPhoneLogin = 'USER_PHONE_LOGIN';

  /// Whether language has been selected.
  static const String languageBoolean = 'languageBoolean';

  /// Selected language code (e.g., "en", "hi").
  static const String languagePreferenceString = 'languagePreferenceString';

  /// Selected language index.
  static const String languagePreference = 'languagePreference';

  /// User photo URL.
  static const String keyUserPhoto = 'KEY_USER_PHOTO';

  /// Fare multiplier per KM (distance * fareRate = fare).
  static const double fareRate = 10.0;
}
