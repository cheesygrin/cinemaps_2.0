import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/cinemaps_theme.dart';
import '../models/tour.dart';

class TourNavigationPage extends StatefulWidget {
  final CustomTour tour;
  final String userId;

  const TourNavigationPage({
    super.key,
    required this.tour,
    required this.userId,
  });

  @override
  State<TourNavigationPage> createState() => _TourNavigationPageState();
}

class _TourNavigationPageState extends State<TourNavigationPage> {
  GoogleMapController? _mapController;
  int _currentStopIndex = 0;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Timer? _locationUpdateTimer;
  bool _isNavigating = false;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMap() async {
    // Create markers for each stop
    _markers = widget.tour.stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return Marker(
        markerId: MarkerId(stop.id),
        position: stop.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          index == _currentStopIndex
              ? BitmapDescriptor.hueRose
              : BitmapDescriptor.hueViolet,
        ),
        infoWindow: InfoWindow(
          title: '${index + 1}. ${stop.name}',
          snippet: stop.movieTitle,
        ),
      );
    }).toSet();

    // Create polyline for the route
    if (widget.tour.stops.length > 1) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(widget.tour.id),
          points: widget.tour.stops.map((stop) => stop.location).toList(),
          color: CinemapsTheme.hotPink,
          width: 3,
        ),
      );
    }
  }

  void _startLocationUpdates() {
    // Simulated location updates for demo
    // In a real app, use location services
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) {
        if (!_isNavigating) return;

        final targetStop = widget.tour.stops[_currentStopIndex];
        final targetLat = targetStop.location.latitude;
        final targetLng = targetStop.location.longitude;

        if (_currentLocation == null) {
          // Start from previous stop or first stop
          final startStop = _currentStopIndex > 0
              ? widget.tour.stops[_currentStopIndex - 1]
              : widget.tour.stops.first;
          _currentLocation = startStop.location;
        }

        // Simulate movement towards target
        final currentLat = _currentLocation!.latitude;
        final currentLng = _currentLocation!.longitude;
        const step = 0.0001; // Small step for smooth movement

        final newLat = _moveTowards(currentLat, targetLat, step);
        final newLng = _moveTowards(currentLng, targetLng, step);
        final newLocation = LatLng(newLat, newLng);

        setState(() {
          _currentLocation = newLocation;
          _updateCurrentLocationMarker();
        });

        // Check if reached destination
        if (_isAtDestination(newLocation, targetStop.location)) {
          _showArrivalDialog();
        }
      },
    );
  }

  double _moveTowards(double current, double target, double step) {
    if (current < target) {
      return current + step > target ? target : current + step;
    } else {
      return current - step < target ? target : current - step;
    }
  }

  bool _isAtDestination(LatLng current, LatLng target) {
    const threshold = 0.0001; // About 10 meters
    return (current.latitude - target.latitude).abs() < threshold &&
        (current.longitude - target.longitude).abs() < threshold;
  }

  void _updateCurrentLocationMarker() {
    if (_currentLocation == null) return;

    final currentLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: _currentLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'You are here'),
    );

    setState(() {
      _markers = {..._markers}..removeWhere(
          (marker) => marker.markerId.value == 'current_location',
        );
      _markers.add(currentLocationMarker);
    });

    // Update camera position
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_currentLocation!),
    );
  }

  Future<void> _showArrivalDialog() async {
    setState(() => _isNavigating = false);

    if (!mounted) return;

    final stop = widget.tour.stops[_currentStopIndex];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: Text(
          'Arrived at ${stop.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stop.description,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            if (stop.scenes.isNotEmpty) ...[
              const Text(
                'Featured Scenes:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...stop.scenes.map((scene) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.movie,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scene,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentStopIndex < widget.tour.stops.length - 1) {
                setState(() {
                  _currentStopIndex++;
                  _initializeMap();
                  _isNavigating = true;
                });
              } else {
                _showTourCompletionDialog();
              }
            },
            child: Text(
              _currentStopIndex < widget.tour.stops.length - 1
                  ? 'NEXT STOP'
                  : 'FINISH TOUR',
              style: const TextStyle(color: CinemapsTheme.hotPink),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTourCompletionDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text(
          '🎉 Tour Completed!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You\'ve completed the "${widget.tour.name}" tour.',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.timer,
                  value: '${widget.tour.totalDuration}',
                  label: 'minutes',
                ),
                _buildStatCard(
                  icon: Icons.directions_walk,
                  value: widget.tour.totalDistance.toStringAsFixed(1),
                  label: 'km',
                ),
                _buildStatCard(
                  icon: Icons.location_on,
                  value: widget.tour.stops.length.toString(),
                  label: 'stops',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'FINISH',
              style: TextStyle(color: CinemapsTheme.hotPink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: CinemapsTheme.hotPink),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStop = widget.tour.stops[_currentStopIndex];

    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentStop.location,
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Card(
              color: CinemapsTheme.deepSpaceBlack.withOpacity(0.9),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CinemapsTheme.hotPink.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stop ${_currentStopIndex + 1} of ${widget.tour.stops.length}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentStop.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currentStop.movieTitle,
                                style: const TextStyle(
                                  color: CinemapsTheme.neonYellow,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => _isNavigating = !_isNavigating);
        },
        backgroundColor: _isNavigating ? Colors.red : CinemapsTheme.hotPink,
        icon: Icon(_isNavigating ? Icons.pause : Icons.navigation),
        label: Text(_isNavigating ? 'PAUSE' : 'START'),
      ),
    );
  }
}
