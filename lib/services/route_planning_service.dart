import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/filming_location.dart';
import 'dart:math' show pi, sin, cos, sqrt, atan2;

class RouteSegment {
  final FilmingLocation start;
  final FilmingLocation end;
  final int durationMinutes;
  final double distanceKm;
  final List<LatLng> polylinePoints;

  RouteSegment({
    required this.start,
    required this.end,
    required this.durationMinutes,
    required this.distanceKm,
    required this.polylinePoints,
  });
}

class OptimizedRoute {
  final List<FilmingLocation> orderedLocations;
  final List<RouteSegment> segments;
  final int totalDurationMinutes;
  final double totalDistanceKm;

  OptimizedRoute({
    required this.orderedLocations,
    required this.segments,
    required this.totalDurationMinutes,
    required this.totalDistanceKm,
  });
}

class RoutePlanningService {
  Future<OptimizedRoute> planRoute(
      List<FilmingLocation> locations, LatLng startPoint) async {
    // Sort locations by nearest neighbor algorithm
    // In a real app, this would use Google Maps Directions API
    List<FilmingLocation> ordered = [];
    List<FilmingLocation> remaining = List.from(locations);
    LatLng currentPoint = startPoint;

    while (remaining.isNotEmpty) {
      FilmingLocation? nearest;
      double nearestDist = double.infinity;

      for (final location in remaining) {
        final dist = _calculateDistance(
          currentPoint,
          LatLng(location.latitude, location.longitude),
        );
        if (dist < nearestDist) {
          nearestDist = dist;
          nearest = location;
        }
      }

      if (nearest == null) break;

      ordered.add(nearest);
      remaining.remove(nearest);
      currentPoint = LatLng(nearest.latitude, nearest.longitude);
    }

    // Create route segments
    List<RouteSegment> segments = [];
    double totalDistance = 0;
    int totalDuration = 0;

    for (int i = 0; i < ordered.length - 1; i++) {
      final start = ordered[i];
      final end = ordered[i + 1];
      final distance = _calculateDistance(
        LatLng(start.latitude, start.longitude),
        LatLng(end.latitude, end.longitude),
      );
      final duration =
          (distance * 3).round(); // Rough estimate: 3 minutes per km

      final segment = RouteSegment(
        start: start,
        end: end,
        durationMinutes: duration,
        distanceKm: distance,
        polylinePoints: _generatePolyline(
          LatLng(start.latitude, start.longitude),
          LatLng(end.latitude, end.longitude),
        ),
      );

      segments.add(segment);
      totalDistance += distance;
      totalDuration += duration;
    }

    return OptimizedRoute(
      orderedLocations: ordered,
      segments: segments,
      totalDurationMinutes: totalDuration,
      totalDistanceKm: totalDistance,
    );
  }

  double _calculateDistance(LatLng start, LatLng end) {
    // Simple Euclidean distance - in a real app, use Google Maps Distance Matrix API
    const double earthRadius = 6371; // km
    final lat1 = start.latitude * (pi / 180);
    final lat2 = end.latitude * (pi / 180);
    final dLat = (end.latitude - start.latitude) * (pi / 180);
    final dLon = (end.longitude - start.longitude) * (pi / 180);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  List<LatLng> _generatePolyline(LatLng start, LatLng end) {
    // In a real app, use Google Maps Directions API for actual route
    return [start, end];
  }
}
