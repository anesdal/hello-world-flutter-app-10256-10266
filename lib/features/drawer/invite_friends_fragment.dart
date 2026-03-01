import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_karo/shared/app_theme.dart';

/// Invite Friends screen matching the Kotlin [InviteFriendsFragment].
///
/// Allows users to share the app via share sheet, copy referral code,
/// and navigate to contact-based SMS invites.
class InviteFriendsFragment extends StatelessWidget {
  /// Creates the invite friends fragment widget.
  const InviteFriendsFragment({super.key});

  static const String _referralCode = 'RIDEKARO2024';
  static const String _shareMessage =
      'Hey! Try Ride Karo - India\'s beloved bike taxi service. '
      'Use my referral code $_referralCode to get a discount on your first ride! '
      'Download now.';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Header illustration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryYellow, AppTheme.accentOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.people, size: 60, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Invite Friends',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Invite friends and get rewards',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Referral code section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  _referralCode,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.content_copy,
                      color: AppTheme.accentOrange),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Share via button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _shareApp(context),
              icon: const Icon(Icons.share, color: Colors.black),
              label: const Text(
                'Share via',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Invite via SMS button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _sendSMS(context),
              icon: const Icon(Icons.sms, color: AppTheme.accentOrange),
              label: const Text(
                'Invite via SMS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accentOrange,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Terms and conditions
          Text(
            'Terms and Conditions',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    // Use SMS as a simple share fallback (matching Android share sheet)
    final uri = Uri.parse(
        'sms:?body=${Uri.encodeComponent(_shareMessage)}');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open share')),
        );
      }
    }
  }

  Future<void> _sendSMS(BuildContext context) async {
    final uri = Uri.parse(
        'sms:?body=${Uri.encodeComponent(_shareMessage)}');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open SMS')),
        );
      }
    }
  }
}
