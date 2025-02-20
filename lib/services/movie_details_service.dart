import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/filming_location.dart';
import '../models/movie_tour.dart';
import '../models/photo_gallery_item.dart';
import '../models/review.dart';
import 'social_service.dart';
import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/location.dart';

class MovieDetails {
  final String id;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final int releaseYear;
  final List<String> genres;
  final double rating;
  final int ratingCount;
  final String overview;
  final List<String> cast;
  final List<String> crew;
  final List<FilmingLocation> filmingLocations;
  final List<MovieTour> relatedTours;
  final List<Review> reviews;
  final List<PhotoGalleryItem> photos;
  final String locationId;
  final List<Comment> comments;

  MovieDetails({
    required this.id,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    required this.releaseYear,
    required this.genres,
    required this.rating,
    required this.ratingCount,
    required this.overview,
    required this.cast,
    required this.crew,
    required this.filmingLocations,
    required this.relatedTours,
    required this.reviews,
    required this.photos,
    required this.locationId,
    this.comments = const [],
  });
}


class MovieDetailsService extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Map<String, MovieDetails> _movieCache = {};
  final Map<String, List<Review>> _reviewCache = {};
  final Map<String, List<PhotoGalleryItem>> _photoCache = {};
  final Map<String, List<Location>> _movieLocations = {};
  bool _isInitialized = false;

  MovieDetailsService() {
    _initializeLocations();
  }

  void _initializeLocations() {
    if (_isInitialized) return;

    // Big (1988)
    _movieLocations['big_1988'] = [
      Location(
        id: 'fao_schwarz',
        name: 'FAO Schwarz',
        address: '767 5th Ave, New York, NY 10153',
        description: 'The iconic toy store where Josh and MacMillan play the giant piano.',
        rating: 4.8,
        lat: 40.7636,
        lng: -73.9731,
        photos: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/FAO_Schwarz_NYC.jpg/1280px-FAO_Schwarz_NYC.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/FAO_Schwarz_Piano.jpg/1280px-FAO_Schwarz_Piano.jpg',
        ],
      ),
      Location(
        id: 'playland',
        name: 'Playland Park',
        address: '1 Playland Parkway, Rye, NY 10580',
        description: 'The amusement park where Josh makes his wish at the Zoltar machine.',
        rating: 4.5,
        lat: 40.9674,
        lng: -73.6731,
        photos: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Playland_Park_Entrance.jpg/1280px-Playland_Park_Entrance.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Playland_Park_Rides.jpg/1280px-Playland_Park_Rides.jpg',
        ],
      ),
      Location(
        id: 'manhattan_loft',
        name: 'Josh\'s Manhattan Loft',
        address: '83 Grand Street, New York, NY 10013',
        description: 'The loft apartment where adult Josh lives.',
        rating: 4.3,
        lat: 40.7219,
        lng: -74.0024,
        photos: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/SoHo_Loft_Building.jpg/1280px-SoHo_Loft_Building.jpg',
        ],
      ),
      Location(
        id: 'macmillan',
        name: 'MacMillan Toys',
        address: '200 5th Ave, New York, NY 10010',
        description: 'The toy company where Josh works.',
        rating: 4.6,
        lat: 40.7419,
        lng: -73.9892,
        photos: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Flatiron_Building.jpg/1280px-Flatiron_Building.jpg',
        ],
      ),
    ];

    // Raiders of the Lost Ark (1981)
    _movieLocations['raiders'] = [
      Location(
        id: 'kauai',
        name: 'Kauai, Hawaii',
        address: 'Kauai, HI',
        description: 'The opening sequence of Raiders was filmed in the lush jungles of Kauai.',
        rating: 4.9,
        lat: 22.0964,
        lng: -159.5261,
        photos: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Kauai_Jungle.jpg/1280px-Kauai_Jungle.jpg',
        ],
      ),
    ];

    // Gladiator (2000)
    _movieLocations['gladiator'] = [
      Location(
        id: 'kasbah',
        name: 'Aït Benhaddou',
        address: 'Aït Benhaddou, Morocco',
        description: 'This ancient fortified village served as a backdrop for the gladiator training scenes.',
        rating: 4.7,
        lat: 31.0474,
        lng: -7.1282,
        photos: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Ait_Benhaddou.jpg/1280px-Ait_Benhaddou.jpg',
        ],
      ),
    ];

    // Star Wars: Episode IV (1977)
    _movieLocations['star_wars'] = [
      Location(
        id: 'tunisia',
        name: 'Matmata',
        address: 'Matmata, Tunisia',
        description: 'The underground dwellings of Matmata were used as Luke Skywalker\'s home on Tatooine.',
        rating: 4.6,
        lat: 33.5446,
        lng: 9.9715,
        photos: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Matmata_Tunisia.jpg/1280px-Matmata_Tunisia.jpg',
        ],
      ),
    ];

    _isInitialized = true;
    notifyListeners();
  }

  List<Location>? getMovieLocations(String movieId) {
    return _movieLocations[movieId];
  }

  static final Map<String, dynamic> _movieData = {
    'big': {
      'id': 'big',
      'title': 'Big',
      'posterUrl': 'https://placehold.co/300x450/png?text=Big',
      'backdropUrl': 'https://placehold.co/1920x1080/png?text=Big+Backdrop',
      'releaseYear': 1988,
      'genres': ['Comedy', 'Drama', 'Fantasy'],
      'overview': 'After wishing to be made big, a teenage boy wakes the next morning to find himself mysteriously in the body of an adult.',
      'cast': ['Tom Hanks', 'Elizabeth Perkins', 'Robert Loggia', 'John Heard'],
      'crew': ['Penny Marshall', 'Gary Ross', 'Anne Spielberg'],
      'filmingLocations': [
        {
          'id': 'fao_schwarz',
          'name': 'FAO Schwarz',
          'address': '767 5th Avenue, New York, NY 10153',
          'description': 'The iconic toy store where Josh and MacMillan play the giant floor piano. This scene has become one of the most memorable moments in film history.',
          'latitude': 40.7641,
          'longitude': -73.9728,
          'photos': ['assets/images/big/big_fao_schwarz.jpg', 'assets/images/big/big_piano.jpg'],
          'rating': 4.9,
          'visitCount': 12500,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'The famous floor piano scene',
            'Josh and MacMillan\'s "Heart and Soul" duet'
          ]
        },
        {
          'id': 'playland_park',
          'name': 'Playland Amusement Park',
          'address': '1 Playland Parkway, Rye, NY 10580',
          'description': 'The historic amusement park where Josh makes his fateful wish at the Zoltar machine. The park still operates today and is a historic landmark.',
          'latitude': 40.9697,
          'longitude': -73.6747,
          'photos': ['assets/images/big/big_playland.jpg', 'assets/images/big/big_zoltar.jpg'],
          'rating': 4.7,
          'visitCount': 8300,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'Zoltar machine wish scene',
            'Opening carnival scenes'
          ]
        },
        {
          'id': 'cliffside_park',
          'name': 'Ross Dock Picnic Area',
          'address': 'Palisades Interstate Park, Fort Lee, NJ 07024',
          'description': 'The location of Josh\'s New Jersey home, where he transforms into an adult. The park offers stunning views of the Hudson River and Manhattan skyline.',
          'latitude': 40.8515,
          'longitude': -73.9567,
          'photos': ['assets/images/big/big_house.jpg'],
          'rating': 4.5,
          'visitCount': 3200,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'Josh\'s house exterior shots',
            'Neighborhood scenes'
          ]
        },
        {
          'id': 'manhattan_loft',
          'name': 'Josh\'s Manhattan Loft',
          'address': '83 Grand Street, New York, NY 10013',
          'description': 'The amazing toy-filled loft apartment where adult Josh lives. This SoHo location perfectly captures the 1980s New York aesthetic.',
          'latitude': 40.7219,
          'longitude': -74.0024,
          'photos': ['assets/images/big/big_loft.jpg', 'assets/images/big/big_toys.jpg'],
          'rating': 4.8,
          'visitCount': 5600,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'Trampoline scene',
            'Basketball hoop scenes',
            'Pinball machine scenes'
          ]
        },
        {
          'id': 'macmillan_toys',
          'name': 'MacMillan Toy Company',
          'address': '200 Park Avenue, New York, NY 10166',
          'description': 'The MetLife Building (formerly Pan Am Building) served as the exterior of the MacMillan Toy Company headquarters, where Josh gets his dream job testing toys.',
          'latitude': 40.7528,
          'longitude': -73.9765,
          'photos': ['assets/images/big/big_macmillan.jpg'],
          'rating': 4.6,
          'visitCount': 4100,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'Office exterior shots',
            'Josh arriving at work scenes'
          ]
        }
      ]
    },
    'dark_knight': {
      'title': 'The Dark Knight',
      'posterUrl': '',
      'backdropUrl': '',
      'releaseYear': 2008,
      'genres': ['Action', 'Crime', 'Drama', 'Thriller'],
      'overview': 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets. The partnership proves to be effective, but they soon find themselves prey to a reign of chaos unleashed by a rising criminal mastermind known to the terrified citizens of Gotham as the Joker.',
      'cast': ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart'],
      'crew': ['Christopher Nolan', 'Jonathan Nolan', 'Emma Thomas'],
      'locations': [
        {
          'id': 'chicago_board_trade',
          'name': 'Chicago Board of Trade',
          'address': '141 W Jackson Blvd, Chicago, IL',
          'latitude': 41.8787,
          'longitude': -87.6320,
          'description': 'Wayne Enterprises exterior',
          'scenes': ['Batman overlooking the city', 'Car chase scenes']
        },
        {
          'id': 'navy_pier',
          'name': 'Navy Pier',
          'address': '600 E Grand Ave, Chicago, IL',
          'latitude': 41.8919,
          'longitude': -87.6051,
          'description': 'Gotham Port scenes',
          'scenes': ['Ferry scene', 'Final confrontation']
        }
      ]
    },
    'gladiator': {
      'title': 'Gladiator',
      'posterUrl': '',
      'backdropUrl': '',
      'releaseYear': 2000,
      'genres': ['Action', 'Adventure', 'Drama'],
      'overview': 'In the year 180, the death of emperor Marcus Aurelius throws the Roman Empire into chaos. Maximus is one of the Roman army\'s most capable and trusted generals and a key advisor to the emperor. As Marcus\' devious son Commodus ascends to the throne, Maximus is set to be executed. He escapes, but is captured by slave traders and becomes a gladiator.',
      'cast': ['Russell Crowe', 'Joaquin Phoenix', 'Connie Nielsen'],
      'crew': ['Ridley Scott', 'David Franzoni', 'John Logan'],
      'locations': [
        {
          'id': 'fort_ricasoli',
          'name': 'Fort Ricasoli',
          'address': 'Kalkara, Malta',
          'latitude': 35.8969,
          'longitude': 14.5180,
          'description': 'Roman Colosseum scenes',
          'scenes': ['Gladiatorial combat scenes', 'Arena battles']
        },
        {
          'id': 'ouarzazate',
          'name': 'Atlas Film Studios',
          'address': 'Ouarzazate, Morocco',
          'latitude': 30.9169,
          'longitude': -6.8939,
          'description': 'Roman city and battle scenes',
          'scenes': ['Opening battle sequence', 'Germanic battle']
        }
      ]
    },
    'slumdog_millionaire': {
      'title': 'Slumdog Millionaire',
      'posterUrl': '',
      'backdropUrl': '',
      'releaseYear': 2008,
      'genres': ['Drama'],
      'overview': 'A Mumbai teenager reflects on his life after being accused of cheating on the Indian version of "Who Wants to be a Millionaire?"',
      'cast': ['Dev Patel', 'Freida Pinto', 'Amanori Ghatge'],
      'crew': ['Danny Boyle', 'Simon Beaufoy', 'John Hodge'],
      'locations': [
        {
          'id': 'dharavi',
          'name': 'Dharavi',
          'address': 'Dharavi, Mumbai, India',
          'latitude': 19.0380,
          'longitude': 72.8538,
          'description': 'Various scenes in the slum',
          'scenes': ['Childhood scenes', 'Chase sequences']
        },
        {
          'id': 'cst_station',
          'name': 'Chhatrapati Shivaji Terminus',
          'address': 'CST Area, Mumbai, India',
          'latitude': 18.9398,
          'longitude': 72.8354,
          'description': 'The iconic train station dance scene finale',
          'scenes': ['Dance sequence', 'Train station scenes']
        }
      ]
    },
    'raiders_lost_ark': {
      'title': 'Raiders of the Lost Ark',
      'posterUrl': 'https://placehold.co/300x450/png?text=Raiders',
      'backdropUrl': 'https://placehold.co/1920x1080/png?text=Raiders+Backdrop',
      'releaseYear': 1981,
      'genres': ['Action', 'Adventure'],
      'overview': 'When Dr. Indiana Jones – the tweed-suited professor who just happens to be a celebrated archaeologist – is hired by the government to locate the legendary Ark of the Covenant, he finds himself up against the entire Nazi regime.',
      'cast': ['Harrison Ford', 'Karen Allen', 'Paul Freeman', 'John Rhys-Davies'],
      'crew': ['Steven Spielberg', 'George Lucas', 'Lawrence Kasdan'],
      'filmingLocations': [
        {
          'id': 'kauai_grove',
          'name': 'Huleia National Wildlife Refuge',
          'address': 'Huleia Valley, Kauai, Hawaii',
          'coordinates': {'latitude': 21.9461, 'longitude': -159.3711},
          'description': 'The famous opening sequence where Indiana Jones escapes from the temple was filmed in the lush jungles of Kauai.',
          'scenes': [
            'Opening temple escape sequence',
            'Running from the Hovitos warriors',
            'Boulder chase scene'
          ],
          'photos': ['assets/images/kauai.jpg'],
          'rating': 4.8,
          'isVerified': true,
          'visitCount': 1250,
          'reviews': []
        },
        {
          'id': 'kasbah_udayas',
          'name': 'Kasbah of the Udayas',
          'address': 'Rabat, Morocco',
          'coordinates': {'latitude': 34.0331, 'longitude': -6.8371},
          'description': 'This ancient fortress served as a backdrop for several Cairo scenes.',
          'scenes': [
            'Cairo marketplace chase',
            'Marion\'s bar exterior shots',
            'Street bazaar scenes'
          ],
          'photos': ['assets/images/kasbah.jpg'],
          'rating': 4.7,
          'isVerified': true,
          'visitCount': 980,
          'reviews': []
        },
        {
          'id': 'sidi_bouhlel',
          'name': 'Sidi Bouhlel',
          'address': 'Tozeur, Tunisia',
          'coordinates': {'latitude': 33.9170, 'longitude': 8.1229},
          'description': 'Known as the "Star Wars canyon" due to its use in both franchises.',
          'scenes': [
            'Nazi convoy ambush',
            'Truck chase sequence',
            'Desert pursuit scenes'
          ],
          'photos': ['assets/images/tunisia.jpg'],
          'rating': 4.9,
          'isVerified': true,
          'visitCount': 750,
          'reviews': []
        }
      ],
      'rating': 4.8,
      'ratingCount': 1000,
      'isWatchlisted': false
    }
  };

  Future<MovieDetails> getMovieDetails(String movieId) async {
    if (_movieCache.containsKey(movieId)) {
      return _movieCache[movieId]!;
    }

    final data = _movieData[movieId];
    if (data == null) {
      throw Exception('Movie not found');
    }

    final locations = (data['filmingLocations'] as List).map((loc) => FilmingLocation(
      id: loc['id'],
      name: loc['name'],
      address: loc['address'],
      latitude: loc['coordinates']['latitude'],
      longitude: loc['coordinates']['longitude'],
      description: loc['description'],
      scenes: List<String>.from(loc['scenes']),
      photos: _getSamplePhotos(),
      rating: loc['rating'],
      isVerified: loc['isVerified'],
      visitCount: loc['visitCount'],
      reviews: [],
    )).toList();

    final movieDetails = MovieDetails(
      id: movieId,
      title: data['title'],
      posterUrl: data['posterUrl'],
      backdropUrl: data['backdropUrl'],
      releaseYear: data['releaseYear'],
      genres: List<String>.from(data['genres']),
      rating: data['rating'],
      ratingCount: data['ratingCount'],
      overview: data['overview'],
      cast: List<String>.from(data['cast']),
      crew: List<String>.from(data['crew']),
      filmingLocations: locations,
      relatedTours: [],
      reviews: [],
      photos: _getSamplePhotos(),
      locationId: locations.isNotEmpty ? locations.first.id : '',
      comments: [],
    );

    _movieCache[movieId] = movieDetails;
    return movieDetails;
  }

  Future<List<Review>> getMovieReviews(String movieId) async {
    if (_reviewCache.containsKey(movieId)) {
      return _reviewCache[movieId]!;
    }

    // TODO: Implement actual API call
    return [];
  }

  Future<List<PhotoGalleryItem>> getMoviePhotos(String movieId) async {
    if (_photoCache.containsKey(movieId)) {
      return _photoCache[movieId]!;
    }

    // TODO: Implement actual API call
    return [];
  }

  Future<void> addReview({
    required String movieId,
    required String userId,
    required double rating,
    required String comment,
    List<String> photos = const [],
  }) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<void> likeReview(String reviewId, String userId) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<void> addReviewComment({
    required String reviewId,
    required String userId,
    required String content,
  }) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<void> addPhotoComment({
    required String photoId,
    required String userId,
    required String comment,
  }) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<void> likePhoto(String photoId, String userId) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<void> markLocationAsVisited(String locationId, String userId) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<void> startTour(String tourId, String userId) async {
    // In a real app, this would start navigation and tracking
    final tour = (await getMovieDetails('1')).relatedTours
        .firstWhere((t) => t.id == tourId);

    // Show a snackbar with tour info
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text('Starting tour: ${tour.name}\nDuration: ${tour.estimatedDuration.inHours} hours\nDistance: ${tour.distance.toStringAsFixed(1)} km'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View Route',
            onPressed: () {
              // TODO: Show route on map
            },
          ),
        ),
      );
    }

    notifyListeners();
  }

  Future<void> completeTour(String tourId, String userId) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<void> rateTour({
    required String tourId,
    required String userId,
    required double rating,
    String? comment,
  }) async {
    // TODO: Implement actual API call
    notifyListeners();
  }

  Future<List<MovieDetails>> getSimilarMovies(String movieId) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<MovieTour>> getPopularTours(String movieId) async {
    // TODO: Implement actual API call
    return [];
  }

  Future<List<FilmingLocation>> getNearbyLocations({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    // TODO: Implement actual API call
    return [];
  }

  List<PhotoGalleryItem> _getSamplePhotos() {
    return [
      PhotoGalleryItem(
        id: '1',
        url: 'https://images.unsplash.com/photo-1605432146168-ac16a4b8f0b9',
        caption: 'The iconic Trump Tower, used as Wayne Enterprises in The Dark Knight',
        userId: 'user1',
        username: 'BatmanFan',
        locationId: 'loc1',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        likeCount: 1245,
        comments: [],
        tags: ['batman', 'gotham', 'chicago', 'wayneenterprises'],
      ),
      PhotoGalleryItem(
        id: '2',
        url: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df',
        caption: 'Chicago skyline at night - Gotham City comes alive',
        userId: 'user2',
        username: 'GothamSpotter',
        locationId: 'loc2',
        timestamp: DateTime.now().subtract(const Duration(days: 15)),
        likeCount: 892,
        comments: [],
        tags: ['gotham', 'skyline', 'chicago', 'batman'],
      ),
      PhotoGalleryItem(
        id: '3',
        url: 'https://images.unsplash.com/photo-1575540203949-4f1c29252f8d',
        caption: 'Navy Pier - The scene of the epic Joker escape',
        userId: 'user3',
        username: 'MovieLocations',
        locationId: 'loc3',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        likeCount: 756,
        comments: [],
        tags: ['joker', 'navypier', 'chicago', 'darkknight'],
      ),
    ];
  }
}
