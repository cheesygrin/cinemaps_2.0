import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/tour.dart';
import 'package:flutter/foundation.dart';

class TourManagementService extends ChangeNotifier {
  static final TourManagementService _instance =
      TourManagementService._internal();
  factory TourManagementService() {
    if (!_instance._isInitialized) {
      _instance._initializeTours();
    }
    return _instance;
  }
  TourManagementService._internal();

  final List<CustomTour> _tours = [
    // New York Movie Magic Tour
    CustomTour(
      id: 'ny_ghostbusters',
      title: 'Ghostbusters NYC Tour',
      description:
          'Experience the supernatural side of New York City! Visit the iconic locations from the original Ghostbusters movie, including the famous firehouse and the haunted library.',
      creatorId: 'system',
      stops: [
        TourStop(
          id: 'ghostbusters_firehouse',
          name: 'Hook & Ladder 8 Firehouse',
          description:
              'The iconic Ghostbusters headquarters! This active FDNY station served as the exterior of the Ghostbusters\'s base of operations.',
          location: const LatLng(40.7197, -74.0066),
          estimatedDuration: 30,
          photos: ['assets/images/ghostbusters.jpg'],
          category: 'Comedy',
          rating: 4.8,
          movieTitle: 'Ghostbusters',
        ),
        TourStop(
          id: 'ghostbusters_library',
          name: 'New York Public Library',
          description:
              'The opening scene with the ghost librarian was filmed here. The historic Rose Main Reading Room is a must-see!',
          location: const LatLng(40.7589, -73.9851),
          estimatedDuration: 45,
          photos: ['assets/images/ghostbusters.jpg'],
          category: 'Comedy',
          rating: 4.6,
          movieTitle: 'Ghostbusters',
        ),
      ],
      isPublic: true,
      imageUrl: 'assets/images/ghostbusters.jpg',
      categories: ['Comedy', 'Action', 'Supernatural'],
      timestamp: DateTime.now(),
      estimatedDuration: 75,
    ),

    // Chicago Dark Knight Tour
    CustomTour(
      id: 'chicago_dark_knight',
      title: 'The Dark Knight\'s Chicago',
      description:
          'Follow in Batman\'s footsteps through the streets of Chicago that doubled as Gotham City in The Dark Knight. Visit iconic locations from the epic chase scenes and dramatic confrontations.',
      creatorId: 'system',
      stops: [
        TourStop(
          id: 'dark_knight_trade',
          name: 'Chicago Board of Trade',
          description:
              'Used as the exterior of Wayne Enterprises, this building played a crucial role in several scenes.',
          location: const LatLng(41.8789, -87.6359),
          estimatedDuration: 45,
          photos: ['assets/images/dark_knight.jpg'],
          category: 'Action',
          rating: 4.7,
          movieTitle: 'The Dark Knight',
        ),
        TourStop(
          id: 'dark_knight_lasalle',
          name: 'LaSalle Street',
          description:
              'The famous truck flip scene was filmed here during the intense chase sequence with the Joker.',
          location: const LatLng(41.8870, -87.6355),
          estimatedDuration: 30,
          photos: ['assets/images/dark_knight.jpg'],
          category: 'Action',
          rating: 4.8,
          movieTitle: 'The Dark Knight',
        ),
      ],
      isPublic: true,
      imageUrl: 'assets/images/dark_knight.jpg',
      categories: ['Action', 'Drama', 'Superhero'],
      timestamp: DateTime.now(),
      estimatedDuration: 75,
    ),

    // LA La Land Experience Tour
    CustomTour(
      id: '2',
      title: 'LA La Land Experience',
      description:
          'Follow in the footsteps of Sebastian and Mia from La La Land, plus visit other romantic movie locations across Los Angeles.',
      creatorId: 'system',
      stops: [
        TourStop(
          id: '4',
          name: 'Griffith Observatory',
          description:
              'The iconic dance scene from La La Land was filmed here. Enjoy spectacular views of LA and recreate the magical moment!',
          location: const LatLng(34.1184, -118.3004),
          estimatedDuration: 90,
          photos: ['https://example.com/griffith.jpg'],
          category: 'Romance/Musical',
          rating: 4.9,
          movieTitle: 'La La Land',
        ),
        TourStop(
          id: '5',
          name: 'Hermosa Beach Pier',
          description:
              'Sebastian and Mia\'s romantic walk scene was filmed here. Perfect for sunset strolls!',
          location: const LatLng(33.8622, -118.4001),
          estimatedDuration: 45,
          photos: ['https://example.com/hermosa_pier.jpg'],
          category: 'Romance',
          rating: 4.7,
          movieTitle: 'La La Land',
        ),
        TourStop(
          id: '6',
          name: 'Chateau Marmont',
          description:
              'This legendary hotel has been featured in countless Hollywood films and is where Mia had her life-changing audition.',
          location: const LatLng(34.0976, -118.3657),
          estimatedDuration: 60,
          photos: ['https://example.com/chateau_marmont.jpg'],
          category: 'Romance/Drama',
          rating: 4.8,
          movieTitle: 'La La Land',
        ),
      ],
      isPublic: true,
      imageUrl: 'https://example.com/la_la_land_tour.jpg',
      categories: ['Romance', 'Musical', 'Drama'],
      timestamp: DateTime(2025, 2, 1),
      estimatedDuration: 195,
    ),
  ];

