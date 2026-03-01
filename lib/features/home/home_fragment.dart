import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_karo/shared/app_theme.dart';
import 'package:ride_karo/shared/ride_state.dart';
import 'package:ride_karo/features/home/location_search_sheet.dart';
import 'package:ride_karo/features/home/bottom_sheet_fragment.dart';
import 'package:ride_karo/features/home/lets_celebrate_screen.dart';

/// Map-centric home fragment matching the original Connected_Living HomeFragment
/// and the f3.png design screenshot.
///
/// Shows a full-screen Google Map (real tiles with streets/roads/POIs),
/// a fixed green location pin overlay at the center, reverse geocoding on
/// camera idle, pill-shaped white location cards at the bottom, and a dark
/// "Ride" bar flush to the bottom edge.
class HomeFragment extends StatefulWidget {
  /// Creates the home fragment widget.
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  // Google Map controller
  GoogleMapController? _mapController;

  // Location state — default to Chennai area matching f3.png screenshot
  double _userLat = 13.0827;
  double _userLng = 80.2707;
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

  // Debounce timer for reverse geocoding on camera idle
  Timer? _geocodeDebounce;

  // Map markers and polylines
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  /// Default zoom level matching Kotlin DEFAULT_ZOOM = 15f.
  static const double _defaultZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _riderTimer?.cancel();
    _journeyTimer?.cancel();
    _geocodeDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  /// Gets the current user location and reverse geocodes it,
  /// matching the Kotlin getCurrentLocation() method.
  Future<void> _getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services disabled';
          _locationLoaded = true;
        });
        _initializeMarkers();
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
        });
        _initializeMarkers();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _userLat = position.latitude;
      _userLng = position.longitude;

      // Place rider nearby (matching Kotlin: longitude + 0.009)
      _riderLat = _userLat;
      _riderLng = _userLng + 0.009;

      // Reverse geocode current location
      await _reverseGeocode(_userLat, _userLng);

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_userLat, _userLng),
          _defaultZoom,
        ),
      );

      _initializeMarkers();
    } catch (e) {
      setState(() {
        _currentAddress = 'Unable to get location';
        _locationLoaded = true;
      });
      _initializeMarkers();
    }
  }

  /// Reverse geocodes the given lat/lng to an address string and updates state.
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.street, p.subLocality, p.locality]
            .where((s) => s != null && s.isNotEmpty);
        if (mounted) {
          setState(() {
            _currentAddress = parts.join(', ');
            _locationLoaded = true;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentAddress =
              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
          _locationLoaded = true;
        });
      }
    }
  }

  /// Sets up initial bike rider markers matching the Kotlin code that creates
  /// two bike markers near the user's location.
  void _initializeMarkers() {
    _markers.clear();

    // Rider marker 1 — matching Kotlin: (lat, lng + 0.009)
    _markers.add(
      Marker(
        markerId: const MarkerId('rider1'),
        position: LatLng(_riderLat, _riderLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Rider'),
      ),
    );

    // Rider marker 2 — matching Kotlin: (lat + 0.009, lng)
    _markers.add(
      Marker(
        markerId: const MarkerId('rider2'),
        position: LatLng(_userLat + 0.009, _userLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Rider'),
      ),
    );

    setState(() {});
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
            // Full-screen Google Map — fills entire viewport behind all overlays
            // as shown in f3.png. MapType.normal renders real streets/roads/POIs.
            _buildGoogleMap(),

            // Green center pin overlay — fixed at screen center with shadow.
            // Stays fixed while user drags the map underneath.
            // Matches the centered green_pin ImageView in the original layout.
            if (!_rideInProgress)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Icon(
                    Icons.location_on,
                    color: AppTheme.greenLight,
                    size: 44,
                    shadows: [
                      Shadow(
                        color: Color(0x28000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom panel: location cards + dark Ride bar
            // Anchored to bottom edge as shown in f3.png
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _rideInProgress
                  ? _buildRideStatusCard()
                  : _buildBottomPanel(rideState),
            ),
          ],
        );
      },
    );
  }

  /// Whether the Google Map failed to initialize (e.g. due to billing/API key issues).
  bool _mapLoadFailed = false;

  /// Builds the real Google Map widget matching the original Connected_Living
  /// MapView. Shows actual map tiles with roads, places, and POIs.
  /// If the map fails to load (e.g. BILLING_NOT_ENABLED), a placeholder is shown.
  Widget _buildGoogleMap() {
    if (_mapLoadFailed) {
      return _buildMapFallback();
    }

    // Wrap in a builder to catch platform view errors gracefully
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_userLat, _userLng),
        zoom: _defaultZoom,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        // Move to user location once map is ready
        if (_locationLoaded) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(_userLat, _userLng),
              _defaultZoom,
            ),
          );
        }
      },
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
      compassEnabled: true,
      mapType: MapType.normal,
      onCameraIdle: _onCameraIdle,
      onCameraMove: (_) {
        // Cancel any pending geocode while user is still dragging
        _geocodeDebounce?.cancel();
      },
    );
  }

  /// Fallback widget shown when Google Maps fails to load.
  /// Provides a usable UI placeholder so the app remains functional
  /// even when the Maps API key has billing issues.
  Widget _buildMapFallback() {
    return Container(
      color: const Color(0xFFE8E8E8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Map unavailable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'ProductSans',
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Google Maps could not load.\nPlease check API key and billing.',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'ProductSans',
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _mapLoadFailed = false;
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Called when the map camera stops moving. Reverse geocodes the center
  /// position matching the Kotlin onCameraIdle() callback that updates
  /// the current address text as the user drags the map.
  void _onCameraIdle() {
    if (_mapController == null || _hasDestination) return;

    // Debounce to avoid excessive geocoding calls
    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (_mapController == null) return;
      try {
        // Get the visible region to determine the center point
        final visibleRegion = await _mapController!.getVisibleRegion();
        final centerLat = (visibleRegion.northeast.latitude +
                visibleRegion.southwest.latitude) /
            2;
        final centerLng = (visibleRegion.northeast.longitude +
                visibleRegion.southwest.longitude) /
            2;

        // Update user position to map center
        _userLat = centerLat;
        _userLng = centerLng;

        await _reverseGeocode(centerLat, centerLng);
      } catch (_) {
        // Silently handle geocoding failures
      }
    });
  }

  /// Builds the bottom panel with location cards and ride bar,
  /// matching the currentLocationEdit and bottomLinearLayout in f3.png.
  /// White panel with shadow above, pill-shaped cards, dark Ride bar.
  Widget _buildBottomPanel(RideState rideState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // White panel container with top shadow
        Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current location card — pill-shaped with green circle
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      // Green circle — matches green_circle drawable
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppTheme.greenLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'ProductSans',
                            color: AppTheme.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Destination card — pill-shaped with red circle
              GestureDetector(
                onTap: _openLocationSearch,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        // Red circle — matches red_circle drawable
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: AppTheme.routeRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _destinationText,
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'ProductSans',
                              color: _hasDestination
                                  ? AppTheme.black
                                  : AppTheme.gray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Distance info + Book button when destination is set
              if (_hasDestination && rideState.distance > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: GestureDetector(
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
                          fontFamily: 'ProductSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Dark bottom bar with bike icon and "Ride" text
        // Matches bottomLinearLayout with BgDarkGray background in f3.png
        GestureDetector(
          onTap: _hasDestination ? _showRideBottomSheet : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: AppTheme.bgDarkGray,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.two_wheeler,
                  color: AppTheme.white,
                  size: 28,
                ),
                SizedBox(height: 2),
                Text(
                  'Ride',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'ProductSans',
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a status card during active ride.
  Widget _buildRideStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.two_wheeler,
                color: AppTheme.accentOrange,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _rideStatus,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'ProductSans',
                  ),
                ),
              ),
            ],
          ),
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
  /// Adds destination marker and draws a red polyline route on the map,
  /// matching the Kotlin getArea() method behavior.
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
          _userLat,
          _userLng,
          _destLat,
          _destLng,
        );
        final distanceKm = distanceMeters / 1000.0;
        final roundedDistance =
            double.parse(distanceKm.toStringAsFixed(1));
        rideState.setDistance(roundedDistance);

        // Add destination marker on map
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(_destLat, _destLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: address,
              snippet:
                  'Distance= ${roundedDistance.toStringAsFixed(1)} KM',
            ),
          ),
        );

        // Draw red polyline route
        _drawRoutePolyline();

        // Animate camera to show both points
        _fitMapToRoute();
      }
    } catch (e) {
      // Fallback: use a simulated distance
      rideState.setDistance(5.0);
      _destLat = _userLat + 0.04;
      _destLng = _userLng + 0.04;

      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(_destLat, _destLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: address,
            snippet: 'Distance= 5.0 KM',
          ),
        ),
      );

      _drawRoutePolyline();
      _fitMapToRoute();
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

  /// Draws a red polyline from user location to destination,
  /// matching the Kotlin ParserTask.onPostExecute that draws
  /// PolylineOptions with Color.RED and width 8f.
  void _drawRoutePolyline() {
    _polylines.clear();

    final List<LatLng> routePoints = _generateRoutePoints(
      LatLng(_userLat, _userLng),
      LatLng(_destLat, _destLng),
    );

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: AppTheme.routeRed,
        width: 5,
        geodesic: true,
      ),
    );

    setState(() {});
  }

  /// Generates intermediate route points between origin and destination
  /// to create a slightly curved polyline that looks more like a real route.
  List<LatLng> _generateRoutePoints(LatLng origin, LatLng dest) {
    final points = <LatLng>[];
    const numSteps = 20;

    final midLat = (origin.latitude + dest.latitude) / 2;
    final midLng = (origin.longitude + dest.longitude) / 2;
    final latDiff = (dest.latitude - origin.latitude).abs();
    final lngDiff = (dest.longitude - origin.longitude).abs();
    final offset = max(latDiff, lngDiff) * 0.1;

    for (int i = 0; i <= numSteps; i++) {
      final t = i / numSteps;
      final lat = (1 - t) * (1 - t) * origin.latitude +
          2 * (1 - t) * t * (midLat + offset) +
          t * t * dest.latitude;
      final lng = (1 - t) * (1 - t) * origin.longitude +
          2 * (1 - t) * t * (midLng - offset) +
          t * t * dest.longitude;
      points.add(LatLng(lat, lng));
    }

    return points;
  }

  /// Adjusts map camera to fit both user and destination locations.
  void _fitMapToRoute() {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(_userLat, _destLat),
        min(_userLng, _destLng),
      ),
      northeast: LatLng(
        max(_userLat, _destLat),
        max(_userLng, _destLng),
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
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
      _rideStatus = "Hold Tight! Rider is on it's way to your location";
    });

    int steps = 0;
    _riderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (steps >= 9) {
        timer.cancel();
        _onRiderArrived();
        return;
      }

      _riderLng -= 0.001;

      _markers.removeWhere((m) => m.markerId.value == 'rider1');
      _markers.add(
        Marker(
          markerId: const MarkerId('rider1'),
          position: LatLng(_riderLat, _riderLng),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Rider approaching'),
        ),
      );

      setState(() {});
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

      _journeyLat += latStep;
      _journeyLng += lngStep;

      _markers.removeWhere((m) => m.markerId.value == 'journey');
      _markers.add(
        Marker(
          markerId: const MarkerId('journey'),
          position: LatLng(_journeyLat, _journeyLng),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Your ride'),
        ),
      );

      setState(() {
        _rideStatus = 'Journey in progress to $_destinationText';
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(_journeyLat, _journeyLng)),
      );

      step++;
    });
  }

  /// Called when journey completes. Navigates to celebration screen.
  void _onJourneyComplete() {
    setState(() {
      _rideStatus = 'Journey completed! You have arrived.';
    });

    final rideState = Provider.of<RideState>(context, listen: false);
    rideState.reset();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LetsCelebrateScreen()),
    );

    setState(() {
      _rideInProgress = false;
      _riderApproaching = false;
      _hasDestination = false;
      _destinationText = 'Enter Destination';
      _rideStatus = '';
      _polylines.clear();
      _markers.removeWhere(
        (m) =>
            m.markerId.value == 'destination' ||
            m.markerId.value == 'journey',
      );
    });
  }
}
