import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_karo/shared/app_theme.dart';

/// Payment method selection bottom sheet matching [PaymentMethodFragment].
///
/// Provides quick access to Paytm, Google Pay, and PhonePe via deep links.
/// Falls back to showing a "not installed" message.
class PaymentMethodSheet extends StatelessWidget {
  /// Creates the payment method sheet widget.
  const PaymentMethodSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Other Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            context,
            icon: Icons.account_balance_wallet,
            name: 'Paytm',
            color: const Color(0xFF00BAF2),
            onTap: () => _launchPaymentApp(context, 'paytm://'),
          ),
          const Divider(height: 1),
          _buildPaymentOption(
            context,
            icon: Icons.payment,
            name: 'Google Pay',
            color: const Color(0xFF4285F4),
            onTap: () => _launchPaymentApp(context, 'gpay://'),
          ),
          const Divider(height: 1),
          _buildPaymentOption(
            context,
            icon: Icons.phone_android,
            name: 'PhonePe',
            color: const Color(0xFF5F259F),
            onTap: () => _launchPaymentApp(context, 'phonepe://'),
          ),
          const Divider(height: 1),
          _buildPaymentOption(
            context,
            icon: Icons.money,
            name: 'Cash',
            color: Colors.green,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required IconData icon,
    required String name,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(30),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: const TextStyle(fontSize: 15)),
      trailing: const Text(
        'Link',
        style: TextStyle(color: AppTheme.accentOrange, fontSize: 13),
      ),
      onTap: onTap,
    );
  }

  Future<void> _launchPaymentApp(BuildContext context, String uriString) async {
    final uri = Uri.parse(uriString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment app not installed on device')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment app not installed on device')),
        );
      }
    }
  }
}
