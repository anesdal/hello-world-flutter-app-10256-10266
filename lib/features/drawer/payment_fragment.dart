import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_karo/shared/app_theme.dart';

/// Payment screen matching the Kotlin [PaymentFragment] drawer section.
///
/// Shows payment options (Paytm, Mobikwik, Google Pay) with deep-link launching
/// and a payment confirmation dialog flow.
class PaymentFragment extends StatelessWidget {
  /// Creates the payment fragment widget.
  const PaymentFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet section
          const Text(
            'PAYMENT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Personal wallet card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: AppTheme.accentOrange),
                      SizedBox(width: 8),
                      Text(
                        '₹ 0.0',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Recharge',
                        style: TextStyle(
                          color: AppTheme.accentOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // QR pay section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              leading: Icon(Icons.qr_code, color: AppTheme.accentOrange),
              title: Text('QR Pay'),
              subtitle: Text(
                'Go cashless, after ride pay by scanning QR code',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Other payment methods
          const Text(
            'Other Payment Methods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          // Paytm
          _buildPaymentTile(
            context,
            icon: Icons.account_balance_wallet,
            name: 'Paytm',
            linkText: 'Link',
            color: const Color(0xFF00BAF2),
            onTap: () => _launchApp(context, 'paytm://', 'Install PayTm on your device'),
          ),
          // Mobikwik
          _buildPaymentTile(
            context,
            icon: Icons.wallet,
            name: 'Mobikwik',
            linkText: 'Link',
            color: Colors.red,
            onTap: () => _launchApp(context, 'mobikwik://', 'Install Mobikwik on your device'),
          ),
          // Google Pay
          _buildPaymentTile(
            context,
            icon: Icons.payment,
            name: 'Google Pay',
            linkText: 'Link',
            color: const Color(0xFF4285F4),
            onTap: () => _launchApp(context, 'gpay://', 'Install GooglePay on your device'),
          ),
          const SizedBox(height: 16),
          // Pay Cash / Complete button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showPaymentDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTile(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String linkText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color),
        ),
        title: Text(name),
        trailing: GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              color: AppTheme.accentOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchApp(BuildContext context, String uriString, String fallbackMsg) async {
    try {
      final launched = await launchUrl(
        Uri.parse(uriString),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackMsg)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackMsg)),
        );
      }
    }
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Alert'),
        content: const Text('Complete the Transaction'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment Failed')),
              );
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Congratulations Payment successful Done'),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