  String _searchQuery = '';
  bool _isInitialized = false;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void _initializeTours() {
    if (_isInitialized) return;

    _tours.addAll([
      CustomTour(
        id: 'ghostbusters_nyc',
        title: 'Ghostbusters NYC Tour',
        description: 'Visit iconic locations from the original Ghostbusters movie in New York City.',
        creatorId: 'system',
        stops: [
          TourStop(
            id: 'ghostbusters_firehouse',
            name: 'Hook & Ladder 8 Firehouse',
            description:
                'The iconic Ghostbusters headquarters! This active FDNY station served as the exterior of the Ghostbusters\'s base of operations.',
            location: const LatLng(40.7197, -74.0066),
            estimatedDuration: 30,
            photos: ['https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Hook_and_Ladder_8_Ghostbusters.jpg/1280px-Hook_and_Ladder_8_Ghostbusters.jpg'],
            category: 'Comedy',
            rating: 4.8,
            movieTitle: 'Ghostbusters',
          ),
          TourStop(
            id: 'ghostbusters_library',
            name: 'New York Public Library',
            description:
                'The opening scene with the ghost librarian was filmed here. The historic Rose Main Reading Room is a must-see!',
            location: const LatLng(40.7589, -73.9851),
            estimatedDuration: 45,
            photos: ['https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Hook_and_Ladder_8_Ghostbusters.jpg/1280px-Hook_and_Ladder_8_Ghostbusters.jpg'],
            category: 'Comedy',
            rating: 4.6,
            movieTitle: 'Ghostbusters',
          ),
        ],
        isPublic: true,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Hook_and_Ladder_8_Ghostbusters.jpg/1280px-Hook_and_Ladder_8_Ghostbusters.jpg',
        categories: ['Comedy', 'Action', 'Supernatural'],
        timestamp: DateTime.now(),
        estimatedDuration: 75,
      ),
      CustomTour(
        id: 'dark_knight_chicago',
        title: 'Dark Knight Chicago Tour',
        description: 'Explore the streets of Chicago that became Gotham City in The Dark Knight.',
        creatorId: 'system',
        stops: [
          TourStop(
            id: 'dark_knight_trade',
            name: 'Chicago Board of Trade',
            description:
                'Used as the exterior of Wayne Enterprises, this building played a crucial role in several scenes.',
            location: const LatLng(41.8789, -87.6359),
            estimatedDuration: 45,
            photos: ['https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Chicago_Theatre.jpg/1280px-Chicago_Theatre.jpg'],
            category: 'Action',
            rating: 4.7,
            movieTitle: 'The Dark Knight',
          ),
          TourStop(
            id: 'dark_knight_lasalle',
            name: 'LaSalle Street',
            description:
                'The famous truck flip scene was filmed here during the intense chase sequence with the Joker.',
            location: const LatLng(41.8870, -87.6355),
            estimatedDuration: 30,
            photos: ['https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Chicago_Theatre.jpg/1280px-Chicago_Theatre.jpg'],
            category: 'Action',
            rating: 4.8,
            movieTitle: 'The Dark Knight',
          ),
        ],
        isPublic: true,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Chicago_Theatre.jpg/1280px-Chicago_Theatre.jpg',
        categories: ['Action', 'Drama', 'Superhero'],
        timestamp: DateTime.now(),
        estimatedDuration: 75,
      ),
    ]);

    _isInitialized = true;
    notifyListeners();
  }

  List<CustomTour> getTours() {
    if (_searchQuery.isEmpty) {
      return List.unmodifiable(_tours);
    }

    return _tours.where((tour) =>
      tour.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      tour.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  CustomTour? getTourById(String id) {
    try {
      return _tours.firstWhere((tour) => tour.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> createTour({
    required String title,
    required String description,
    required String creatorId,
    required List<TourStop> stops,
    bool isPublic = false,
    String? imageUrl,
    List<String> categories = const [],
  }) async {
    final tour = CustomTour(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      creatorId: creatorId,
      stops: stops,
      isPublic: isPublic,
      imageUrl: imageUrl,
      categories: categories,
      timestamp: DateTime.now(),
      estimatedDuration:
          stops.fold(0, (sum, stop) => sum + stop.estimatedDuration),
    );
    _tours.add(tour);
    notifyListeners();
  }

  List<CustomTour> getToursNearLocation(LatLng location,
      {double radiusKm = 5.0}) {
    // TODO: Implement proper location-based filtering
    return _tours.where((tour) => tour.isPublic).toList();
  }

  List<CustomTour> getUserCreatedTours(String userId) {
    return _tours.where((tour) => tour.creatorId == userId).toList();
  }

  List<CustomTour> getUserTours(String userId) {
    // TODO: Implement user participation tracking
    return _tours.where((tour) => tour.isPublic).toList();
  }

  double getTourProgress(String tourId) {
    final tour = _tours.firstWhere((t) => t.id == tourId);
    if (tour.stops.isEmpty) return 0.0;

    final visitedStops = tour.stops.where((stop) => stop.isVisited).length;
    return visitedStops / tour.stops.length;
  }

  Future<void> rateTour(String tourId, double rating) async {
    // TODO: Implement tour rating system
  }

  List<CustomTour> getRecommendedTours() {
    // TODO: Implement recommendation algorithm
    return _tours.where((tour) => tour.isPublic).take(5).toList();
  }

  List<CustomTour> getToursByCategory(String category) {
    return _tours
        .where((tour) => tour.isPublic && tour.categories.contains(category))
        .toList();
  }

  Future<void> deleteTour(String tourId) async {
    _tours.removeWhere((tour) => tour.id == tourId);
    notifyListeners();
  }
}
