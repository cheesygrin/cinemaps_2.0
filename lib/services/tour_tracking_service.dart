import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/tour_tracking.dart';
import 'gamification_service.dart';

class TourTrackingService extends ChangeNotifier {
  final Map<String, ActiveTour> _activeTours = {};
  final Map<String, StreamSubscription<Position>> _locationStreams = {};
  final GamificationService _gamificationService;

  // Constants for tracking
  static const double stopRadius = 50.0; // meters
  static const Duration updateInterval = Duration(seconds: 10);
  static const Duration nearbyAlertDistance =
      Duration(minutes: 5); // walking time

  TourTrackingService({
    required GamificationService gamificationService,
  }) : _gamificationService = gamificationService;

  Future<ActiveTour> startTour({
    required String tourId,
    required String userId,
    required List<TourStop> stops,
  }) async {
    // Create new active tour
    final activeTour = ActiveTour(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tourId: tourId,
      userId: userId,
      startTime: DateTime.now(),
      stops: stops,
      status: TourStatus.inProgress,
      currentStopIndex: 0,
      totalDuration: stops.fold(
        Duration.zero,
        (total, stop) => total + stop.estimatedDuration,
      ),
      elapsedTime: Duration.zero,
      statistics: {
        'distanceCovered': 0.0,
        'averageSpeed': 0.0,
        'pauseCount': 0,
        'photosTaken': 0,
      },
    );

    _activeTours[tourId] = activeTour;

    // Start location tracking
    await _startLocationTracking(tourId, userId);

    notifyListeners();
    return activeTour;
  }

  Future<void> _startLocationTracking(String tourId, String userId) async {
    // Request location permission if not granted
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // Start location stream
    final stream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    );

