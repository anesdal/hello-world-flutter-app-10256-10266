import 'package:shared_preferences/shared_preferences.dart';

/// Singleton wrapper around [SharedPreferences], mirroring the Kotlin
/// `PreferenceHelper` companion object from the original app.
///
/// Usage:
/// ```dart
/// await PreferenceHelper.init();
/// PreferenceHelper.writeBool('key', true);
/// ```
class PreferenceHelper {
  PreferenceHelper._();

  static SharedPreferences? _prefs;

  // PUBLIC_INTERFACE
  /// Initializes SharedPreferences. Must be called before any read/write.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // PUBLIC_INTERFACE
  /// Writes an integer value to preferences.
  static Future<void> writeInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  // PUBLIC_INTERFACE
  /// Writes a boolean value to preferences.
  static Future<void> writeBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // PUBLIC_INTERFACE
  /// Writes a string value to preferences.
  static Future<void> writeString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  // PUBLIC_INTERFACE
  /// Reads an integer from preferences, defaulting to 0.
  static int getInt(String key) {
    return _prefs?.getInt(key) ?? 0;
  }

  // PUBLIC_INTERFACE
  /// Reads a string from preferences, defaulting to "en".
  static String getString(String key) {
    return _prefs?.getString(key) ?? 'en';
  }

  // PUBLIC_INTERFACE
  /// Reads a boolean from preferences, defaulting to [defaultValue].
  static bool getBool(String key, {bool defaultValue = true}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // PUBLIC_INTERFACE
  /// Reads a login boolean from preferences, defaulting to false.
  static bool getLoginBool(String key) {
    return _prefs?.getBool(key) ?? false;
  }

  // PUBLIC_INTERFACE
  /// Clears all preferences (used for logout).
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
