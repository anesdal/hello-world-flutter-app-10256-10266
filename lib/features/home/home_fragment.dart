import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/ride_state.dart';
import 'package:ride_karo/features/home/location_search_sheet.dart';
import 'package:ride_karo/features/home/bottom_sheet_fragment.dart';
import 'package:ride_karo/features/home/lets_celebrate_screen.dart';

/// Map-centric home fragment matching the Kotlin [HomeFragment].
///
/// Displays a simulated map area with current location, destination entry,
/// rider simulation markers, and the ride booking bottom sheet flow.
/// Uses [Geolocator] for location and [Geocoding] for address resolution.
class HomeFragment extends StatefulWidget {
  /// Creates the home fragment widget.
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  // Location state
  double _userLat = 0.0;
  double _userLng = 0.0;
  double _destLat = 0.0;
  double _destLng = 0.0;
  String _currentAddress = 'Locating...';
  String _destinationText = 'Enter Destination';
  bool _locationLoaded = false;
  bool _hasDestination = false;
  bool _rideInProgress = false;
  bool _riderApproaching = false;
  String _rideStatus = '';

  // Rider simulation state
  double _riderLat = 0.0;
  double _riderLng = 0.0;
  double _journeyLat = 0.0;
  double _journeyLng = 0.0;
  Timer? _riderTimer;
  Timer? _journeyTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _riderTimer?.cancel();
    _journeyTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services disabled';
          _locationLoaded = true;
          // Use default location (Mumbai)
          _userLat = 19.0760;
          _userLng = 72.8777;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = 'Location permission denied';
          _locationLoaded = true;
          _userLat = 19.0760;
          _userLng = 72.8777;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _userLat = position.latitude;
      _userLng = position.longitude;
      // Place rider nearby (matching Kotlin: longitude + 0.009)
      _riderLat = _userLat;
      _riderLng = _userLng + 0.009;

