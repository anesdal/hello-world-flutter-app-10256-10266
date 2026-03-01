import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/preference_helper.dart';
import 'package:ride_karo/features/auth/language_screen.dart';
import 'package:ride_karo/features/auth/otp_validation_screen.dart';

/// Settings screen matching the Kotlin [SettingsFragment].
///
/// Shows profile, favorites, app language, shortcuts, about, and logout.
/// Language selection opens the LanguageScreen matching the original flow.
class SettingsFragment extends StatelessWidget {
  /// Creates the settings fragment widget.
  const SettingsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = PreferenceHelper.getString(AppConstants.languagePreferenceString);
    String languageName;
    switch (langCode) {
      case 'hi':
        languageName = 'Hindi';
        break;
      case 'kn':
        languageName = 'Kannada';
        break;
      case 'ta':
        languageName = 'Tamil';
        break;
      case 'te':
        languageName = 'Telugu';
        break;
      case 'en':
      default:
        languageName = 'English';
        break;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // General section
        const Text(
          'General',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingsItem(
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () {},
        ),
        _buildSettingsItem(
          icon: Icons.favorite_border,
          title: 'Favorites',
          subtitle: 'Manage favorite locations',
          onTap: () {},
        ),
        _buildSettingsItem(
          icon: Icons.language,
          title: 'App Language',
          trailing: Text(
            languageName,
            style: const TextStyle(color: AppTheme.accentOrange),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageScreen()),
            );
          },
        ),
        _buildSettingsItem(
          icon: Icons.shortcut,
          title: 'App Shortcuts',
          subtitle: 'Create shortcuts on home launcher',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        // Others section
        const Text(
          'Others',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: '5.5.27',
          onTap: () {},
        ),
        _buildSettingsItem(
          icon: Icons.science,
          title: 'Subscribe to Beta',
          subtitle: 'Get early access to latest features',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        // Logout button
        _buildSettingsItem(
          icon: Icons.logout,
          title: 'Logout',
          titleColor: Colors.red,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? Colors.grey.shade700),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: titleColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              )
            : null,
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await PreferenceHelper.clear();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const OTPValidationScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
