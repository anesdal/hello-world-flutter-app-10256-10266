import 'package:flutter/foundation.dart';

/// Central ride state management using ChangeNotifier (replaces ViewModels).
///
/// Mirrors the Kotlin ViewModels:
/// - [DistanceViewModel] -> [distance]
/// - [AfterClickingRideNow] -> [rideRequested]
/// - [LocationViewModel] -> [destinationAddress]
/// - [LatLongViewModel] -> [destinationLat], [destinationLng]
class RideState extends ChangeNotifier {
  double _distance = 0.0;
  bool _rideRequested = false;
  String _destinationAddress = '';
  double _destinationLat = 0.0;
  double _destinationLng = 0.0;
  String _currentAddress = '';

  // PUBLIC_INTERFACE
  /// Current trip distance in KM.
  double get distance => _distance;

  // PUBLIC_INTERFACE
  /// Whether a ride has been requested.
  bool get rideRequested => _rideRequested;

  // PUBLIC_INTERFACE
  /// The destination address text.
  String get destinationAddress => _destinationAddress;

  // PUBLIC_INTERFACE
  /// Destination latitude.
  double get destinationLat => _destinationLat;

  // PUBLIC_INTERFACE
  /// Destination longitude.
  double get destinationLng => _destinationLng;

  // PUBLIC_INTERFACE
  /// Current user address.
  String get currentAddress => _currentAddress;

  // PUBLIC_INTERFACE
  /// Sets the trip distance and notifies listeners.
  void setDistance(double d) {
    _distance = d;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Signals that a ride has been requested.
  void requestRide() {
    _rideRequested = true;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Sets the destination address and notifies listeners.
  void setDestinationAddress(String address) {
    _destinationAddress = address;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Sets the destination coordinates.
  void setDestinationCoords(double lat, double lng) {
    _destinationLat = lat;
    _destinationLng = lng;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Sets the current address text.
  void setCurrentAddress(String address) {
    _currentAddress = address;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Resets ride state for a new ride.
  void reset() {
    _distance = 0.0;
    _rideRequested = false;
    _destinationAddress = '';
    _destinationLat = 0.0;
    _destinationLng = 0.0;
    notifyListeners();
  }
}