    _locationStreams[tourId] = stream.listen((position) {
      _handleLocationUpdate(
        tourId,
        userId,
        LatLng(position.latitude, position.longitude),
      );
    });
  }

  Future<void> _handleLocationUpdate(
    String tourId,
    String userId,
    LatLng currentLocation,
  ) async {
    final tour = _activeTours[tourId];
    if (tour == null || tour.status != TourStatus.inProgress) return;

    // Check if user has reached current stop
    final currentStop = tour.currentStop;
    if (currentStop != null && !currentStop.isVisited) {
      final distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        currentStop.coordinates.latitude,
        currentStop.coordinates.longitude,
      );

      if (distance <= stopRadius) {
        await _markStopAsVisited(tourId, currentStop.id);
      }
    }

    // Update tour statistics
    final updatedStats = Map<String, dynamic>.from(tour.statistics);
    updatedStats['distanceCovered'] += 10; // Simplified distance calculation

    // Create updated tour object
    final updatedTour = ActiveTour(
      id: tour.id,
      tourId: tour.tourId,
      userId: tour.userId,
      startTime: tour.startTime,
      endTime: tour.endTime,
      stops: tour.stops,
      status: tour.status,
      currentStopIndex: tour.currentStopIndex,
      totalDuration: tour.totalDuration,
      elapsedTime: DateTime.now().difference(tour.startTime),
      statistics: updatedStats,
    );

    _activeTours[tourId] = updatedTour;
    notifyListeners();

    // Check for nearby stops and send notifications
    _checkNearbyStops(tourId, currentLocation);
  }

  Future<void> _markStopAsVisited(String tourId, String stopId) async {
    final tour = _activeTours[tourId];
    if (tour == null) return;

    // Update stop with visit time
    final updatedStops = tour.stops.map((stop) {
      if (stop.id == stopId) {
        return TourStop(
          id: stop.id,
          locationId: stop.locationId,
          name: stop.name,
          coordinates: stop.coordinates,
          description: stop.description,
          scenes: stop.scenes,
          estimatedDuration: stop.estimatedDuration,
          isOptional: stop.isOptional,
          visitedAt: DateTime.now(),
        );
      }
      return stop;
    }).toList();

    // Move to next stop if available
    int nextStopIndex = tour.currentStopIndex;
    if (nextStopIndex < updatedStops.length - 1) {
      nextStopIndex++;
    }

    // Check if tour is completed
    final allVisited =
        updatedStops.every((stop) => stop.isVisited || stop.isOptional);

    // Create updated tour
    final updatedTour = ActiveTour(
      id: tour.id,
      tourId: tour.tourId,
      userId: tour.userId,
      startTime: tour.startTime,
      endTime: allVisited ? DateTime.now() : null,
      stops: updatedStops,
      status: allVisited ? TourStatus.completed : tour.status,
      currentStopIndex: nextStopIndex,
      totalDuration: tour.totalDuration,
      elapsedTime: DateTime.now().difference(tour.startTime),
      statistics: tour.statistics,
    );

    _activeTours[tourId] = updatedTour;

    // Award points and achievements
    await _awardStopCompletion(tour.userId, stopId);

    if (allVisited) {
      await _completeTour(tourId);
    }

    notifyListeners();
  }

  Future<void> _awardStopCompletion(String userId, String stopId) async {
    // Award base points for visiting stop
    await _gamificationService.awardPoints(userId, 50);

    // TODO: Add more complex point calculation based on:
    // - Stop difficulty
    // - Time taken
    // - Photos taken
    // - Social sharing
  }

  Future<void> _completeTour(String tourId) async {
    final tour = _activeTours[tourId];
    if (tour == null) return;

    // Calculate tour statistics
    final progress = TourProgress(
      tourId: tourId,
      userId: tour.userId,
      totalStops: tour.stops.length,
      completedStops: tour.stops.where((stop) => stop.isVisited).length,
      totalTime: tour.totalDuration,
      elapsedTime: tour.elapsedTime,
      distanceCovered: tour.statistics['distanceCovered'] as double,
      unlockedAchievements: [], // TODO: Calculate achievements
      pointsEarned: 500, // Base points for tour completion
    );

    // Award completion points and achievements
    await _gamificationService.awardPoints(tour.userId, progress.pointsEarned);

    // Clean up location tracking
    await _locationStreams[tourId]?.cancel();
    _locationStreams.remove(tourId);

    notifyListeners();
  }

  Future<void> pauseTour(String tourId) async {
    final tour = _activeTours[tourId];
    if (tour == null) return;

    // Update statistics
    final updatedStats = Map<String, dynamic>.from(tour.statistics);
    updatedStats['pauseCount'] = (updatedStats['pauseCount'] as int) + 1;

    // Create paused tour
    final pausedTour = ActiveTour(
      id: tour.id,
      tourId: tour.tourId,
      userId: tour.userId,
      startTime: tour.startTime,
      endTime: null,
      stops: tour.stops,
      status: TourStatus.paused,
      currentStopIndex: tour.currentStopIndex,
      totalDuration: tour.totalDuration,
      elapsedTime: DateTime.now().difference(tour.startTime),
      statistics: updatedStats,
    );

    _activeTours[tourId] = pausedTour;

    // Pause location tracking
    await _locationStreams[tourId]?.cancel();
    _locationStreams.remove(tourId);

    notifyListeners();
  }

  Future<void> resumeTour(String tourId) async {
    final tour = _activeTours[tourId];
    if (tour == null) return;

    // Create resumed tour
    final resumedTour = ActiveTour(
      id: tour.id,
      tourId: tour.tourId,
      userId: tour.userId,
      startTime: tour.startTime,
      endTime: null,
      stops: tour.stops,
      status: TourStatus.inProgress,
      currentStopIndex: tour.currentStopIndex,
      totalDuration: tour.totalDuration,
      elapsedTime: tour.elapsedTime,
      statistics: tour.statistics,
    );

    _activeTours[tourId] = resumedTour;

    // Resume location tracking
    await _startLocationTracking(tourId, tour.userId);

    notifyListeners();
  }

  Future<void> cancelTour(String tourId) async {
    final tour = _activeTours[tourId];
    if (tour == null) return;

    // Create cancelled tour
    final cancelledTour = ActiveTour(
      id: tour.id,
      tourId: tour.tourId,
      userId: tour.userId,
      startTime: tour.startTime,
      endTime: DateTime.now(),
      stops: tour.stops,
      status: TourStatus.cancelled,
      currentStopIndex: tour.currentStopIndex,
      totalDuration: tour.totalDuration,
      elapsedTime: DateTime.now().difference(tour.startTime),
      statistics: tour.statistics,
    );

    _activeTours[tourId] = cancelledTour;

    // Clean up location tracking
    await _locationStreams[tourId]?.cancel();
    _locationStreams.remove(tourId);

    notifyListeners();
  }

  void _checkNearbyStops(String tourId, LatLng currentLocation) async {
    final tour = _activeTours[tourId];
    if (tour == null) return;

    // Check remaining stops for proximity
    for (final stop in tour.remainingStops) {
      if (stop.isVisited) continue;

      final distance = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        stop.coordinates.latitude,
        stop.coordinates.longitude,
      );

      // Calculate walking time (assuming 5km/h walking speed)
      final walkingTimeMinutes = (distance / 83.33); // 83.33 meters per minute

      if (walkingTimeMinutes <= nearbyAlertDistance.inMinutes) {
        // TODO: Show notification that stop is nearby
        print(
            'Stop ${stop.name} is ${walkingTimeMinutes.round()} minutes away');
      }
    }
  }

  ActiveTour? getActiveTour(String tourId) => _activeTours[tourId];

  List<ActiveTour> getUserActiveTours(String userId) {
    return _activeTours.values
        .where((tour) =>
            tour.userId == userId && tour.status == TourStatus.inProgress)
        .toList();
  }

  @override
  void dispose() {
    // Clean up all location streams
    for (final stream in _locationStreams.values) {
      stream.cancel();
    }
    _locationStreams.clear();
    super.dispose();
  }
}
