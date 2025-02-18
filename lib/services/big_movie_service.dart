import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../models/location.dart';

class BigMovieService extends ChangeNotifier {
  Movie? _movie;
  List<Location> _locations = [];

  Movie? get movie => _movie;
  List<Location> get locations => List.unmodifiable(_locations);

  Future<void> loadMovie() async {
    _movie = Movie(
      id: 'big_1988',
      title: 'Big',
      overview: 'When a young boy makes a wish at a carnival machine to be big—he wakes up the following morning to find that it has been granted and his body has grown older overnight. But he is still the same 13-year-old boy inside. Now he must learn how to cope with the consequences of his wish.',
      rating: 4.8,
      posterUrl: 'https://image.tmdb.org/t/p/w500/eWWyUx0NyHxn8iIE3cmxH6NlHYh.jpg',
    );

    _locations = [
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
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/FAO_Schwarz_Interior.jpg/1280px-FAO_Schwarz_Interior.jpg'
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
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Playland_Park_Boardwalk.jpg/1280px-Playland_Park_Boardwalk.jpg'
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
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/SoHo_Street.jpg/1280px-SoHo_Street.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/SoHo_Architecture.jpg/1280px-SoHo_Architecture.jpg'
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
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Madison_Square.jpg/1280px-Madison_Square.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Fifth_Avenue.jpg/1280px-Fifth_Avenue.jpg'
        ],
      ),
    ];

    notifyListeners();
  }
} 