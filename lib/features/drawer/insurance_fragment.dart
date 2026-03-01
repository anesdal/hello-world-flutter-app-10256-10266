import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';

/// Insurance screen matching the Kotlin [InsuranceFragment].
///
/// Displays static insurance information including policy coverage,
/// claim procedures, and a claim button.
class InsuranceFragment extends StatelessWidget {
  /// Creates the insurance fragment widget.
  const InsuranceFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  size: 50,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Insurance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Powered by Acko',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Policy coverage section
          const Text(
            'Policy Coverage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCoverageItem(
            Icons.personal_injury,
            'Personal Accident/Accidental Death',
          ),
          _buildCoverageItem(
            Icons.local_hospital,
            'OPD Treatment',
          ),
          _buildCoverageItem(
            Icons.medical_services,
            'Medical Expense for Hospitalization',
          ),
          const SizedBox(height: 20),
          // Claim procedure section
          const Text(
            'Claim Procedure',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your correct email-id, date of birth and '
            'phone number to avoid cancellations of your Insurance claim.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Legal',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade600,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 24),
          // Claim button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Insurance claim feature coming soon'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'CLAIM INSURANCE',
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

  Widget _buildCoverageItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
