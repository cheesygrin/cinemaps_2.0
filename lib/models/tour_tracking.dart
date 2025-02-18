import 'package:google_maps_flutter/google_maps_flutter.dart';

enum TourStatus { notStarted, inProgress, paused, completed, cancelled }

class TourStop {
  final String id;
  final String locationId;
  final String name;
  final LatLng coordinates;
  final String description;
  final List<String> scenes;
  final Duration estimatedDuration;
  final bool isOptional;
  final DateTime? visitedAt;

  const TourStop({
    required this.id,
    required this.locationId,
    required this.name,
    required this.coordinates,
    required this.description,
    required this.scenes,
    required this.estimatedDuration,
    this.isOptional = false,
    this.visitedAt,
  });

  bool get isVisited => visitedAt != null;
}

class ActiveTour {
  final String id;
  final String tourId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<TourStop> stops;
  final TourStatus status;
  final int currentStopIndex;
  final Duration totalDuration;
  final Duration elapsedTime;
  final Map<String, dynamic> statistics;

  const ActiveTour({
    required this.id,
    required this.tourId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.stops,
    required this.status,
    required this.currentStopIndex,
    required this.totalDuration,
    required this.elapsedTime,
    required this.statistics,
  });

  double get completionPercentage {
    if (stops.isEmpty) return 0;
    final visitedStops = stops.where((stop) => stop.isVisited).length;
    return (visitedStops / stops.length) * 100;
  }

  Duration get remainingTime {
    if (status == TourStatus.completed) return Duration.zero;
    return totalDuration - elapsedTime;
  }

  TourStop? get currentStop {
    if (currentStopIndex >= 0 && currentStopIndex < stops.length) {
      return stops[currentStopIndex];
    }
    return null;
  }

  TourStop? get nextStop {
    final nextIndex = currentStopIndex + 1;
    if (nextIndex < stops.length) {
      return stops[nextIndex];
    }
    return null;
  }

  List<TourStop> get remainingStops {
    if (currentStopIndex >= stops.length - 1) return [];
    return stops.sublist(currentStopIndex + 1);
  }

  Duration get estimatedRemainingDuration {
    return remainingStops.fold(
      Duration.zero,
      (total, stop) => total + stop.estimatedDuration,
    );
  }
}

class TourProgress {
  final String tourId;
  final String userId;
  final int totalStops;
  final int completedStops;
  final Duration totalTime;
  final Duration elapsedTime;
  final double distanceCovered;
  final List<String> unlockedAchievements;
  final int pointsEarned;

  const TourProgress({
    required this.tourId,
    required this.userId,
    required this.totalStops,
    required this.completedStops,
    required this.totalTime,
    required this.elapsedTime,
    required this.distanceCovered,
    required this.unlockedAchievements,
    required this.pointsEarned,
  });

  double get completionPercentage => (completedStops / totalStops) * 100;

  Duration get remainingTime => totalTime - elapsedTime;

  bool get isCompleted => completedStops == totalStops;
}
