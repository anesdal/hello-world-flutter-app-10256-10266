import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/constants.dart';
import 'package:ride_karo/shared/ride_state.dart';
import 'package:ride_karo/features/home/payment_method_sheet.dart';

/// Ride request bottom sheet matching the Kotlin [BottomSheetFragment].
///
/// Displays distance, fare (distance * 10), and a Request Ride button.
/// Also provides access to payment method selection.
class RideBottomSheet extends StatelessWidget {
  /// Creates the ride bottom sheet widget.
  const RideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RideState>(
      builder: (context, rideState, _) {
        final distance = rideState.distance;
        final fare = (distance * AppConstants.fareRate).toInt();

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Distance row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Distance',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    '${distance.toStringAsFixed(1)} KM',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Fare row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount to be paid',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    '₹ $fare',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Apply coupon row
              Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.grey.shade500, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Apply Coupon Code',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Payment method row (tappable)
              GestureDetector(
                onTap: () => _showPaymentMethod(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: AppTheme.accentOrange),
                      SizedBox(width: 12),
                      Text(
                        'Cash',
                        style: TextStyle(fontSize: 15),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Request Ride button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _onRequestRide(context, rideState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Request Ride',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentMethod(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PaymentMethodSheet(),
    );
  }

  void _onRequestRide(BuildContext context, RideState rideState) {
    // Signal ride requested (matching Kotlin afterClickingRideNow.setMapRider)
    rideState.requestRide();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ride Booked! The Rider is on his way to your location'),
        duration: Duration(seconds: 2),
      ),
    );

    // Dismiss bottom sheet
    Navigator.of(context).pop();
  }
}
