import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MovieTour {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<TourStop> stops;
  final int estimatedDuration; // in minutes
  final int difficulty; // 1-5
  final String theme;
  final int points;
  bool isCompleted;
  DateTime? completedAt;

  MovieTour({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.stops,
    required this.estimatedDuration,
    required this.difficulty,
    required this.theme,
    required this.points,
    this.isCompleted = false,
    this.completedAt,
  });
}

class TourStop {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final String imageUrl;
  final String movieTitle;
  final String sceneDescription;
  final String trivia;
  bool isVisited;
  DateTime? visitedAt;

  TourStop({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.movieTitle,
    required this.sceneDescription,
    required this.trivia,
    this.isVisited = false,
    this.visitedAt,
  });
}

class TourService extends ChangeNotifier {
  final List<MovieTour> _tours = [
    MovieTour(
      id: 'friends_nyc',
      name: 'Friends NYC Tour',
      description: 'Visit the iconic locations from Friends in New York City',
      imageUrl: 'assets/tours/friends_nyc.jpg',
      stops: [
        TourStop(
          id: 'central_perk',
          name: 'Central Perk',
          description: 'The iconic coffee shop where the gang hung out',
          location: const LatLng(40.7326, -74.0063),
          imageUrl: 'assets/locations/central_perk.jpg',
          movieTitle: 'Friends',
          sceneDescription: 'The main hangout spot throughout the series',
          trivia: 'The exterior shot is actually of a building in Greenwich Village',
        ),
        TourStop(
          id: 'friends_apartment',
          name: 'Monica\'s Apartment',
          description: 'The famous apartment where Monica and Rachel lived',
          location: const LatLng(40.7339, -73.9937),
          imageUrl: 'assets/locations/friends_apartment.jpg',
          movieTitle: 'Friends',
          sceneDescription: 'The main setting for many of the show\'s scenes',
          trivia: 'The building is located at 90 Bedford Street',
        ),
      ],
      estimatedDuration: 180,
      difficulty: 2,
      theme: '90s Sitcom',
      points: 100,
    ),
    MovieTour(
      id: 'marvel_nyc',
      name: 'Marvel NYC Tour',
      description: 'Explore the real locations from Marvel movies in NYC',
      imageUrl: 'assets/tours/marvel_nyc.jpg',
      stops: [
        TourStop(
          id: 'sanctum_sanctorum',
          name: 'Sanctum Sanctorum',
          description: 'Doctor Strange\'s New York Sanctuary',
          location: const LatLng(40.7294, -74.0031),
          imageUrl: 'assets/locations/sanctum.jpg',
          movieTitle: 'Doctor Strange',
          sceneDescription: 'Home and headquarters of Doctor Strange',
          trivia: 'Located at 177A Bleecker Street in Greenwich Village',
        ),
        TourStop(
          id: 'stark_tower',
          name: 'Stark Tower',
          description: 'The home of the Avengers',
          location: const LatLng(40.7527, -73.9772),
          imageUrl: 'assets/locations/stark_tower.jpg',
          movieTitle: 'The Avengers',
          sceneDescription: 'The battle of New York centered around this building',
          trivia: 'Based on the MetLife Building in real life',
        ),
      ],
      estimatedDuration: 240,
      difficulty: 3,
      theme: 'Superhero',
      points: 150,
    ),
  ];

  final Set<String> _completedTourStops = {};
  int _tourPoints = 0;

  List<MovieTour> get allTours => _tours;
  List<MovieTour> get completedTours => 
      _tours.where((tour) => tour.isCompleted).toList();
  int get totalPoints => _tourPoints;

  void markStopAsVisited(String tourId, String stopId) {
    final tour = _findTourById(tourId);
    if (tour == null) return;

    final stop = _findStopById(tour, stopId);
    if (stop == null) return;

    if (!_completedTourStops.contains(stopId)) {
      stop.isVisited = true;
      stop.visitedAt = DateTime.now();
      _completedTourStops.add(stopId);
      
      // Check if all stops in the tour are completed
      final allStopsCompleted = tour.stops.every((s) => s.isVisited);
      if (allStopsCompleted && !tour.isCompleted) {
        tour.isCompleted = true;
        tour.completedAt = DateTime.now();
        _tourPoints += tour.points;
      }
      
      notifyListeners();
    }
  }

  MovieTour? _findTourById(String tourId) {
    try {
      return _tours.firstWhere((tour) => tour.id == tourId);
    } catch (e) {
      return null;
    }
  }

  TourStop? _findStopById(MovieTour tour, String stopId) {
    try {
      return tour.stops.firstWhere((stop) => stop.id == stopId);
    } catch (e) {
      return null;
    }
  }

  double getTourProgress(String tourId) {
    final tour = _findTourById(tourId);
    if (tour == null) return 0.0;

    final completedStops = tour.stops.where((stop) => stop.isVisited).length;
    return completedStops / tour.stops.length;
  }

  List<TourStop> getUnvisitedStops(String tourId) {
    final tour = _findTourById(tourId);
    if (tour == null) return [];

    return tour.stops.where((stop) => !stop.isVisited).toList();
  }

  List<MovieTour> getToursByTheme(String theme) {
    return _tours.where((tour) => tour.theme == theme).toList();
  }

  List<MovieTour> getRecommendedTours() {
    // Simple recommendation based on completion status and difficulty
    return _tours
        .where((tour) => !tour.isCompleted)
        .toList()
      ..sort((a, b) => a.difficulty.compareTo(b.difficulty));
  }
}
