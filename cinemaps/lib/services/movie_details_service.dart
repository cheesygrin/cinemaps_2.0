import 'package:flutter/material.dart';
import '../models/filming_location.dart';
import '../models/movie_tour.dart';
import '../models/photo_gallery_item.dart';
import '../models/review.dart';
import 'social_service.dart';
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
      const Location(
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
      const Location(
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
      const Location(
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
      const Location(
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
      const Location(
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
      const Location(
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
      const Location(
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

  List<PhotoGalleryItem> _getSamplePhotos() {
    return [
      PhotoGalleryItem(
        id: 'sample1',
        url: 'https://picsum.photos/800/600?random=1',
        caption: 'Beautiful filming location',
        userId: 'system',
        username: 'CinemapsBot',
        locationId: 'sample_location',
        timestamp: DateTime.now(),
        likeCount: 42,
        comments: [
          PhotoComment(
            id: 'comment1',
            userId: 'user1',
            content: 'Amazing place!',
            username: 'MovieFan',
            timestamp: DateTime.now(),
            likeCount: 5,
          ),
        ],
        tags: ['scenic', 'movie', 'location'],
      ),
      PhotoGalleryItem(
        id: 'sample2',
        url: 'https://picsum.photos/800/600?random=2',
        caption: 'Historic filming spot',
        userId: 'system',
        username: 'CinemapsBot',
        locationId: 'sample_location',
        timestamp: DateTime.now(),
        likeCount: 38,
        comments: [],
        tags: ['historic', 'movie', 'location'],
      ),
      PhotoGalleryItem(
        id: 'sample3',
        url: 'https://picsum.photos/800/600?random=3',
        caption: 'Iconic movie scene location',
        userId: 'system',
        username: 'CinemapsBot',
        locationId: 'sample_location',
        timestamp: DateTime.now(),
        likeCount: 56,
        comments: [],
        tags: ['iconic', 'movie', 'scene'],
      ),
    ];
  }

  final Map<String, Map<String, dynamic>> _movieData = {
    'big': {
      'id': 'big',
      'title': 'Big',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/kBj8bJP8gWjVQXqgfMD5TzIBHrI.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/lxD5ak7BOoinRNehOCA85CQ8ubr.jpg',
      'releaseYear': 1988,
      'genres': ['Comedy', 'Drama', 'Fantasy'],
      'rating': 4.7,
      'ratingCount': 8500,
      'overview': 'After wishing to be made big, a teenage boy wakes the next morning to find himself mysteriously in the body of an adult.',
      'cast': ['Tom Hanks', 'Elizabeth Perkins', 'Robert Loggia', 'John Heard'],
      'crew': ['Penny Marshall', 'Gary Ross', 'Anne Spielberg', 'Howard Shore'],
      'filmingLocations': [
        {
          'id': 'fao_schwarz',
          'name': 'FAO Schwarz',
          'address': '767 5th Avenue, New York, NY 10153',
          'description': 'The iconic toy store where Josh and MacMillan play the giant floor piano. This scene has become one of the most memorable moments in film history.',
          'latitude': 40.7641,
          'longitude': -73.9728,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/FAO_Schwarz_flagship_store.jpg/800px-FAO_Schwarz_flagship_store.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/FAO_Schwarz_Piano.jpg/800px-FAO_Schwarz_Piano.jpg'
          ],
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
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Playland_Park_entrance.jpg/800px-Playland_Park_entrance.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Playland_Dragon_Coaster.jpg/800px-Playland_Dragon_Coaster.jpg'
          ],
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
          'id': 'manhattan_loft',
          'name': 'Josh\'s Manhattan Loft',
          'address': '83 Grand Street, New York, NY 10013',
          'description': 'The amazing toy-filled loft apartment where adult Josh lives. This SoHo location perfectly captures the 1980s New York aesthetic.',
          'latitude': 40.7219,
          'longitude': -74.0024,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/SoHo_Cast_Iron_Historic_District.jpg/800px-SoHo_Cast_Iron_Historic_District.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/SoHo_Greene_Street.jpg/800px-SoHo_Greene_Street.jpg'
          ],
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
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/MetLife_Building.jpg/800px-MetLife_Building.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Pan_Am_Building.jpg/800px-Pan_Am_Building.jpg'
          ],
          'rating': 4.6,
          'visitCount': 4100,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'Office exterior shots',
            'Josh arriving at work scenes'
          ]
        }
      ],
      'locationId': 'fao_schwarz',
      'reviews': [],
      'photos': [],
      'comments': [],
      'relatedTours': []
    },
    'dark_knight': {
      'id': 'dark_knight',
      'title': 'The Dark Knight',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg',
      'releaseYear': 2008,
      'genres': ['Action', 'Crime', 'Drama', 'Thriller'],
      'rating': 4.9,
      'ratingCount': 25000,
      'overview': 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets. The partnership proves to be effective, but they soon find themselves prey to a reign of chaos unleashed by a rising criminal mastermind known to the terrified citizens of Gotham as the Joker.',
      'cast': ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart', 'Michael Caine', 'Gary Oldman'],
      'crew': ['Christopher Nolan', 'Jonathan Nolan', 'Emma Thomas', 'Hans Zimmer'],
      'filmingLocations': [
        {
          'id': 'chicago_board_trade',
          'name': 'Chicago Board of Trade',
          'address': '141 W Jackson Blvd, Chicago, IL',
          'description': 'The iconic Art Deco building served as the exterior of Wayne Enterprises and was featured in several key scenes.',
          'latitude': 41.8787,
          'longitude': -87.6320,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Chicago_board_of_trade_building.jpg/800px-Chicago_board_of_trade_building.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Chicago_Board_of_Trade_Building.jpg/800px-Chicago_Board_of_Trade_Building.jpg'
          ],
          'rating': 4.8,
          'visitCount': 7500,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Batman overlooking the city', 'Car chase scenes']
        },
        {
          'id': 'navy_pier',
          'name': 'Navy Pier',
          'address': '600 E Grand Ave, Chicago, IL',
          'description': 'This famous Chicago landmark was transformed into Gotham Port for the dramatic ferry scene.',
          'latitude': 41.8919,
          'longitude': -87.6051,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Navy_Pier_aerial.jpg/800px-Navy_Pier_aerial.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Navy_Pier_at_night.jpg/800px-Navy_Pier_at_night.jpg'
          ],
          'rating': 4.7,
          'visitCount': 6200,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Ferry scene', 'Final confrontation']
        }
      ],
      'locationId': 'chicago_board_trade'
    },
    'gladiator': {
      'id': 'gladiator',
      'title': 'Gladiator',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/ehGpN04mLJIrSnxcZBMvHeG0eDc.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/3xgTVWJDUnY9lIhkb51UqEGPrPw.jpg',
      'releaseYear': 2000,
      'genres': ['Action', 'Adventure', 'Drama'],
      'rating': 4.8,
      'ratingCount': 18000,
      'overview': 'In the year 180, the death of emperor Marcus Aurelius throws the Roman Empire into chaos. Maximus is one of the Roman army\'s most capable and trusted generals and a key advisor to the emperor. As Marcus\' devious son Commodus ascends to the throne, Maximus is set to be executed. He escapes, but is captured by slave traders and becomes a gladiator.',
      'cast': ['Russell Crowe', 'Joaquin Phoenix', 'Connie Nielsen', 'Oliver Reed'],
      'crew': ['Ridley Scott', 'David Franzoni', 'John Logan', 'Hans Zimmer'],
      'filmingLocations': [
        {
          'id': 'fort_ricasoli',
          'name': 'Fort Ricasoli',
          'address': 'Kalkara, Malta',
          'description': 'This 17th-century fort was transformed into the Roman Colosseum for the film\'s iconic gladiatorial scenes.',
          'latitude': 35.8969,
          'longitude': 14.5180,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Fort_Ricasoli_aerial.jpg/800px-Fort_Ricasoli_aerial.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Fort_Ricasoli_gate.jpg/800px-Fort_Ricasoli_gate.jpg'
          ],
          'rating': 4.9,
          'visitCount': 4200,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Gladiatorial combat scenes', 'Arena battles']
        },
        {
          'id': 'ouarzazate',
          'name': 'Atlas Film Studios',
          'address': 'Ouarzazate, Morocco',
          'description': 'Known as the "Hollywood of Morocco," this studio complex was used for the film\'s epic battle sequences.',
          'latitude': 30.9169,
          'longitude': -6.8939,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Atlas_Film_Studios.jpg/800px-Atlas_Film_Studios.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Atlas_Studios_set.jpg/800px-Atlas_Studios_set.jpg'
          ],
          'rating': 4.7,
          'visitCount': 3800,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Opening battle sequence', 'Germanic battle']
        }
      ],
      'locationId': 'fort_ricasoli'
    },
    'slumdog_millionaire': {
      'id': 'slumdog_millionaire',
      'title': 'Slumdog Millionaire',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/2BQoJHJtWWJ3Y5oBXTEwGwuKAFX.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/tCoWk5LG7wWpHlxTJWIHgL46Jpk.jpg',
      'releaseYear': 2008,
      'genres': ['Drama', 'Romance'],
      'rating': 4.8,
      'ratingCount': 12500,
      'overview': 'A Mumbai teenager reflects on his life after being accused of cheating on the Indian version of "Who Wants to be a Millionaire?"',
      'cast': ['Dev Patel', 'Freida Pinto', 'Madhur Mittal'],
      'crew': ['Danny Boyle', 'Simon Beaufoy'],
      'filmingLocations': [
        {
          'id': 'dharavi',
          'name': 'Dharavi',
          'address': 'Dharavi, Mumbai, India',
          'description': 'The largest slum in Asia, where key scenes of the movie were filmed.',
          'latitude': 19.0380,
          'longitude': 72.8538,
          'photos': [],
          'rating': 4.5,
          'visitCount': 1000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Chase sequences', 'Childhood scenes']
        },
        {
          'id': 'cst_station',
          'name': 'Chhatrapati Shivaji Terminus',
          'address': 'CST Area, Mumbai, India',
          'description': 'The iconic railway station where the final dance sequence was filmed.',
          'latitude': 18.9398,
          'longitude': 72.8354,
          'photos': [],
          'rating': 4.7,
          'visitCount': 5000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Dance sequence', 'Train station scenes']
        }
      ],
      'locationId': 'dharavi',
      'reviews': [],
      'photos': [],
      'comments': [],
      'relatedTours': []
    },
    'raiders': {
      'id': 'raiders',
      'title': 'Raiders of the Lost Ark',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/ceG9VzoRAVGwivFU403Wc3AHRys.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/AmR3JG1VQVxU8TfAvljUhfSFUOx.jpg',
      'releaseYear': 1981,
      'genres': ['Action', 'Adventure'],
      'rating': 4.8,
      'ratingCount': 15000,
      'overview': 'When Dr. Indiana Jones – the tweed-suited professor who just happens to be a celebrated archaeologist – is hired by the government to locate the legendary Ark of the Covenant, he finds himself up against the entire Nazi regime.',
      'cast': ['Harrison Ford', 'Karen Allen', 'Paul Freeman', 'John Rhys-Davies'],
      'crew': ['Steven Spielberg', 'George Lucas', 'Lawrence Kasdan', 'John Williams'],
      'filmingLocations': [
        {
          'id': 'kauai_grove',
          'name': 'Huleia National Wildlife Refuge',
          'address': 'Huleia Valley, Kauai, Hawaii',
          'description': 'The famous opening sequence where Indiana Jones escapes from the temple was filmed in the lush jungles of Kauai.',
          'latitude': 21.9461,
          'longitude': -159.3711,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Huleia_Valley.jpg/800px-Huleia_Valley.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Kauai_jungle.jpg/800px-Kauai_jungle.jpg'
          ],
          'rating': 4.8,
          'visitCount': 3200,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'Opening temple escape sequence',
            'Running from the Hovitos warriors',
            'Boulder chase scene'
          ]
        },
        {
          'id': 'kasbah_udayas',
          'name': 'Kasbah of the Udayas',
          'address': 'Rabat, Morocco',
          'description': 'This ancient fortress served as a backdrop for several Cairo scenes.',
          'latitude': 34.0331,
          'longitude': -6.8371,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Kasbah_of_the_Udayas.jpg/800px-Kasbah_of_the_Udayas.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Udayas_street.jpg/800px-Udayas_street.jpg'
          ],
          'rating': 4.7,
          'visitCount': 2800,
          'isVerified': true,
          'reviews': [],
          'scenes': [
            'Cairo marketplace chase',
            'Marion\'s bar exterior shots',
            'Street bazaar scenes'
          ]
        }
      ],
      'locationId': 'kauai_grove'
    },
    'inception': {
      'id': 'inception',
      'title': 'Inception',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
      'releaseYear': 2010,
      'genres': ['Action', 'Science Fiction', 'Adventure'],
      'rating': 4.9,
      'ratingCount': 22000,
      'overview': 'Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets is offered a chance to regain his old life as payment for a task considered to be impossible: "inception", the implantation of another person\'s idea into a target\'s subconscious.',
      'cast': ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Ellen Page', 'Tom Hardy'],
      'crew': ['Christopher Nolan', 'Hans Zimmer', 'Wally Pfister'],
      'filmingLocations': [
        {
          'id': 'tangier',
          'name': 'Tangier, Morocco',
          'address': 'Tangier, Morocco',
          'description': 'The maze-like streets of Tangier\'s old city were used for the chase sequence.',
          'latitude': 35.7595,
          'longitude': -5.8340,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Tangier_Medina.jpg/800px-Tangier_Medina.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Tangier_Streets.jpg/800px-Tangier_Streets.jpg'
          ],
          'rating': 4.7,
          'visitCount': 3200,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Chase sequence', 'Market scenes']
        },
        {
          'id': 'alberta',
          'name': 'Fortress Mountain, Alberta',
          'address': 'Fortress Mountain, Kananaskis, Alberta, Canada',
          'description': 'The snow fortress sequence was filmed at this ski resort.',
          'latitude': 50.8253,
          'longitude': -115.2128,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Fortress_Mountain.jpg/800px-Fortress_Mountain.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Alberta_Mountains.jpg/800px-Alberta_Mountains.jpg'
          ],
          'rating': 4.9,
          'visitCount': 2800,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Snow fortress battle', 'Ski chase']
        }
      ],
      'locationId': 'tangier'
    },
    'spider_man': {
      'id': 'spider_man',
      'title': 'Spider-Man',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/628Dep6AxEtDxjZoGP78TsOxYbK.jpg',
      'releaseYear': 2002,
      'genres': ['Action', 'Adventure', 'Fantasy'],
      'rating': 4.7,
      'ratingCount': 16000,
      'overview': 'After being bitten by a genetically altered spider at Oscorp, nerdy high school student Peter Parker is endowed with amazing powers to become the Amazing Spider-Man.',
      'cast': ['Tobey Maguire', 'Kirsten Dunst', 'Willem Dafoe', 'James Franco'],
      'crew': ['Sam Raimi', 'David Koepp', 'Danny Elfman'],
      'filmingLocations': [
        {
          'id': 'times_square',
          'name': 'Times Square',
          'address': 'Times Square, Manhattan, New York',
          'description': 'The iconic final battle between Spider-Man and Green Goblin was filmed here.',
          'latitude': 40.7580,
          'longitude': -73.9855,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Times_Square_1.jpg/800px-Times_Square_1.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Times_Square_2.jpg/800px-Times_Square_2.jpg'
          ],
          'rating': 4.8,
          'visitCount': 25000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Final battle', 'City swinging scenes']
        }
      ],
      'locationId': 'times_square'
    },
    'into_the_wild': {
      'id': 'into_the_wild',
      'title': 'Into the Wild',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/2MSGZEE6XZd2r4ODNziwAw7Hpw0.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/sG6n4ei1F0kVQtTs3fAjDghgwf0.jpg',
      'releaseYear': 2007,
      'genres': ['Adventure', 'Drama', 'Biography'],
      'rating': 4.7,
      'ratingCount': 12000,
      'overview': 'After graduating from Emory University in 1992, top student and athlete Christopher McCandless abandons his possessions, gives his entire savings account of 24,000 dollars to charity, and hitchhikes to Alaska to live in the wilderness.',
      'cast': ['Emile Hirsch', 'Marcia Gay Harden', 'William Hurt', 'Jena Malone', 'Catherine Keener'],
      'crew': ['Sean Penn', 'Eddie Vedder', 'Eric Gautier'],
      'filmingLocations': [
        {
          'id': 'bus_142',
          'name': 'Stampede Trail - Magic Bus 142',
          'address': 'Denali National Park, Alaska',
          'description': 'The iconic abandoned bus where Christopher McCandless spent his final months. Note: The bus was airlifted from the site in 2020 due to public safety concerns.',
          'latitude': 63.8667,
          'longitude': -149.7583,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Magic_Bus_142.jpg/800px-Magic_Bus_142.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Bus_142_site.jpg/800px-Bus_142_site.jpg'
          ],
          'rating': 4.9,
          'visitCount': 5000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Final destination scenes', 'Survival sequences']
        },
        {
          'id': 'salvation_mountain',
          'name': 'Salvation Mountain',
          'address': 'Niland, California',
          'description': 'The colorful art installation in the Colorado Desert where Chris meets Jan Burres and Rainey.',
          'latitude': 33.2541,
          'longitude': -115.4724,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Salvation_Mountain.jpg/800px-Salvation_Mountain.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Salvation_Mountain_entrance.jpg/800px-Salvation_Mountain_entrance.jpg'
          ],
          'rating': 4.7,
          'visitCount': 8000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Desert community scenes', 'Meeting with desert residents']
        },
        {
          'id': 'lake_mead',
          'name': 'Lake Mead',
          'address': 'Nevada/Arizona Border',
          'description': 'Where Chris works as a kayak instructor and experiences the freedom of nature.',
          'latitude': 36.1447,
          'longitude': -114.4108,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Lake_Mead_from_Hoover_Dam.jpg/800px-Lake_Mead_from_Hoover_Dam.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8b/Lake_Mead_Marina.jpg/800px-Lake_Mead_Marina.jpg'
          ],
          'rating': 4.6,
          'visitCount': 12000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Kayaking scenes', 'Working at the marina']
        }
      ],
      'locationId': 'bus_142',
      'reviews': [],
      'photos': [],
      'comments': [],
      'relatedTours': []
    },
    'back_to_the_future': {
      'id': 'back_to_the_future',
      'title': 'Back to the Future',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/7lyBcpYB0Qt8gYhXYaEZUNlNQAv.jpg',
      'backdropUrl': 'https://image.tmdb.org/t/p/original/x4N74cycZvKu5k3KDERJay4ajR3.jpg',
      'releaseYear': 1985,
      'genres': ['Adventure', 'Comedy', 'Science Fiction'],
      'rating': 4.9,
      'ratingCount': 20000,
      'overview': 'Marty McFly, a 17-year-old high school student, is accidentally sent thirty years into the past in a time-traveling DeLorean invented by his close friend, the eccentric scientist Doc Brown.',
      'cast': ['Michael J. Fox', 'Christopher Lloyd', 'Lea Thompson', 'Crispin Glover', 'Thomas F. Wilson'],
      'crew': ['Robert Zemeckis', 'Bob Gale', 'Alan Silvestri', 'Steven Spielberg'],
      'filmingLocations': [
        {
          'id': 'courthouse_square',
          'name': 'Courthouse Square',
          'address': '100 Universal City Plaza, Universal City, CA',
          'description': 'The iconic town square where the Clock Tower stands. This location at Universal Studios has become a major tourist attraction.',
          'latitude': 34.1381,
          'longitude': -118.3534,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Hill_Valley_Courthouse.jpg/800px-Hill_Valley_Courthouse.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Back_to_the_Future_Clock_Tower.jpg/800px-Back_to_the_Future_Clock_Tower.jpg'
          ],
          'rating': 4.9,
          'visitCount': 50000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Clock Tower lightning strike', 'Town square scenes in 1955 and 1985']
        },
        {
          'id': 'mcfly_house',
          'name': 'Marty McFly\'s House',
          'address': '9303 Roslyndale Ave, Arleta, CA',
          'description': 'The actual house used for the exterior shots of the McFly family home.',
          'latitude': 34.2352,
          'longitude': -118.4305,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/McFly_House.jpg/800px-McFly_House.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/McFly_House_Street.jpg/800px-McFly_House_Street.jpg'
          ],
          'rating': 4.7,
          'visitCount': 15000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['Opening scenes', 'Family dinner scenes']
        },
        {
          'id': 'whittier_high',
          'name': 'Whittier High School',
          'address': '12417 Philadelphia St, Whittier, CA',
          'description': 'The real high school that served as Hill Valley High School in both 1955 and 1985.',
          'latitude': 33.9790,
          'longitude': -118.0340,
          'photos': [
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Whittier_High_School.jpg/800px-Whittier_High_School.jpg',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Hill_Valley_High_School.jpg/800px-Hill_Valley_High_School.jpg'
          ],
          'rating': 4.6,
          'visitCount': 20000,
          'isVerified': true,
          'reviews': [],
          'scenes': ['School scenes', 'First meeting of Marty\'s parents']
        }
      ],
      'locationId': 'courthouse_square',
      'reviews': [],
      'photos': [],
      'comments': [],
      'relatedTours': []
    },
  };

  Future<MovieDetails> getMovieDetails(String movieId) async {
    if (_movieCache.containsKey(movieId)) {
      return _movieCache[movieId]!;
    }

    try {
      final data = _movieData[movieId];
      if (data == null) {
        throw Exception('Movie not found');
      }

      final filmingLocations = (data['filmingLocations'] as List<dynamic>? ?? [])
          .map((loc) => FilmingLocation(
                id: loc['id'] as String? ?? '',
                name: loc['name'] as String? ?? '',
                address: loc['address'] as String? ?? '',
                description: loc['description'] as String? ?? '',
                latitude: loc['latitude'] as double? ?? 0.0,
                longitude: loc['longitude'] as double? ?? 0.0,
                photos: (loc['photos'] as List<dynamic>? ?? []).map((url) => PhotoGalleryItem(
                  id: '${loc['id']}_${(loc['photos'] as List).indexOf(url)}',
                  url: url as String,
                  caption: '${loc['name']} - ${loc['description']}',
                  userId: 'system',
                  username: 'CinemapsBot',
                  locationId: loc['id'] as String? ?? '',
                  timestamp: DateTime.now(),
                  likeCount: 0,
                  comments: [],
                  tags: ['movie', 'location'],
                )).toList(),
                rating: loc['rating'] as double? ?? 0.0,
                visitCount: loc['visitCount'] as int? ?? 0,
                isVerified: loc['isVerified'] as bool? ?? false,
                reviews: (loc['reviews'] as List<dynamic>? ?? []).map((r) => Review(
                      id: r['id'] as String? ?? '',
                      userId: r['userId'] as String? ?? '',
                      username: r['username'] as String? ?? 'Anonymous',
                      rating: r['rating'] as double? ?? 0.0,
                      comment: r['comment'] as String? ?? '',
                      timestamp: DateTime.now(),
                    )).toList(),
                scenes: (loc['scenes'] as List<dynamic>? ?? []).cast<String>(),
              ))
          .toList();

      final movieDetails = MovieDetails(
        id: data['id'] as String? ?? movieId,
        title: data['title'] as String? ?? 'Unknown Title',
        posterUrl: data['posterUrl'] as String?,
        backdropUrl: data['backdropUrl'] as String?,
        releaseYear: data['releaseYear'] as int? ?? 0,
        genres: (data['genres'] as List<dynamic>? ?? []).cast<String>(),
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: data['ratingCount'] as int? ?? 0,
        overview: data['overview'] as String? ?? 'No overview available',
        cast: (data['cast'] as List<dynamic>? ?? []).cast<String>(),
        crew: (data['crew'] as List<dynamic>? ?? []).cast<String>(),
        filmingLocations: filmingLocations,
        relatedTours: (data['relatedTours'] as List<dynamic>? ?? [])
            .map((tour) => MovieTour(
                  id: tour['id'] as String? ?? '',
                  name: tour['name'] as String? ?? '',
                  description: tour['description'] as String? ?? '',
                  estimatedDuration: Duration(minutes: tour['duration'] as int? ?? 0),
                  rating: tour['rating'] as double? ?? 0.0,
                  distance: 0.0,
                  locations: [],
                  completionCount: 0,
                  reviews: [],
                  createdBy: 'system',
                  timestamp: DateTime.now(),
                ))
            .toList(),
        reviews: (data['reviews'] as List<dynamic>? ?? [])
            .map((r) => Review(
                  id: r['id'] as String? ?? '',
                  userId: r['userId'] as String? ?? '',
                  username: r['username'] as String? ?? 'Anonymous',
                  rating: r['rating'] as double? ?? 0.0,
                  comment: r['comment'] as String? ?? '',
                  timestamp: DateTime.now(),
                ))
            .toList(),
        photos: filmingLocations.expand((loc) => loc.photos).toList(),
        locationId: data['locationId'] as String? ?? '',
        comments: (data['comments'] as List<dynamic>? ?? [])
            .map((c) => Comment(
                  id: c['id'] as String? ?? '',
                  userId: c['userId'] as String? ?? '',
                  content: c['content'] as String? ?? '',
                  timestamp: DateTime.now(),
                ))
            .toList(),
      );

      _movieCache[movieId] = movieDetails;
      return movieDetails;
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
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
}
