import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/faqs_model.dart';

/// Support/FAQ screen matching the Kotlin [SupportFragment].
///
/// Displays a search bar and FAQ grid using a [GridView] with 3 columns,
/// matching the original RecyclerView + GridLayoutManager(3) layout.
class SupportFragment extends StatelessWidget {
  /// Creates the support fragment widget.
  const SupportFragment({super.key});

  /// FAQ items matching the Kotlin buildData() method.
  static const List<FAQsModel> _faqItems = [
    FAQsModel(icon: Icons.shield, title: 'Safety &\nSecurity'),
    FAQsModel(icon: Icons.two_wheeler, title: 'Ride &\nBilling'),
    FAQsModel(icon: Icons.build, title: 'Services'),
    FAQsModel(icon: Icons.person, title: 'Account\n& App'),
    FAQsModel(icon: Icons.people, title: 'Referrals'),
    FAQsModel(icon: Icons.account_balance_wallet, title: 'Payment\n& Wallets'),
    FAQsModel(icon: Icons.card_membership, title: 'Power\nPass'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search issue',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // "Having an issue?" header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Having an issue?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // FAQ Grid matching GridLayoutManager(context, 3)
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: _faqItems.length,
            itemBuilder: (context, index) {
              final item = _faqItems[index];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.title.replaceAll('\n', ' ')} tapped'),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: AppTheme.accentOrange, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Get Help + View all tickets
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Get Help',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View all tickets',
                  style: TextStyle(color: AppTheme.accentOrange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