      // Reverse geocode current location
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.street, p.subLocality, p.locality]
              .where((s) => s != null && s.isNotEmpty);
          setState(() {
            _currentAddress = parts.join(', ');
            _locationLoaded = true;
          });
        }
      } catch (_) {
        setState(() {
          _currentAddress = '${_userLat.toStringAsFixed(4)}, ${_userLng.toStringAsFixed(4)}';
          _locationLoaded = true;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Unable to get location';
        _locationLoaded = true;
        _userLat = 19.0760;
        _userLng = 72.8777;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideState>(
      builder: (context, rideState, child) {
        // Listen for ride requested signal
        if (rideState.rideRequested && !_rideInProgress && !_riderApproaching) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startRiderApproach();
          });
        }

        return Stack(
          children: [
            // Map placeholder area
            _buildMapArea(),
            // Top address bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAddressBar(),
            ),
            // Rider markers overlay
            if (_locationLoaded) _buildMarkerOverlay(),
            // Bottom destination bar
            if (!_rideInProgress)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(rideState),
              ),
            // Ride status overlay
            if (_rideInProgress)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _buildRideStatusCard(),
              ),
          ],
        );
      },
    );
  }

  /// Builds the map background area with grid lines to simulate a map.
  Widget _buildMapArea() {
    return Container(
      color: const Color(0xFFE8E4D8),
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  /// Builds the address display bar at the top.
  Widget _buildAddressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.my_location, color: AppTheme.accentOrange, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _currentAddress,
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the marker overlay showing rider and destination pins.
  Widget _buildMarkerOverlay() {
    return Stack(
      children: [
        // Center pin for user location
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 40),
              Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // Rider bike marker (offset from center)
        if (!_rideInProgress)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: MediaQuery.of(context).size.width * 0.15,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.two_wheeler, color: Colors.blue, size: 30),
                Text('Rider', style: TextStyle(fontSize: 9)),
              ],
            ),
          ),
        // Second rider marker
        if (!_rideInProgress)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.2,
            child: const Icon(Icons.two_wheeler, color: Colors.blue, size: 26),
          ),
        // Destination marker
        if (_hasDestination)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.5 - 15,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 36),
                Text('Dest', style: TextStyle(fontSize: 9)),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds the bottom bar with destination entry and ride request.
  Widget _buildBottomBar(RideState rideState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current location row
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentAddress,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          // Destination row (tappable)
          GestureDetector(
            onTap: _openLocationSearch,
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _destinationText,
                      style: TextStyle(
                        color: _hasDestination
                            ? Colors.black
                            : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Show distance info and ride button if destination is set
          if (_hasDestination && rideState.distance > 0) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showRideBottomSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Distance: ${rideState.distance.toStringAsFixed(1)} KM  •  Tap to Book',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a status card during active ride.
  Widget _buildRideStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.two_wheeler, color: AppTheme.accentOrange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _rideStatus,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the destination search bottom sheet.
  void _openLocationSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LocationSearchSheet(
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  /// Called when a destination address is selected.
  void _onDestinationSelected(String address) async {
    final rideState = Provider.of<RideState>(context, listen: false);
    rideState.setDestinationAddress(address);

    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        _destLat = locations.first.latitude;
        _destLng = locations.first.longitude;
        rideState.setDestinationCoords(_destLat, _destLng);

        // Calculate distance (matching Kotlin Location.distanceBetween)
        final distanceMeters = Geolocator.distanceBetween(
          _userLat, _userLng, _destLat, _destLng,
        );
        final distanceKm = distanceMeters / 1000.0;
        final roundedDistance = double.parse(distanceKm.toStringAsFixed(1));
        rideState.setDistance(roundedDistance);
      }
    } catch (e) {
      // Fallback: use a simulated distance
      rideState.setDistance(5.0);
      _destLat = _userLat + 0.04;
      _destLng = _userLng + 0.04;
    }

    setState(() {
      _destinationText = address;
      _hasDestination = true;
    });

    // Auto-show bottom sheet (matching Kotlin behavior)
    if (mounted) {
      _showRideBottomSheet();
    }
  }

  /// Shows the ride request bottom sheet.
  void _showRideBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<RideState>(context, listen: false),
        child: const RideBottomSheet(),
      ),
    );
  }

  /// Starts the rider approach simulation (matching Kotlin startTheLoop).
  void _startRiderApproach() {
    setState(() {
      _riderApproaching = true;
      _rideStatus = 'Hold Tight! Rider is on the way to your location';
    });

    int steps = 0;
    _riderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (steps >= 9) {
        timer.cancel();
        _onRiderArrived();
        return;
      }
      setState(() {
        _riderLng -= 0.001;
      });
      steps++;
    });
  }

  /// Called when rider has arrived. Shows dialog matching Kotlin behavior.
  void _onRiderArrived() {
    setState(() {
      _rideStatus = 'Rider Arrived at your location!';
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rider Arrived'),
        content: const Text('Do You want to start Your journey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _startJourney();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  /// Starts the journey simulation (matching Kotlin letsGo).
  void _startJourney() {
    setState(() {
      _rideInProgress = true;
      _rideStatus = 'Journey in progress...';
      _journeyLat = _userLat;
      _journeyLng = _userLng;
    });

    // Calculate steps needed
    final latDiff = (_destLat - _userLat).abs();
    final lngDiff = (_destLng - _userLng).abs();
    final maxDiff = max(latDiff, lngDiff);
    final totalSteps = (maxDiff / 0.002).ceil().clamp(5, 30);
    final latStep = (_destLat - _userLat) / totalSteps;
    final lngStep = (_destLng - _userLng) / totalSteps;

    int step = 0;
    _journeyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (step >= totalSteps) {
        timer.cancel();
        _onJourneyComplete();
        return;
      }
      setState(() {
        _journeyLat += latStep;
        _journeyLng += lngStep;
        _rideStatus = 'Journey in progress to $_destinationText';
      });
      step++;
    });
  }

  /// Called when journey completes. Navigates to celebration screen.
  void _onJourneyComplete() {
    setState(() {
      _rideStatus = 'Journey completed! You have arrived.';
    });

    // Reset ride state
    final rideState = Provider.of<RideState>(context, listen: false);
    rideState.reset();

    // Navigate to celebration screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LetsCelebrateScreen()),
    );

    // Reset local state
    setState(() {
      _rideInProgress = false;
      _riderApproaching = false;
      _hasDestination = false;
      _destinationText = 'Enter Destination';
      _rideStatus = '';
    });
  }
}

/// Custom painter that draws a grid to simulate a map background.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5D1C5)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw some "road" lines
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
