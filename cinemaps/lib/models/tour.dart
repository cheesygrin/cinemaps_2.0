import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomTour {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final List<TourStop> stops;
  final bool isPublic;
  final String? imageUrl;
  final double rating;
  final List<String> categories;
  final DateTime timestamp;
  final int estimatedDuration; // in minutes
  final String name;
  final int ratingCount;
  final int totalDuration;

  CustomTour({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.stops,
    this.isPublic = false,
    this.imageUrl,
    this.rating = 0.0,
    this.categories = const [],
    required this.timestamp,
    required this.estimatedDuration,
    String? name,
    this.ratingCount = 0,
    int? totalDuration,
  }) : name = name ?? title,
       totalDuration = totalDuration ?? estimatedDuration;

  double get totalDistance {
    if (stops.length < 2) return 0.0;

    double distance = 0.0;
    for (int i = 0; i < stops.length - 1; i++) {
      distance += _calculateDistance(
        stops[i].location,
        stops[i + 1].location,
      );
    }
    return distance;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters

    final startLat = start.latitude * pi / 180;
    final endLat = end.latitude * pi / 180;
    final latDiff = (end.latitude - start.latitude) * pi / 180;
    final lngDiff = (end.longitude - start.longitude) * pi / 180;

    final a = sin(latDiff / 2) * sin(latDiff / 2) +
        cos(startLat) * cos(endLat) * sin(lngDiff / 2) * sin(lngDiff / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }
}

class TourStop {
  final String id;
  final String name;
  final LatLng location;
  final String description;
  final int estimatedDuration; // in minutes
  final List<String>? photos;
  final String category;
  final double rating;
  final bool isVisited;
  final String movieTitle;
  final List<String> scenes;

  TourStop({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.estimatedDuration,
    this.photos,
    required this.category,
    required this.rating,
    this.isVisited = false,
    required this.movieTitle,
    this.scenes = const [],
  });
}
