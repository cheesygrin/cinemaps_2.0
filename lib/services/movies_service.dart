import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import 'tmdb_service.dart';

class MoviesService extends ChangeNotifier {
  final List<Movie> _movies = [];
  String _searchQuery = '';
  bool _isInitialized = false;
  final Map<String, String?> _posterCache = {};

  MoviesService() {
    loadMovies();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<String?> getPosterUrl(String movieId, String title, int year) async {
    if (_posterCache.containsKey(movieId)) {
      return _posterCache[movieId];
    }

    try {
      final posterUrl = await TMDbService.getMoviePoster(title, year);
      _posterCache[movieId] = posterUrl;
      notifyListeners();
      return posterUrl;
    } catch (e) {
      print('Error loading poster for $title: $e');
      return null;
    }
  }

  Future<void> loadMovies() async {
    if (_isInitialized) return;
    
    final movieData = [
      {
        'id': 'amelie',
        'title': 'Amélie',
        'year': 2001,
        'overview': 'Amélie is an innocent and naive girl in Paris with her own sense of justice. She decides to help those around her and, along the way, discovers love.',
        'rating': 4.9,
        'locationCount': 15,
        'tourCount': 3,
        'locationProgress': 0.4,
      },
      {
        'id': 'slumdog_millionaire',
        'title': 'Slumdog Millionaire',
        'year': 2008,
        'overview': 'A Mumbai teenager reflects on his life after being accused of cheating on the Indian version of "Who Wants to be a Millionaire?"',
        'rating': 4.8,
        'locationCount': 12,
        'tourCount': 2,
        'locationProgress': 0.3,
      },
      {
        'id': 'wall_e',
        'title': 'WALL-E',
        'year': 2008,
        'overview': 'In a distant, but not so unrealistic, future where mankind has abandoned earth because it has become covered with trash from products sold by the powerful Buy N Large corporation, WALL-E, a garbage collecting robot has been left to clean up the mess.',
        'rating': 4.9,
        'locationCount': 8,
        'tourCount': 1,
        'locationProgress': 0.2,
      },
      {
        'id': 'inception',
        'title': 'Inception',
        'year': 2010,
        'overview': 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
        'rating': 4.9,
        'locationCount': 20,
        'tourCount': 4,
        'locationProgress': 0.6,
      },
      {
        'id': 'spider_man',
        'title': 'Spider-Man',
        'year': 2002,
        'overview': 'When bitten by a genetically modified spider, a nerdy, shy, and awkward high school student gains spider-like abilities that he eventually must use to fight evil as a superhero after tragedy befalls his family.',
        'rating': 4.7,
        'locationCount': 18,
        'tourCount': 3,
        'locationProgress': 0.5,
      },
      {
        'id': 'memento',
        'title': 'Memento',
        'year': 2000,
        'overview': 'A man with short-term memory loss attempts to track down his wife\'s murderer.',
        'rating': 4.8,
        'locationCount': 10,
        'tourCount': 2,
        'locationProgress': 0.4,
      },
      {
        'id': 'city_of_god',
        'title': 'City of God',
        'year': 2002,
        'overview': 'In the slums of Rio, two kids\' paths diverge as one struggles to become a photographer and the other a kingpin.',
        'rating': 4.9,
        'locationCount': 15,
        'tourCount': 2,
        'locationProgress': 0.3,
      },
      {
        'id': 'donnie_darko',
        'title': 'Donnie Darko',
        'year': 2001,
        'overview': 'A troubled teenager is plagued by visions of a man in a large rabbit suit who manipulates him to commit a series of crimes, after he narrowly escapes a bizarre accident.',
        'rating': 4.7,
        'locationCount': 12,
        'tourCount': 2,
        'locationProgress': 0.4,
      },
      {
        'id': 'no_country_for_old_men',
        'title': 'No Country for Old Men',
        'year': 2007,
        'overview': 'Violence and mayhem ensue after a hunter stumbles upon a drug deal gone wrong and more than two million dollars in cash near the Rio Grande.',
        'rating': 4.8,
        'locationCount': 14,
        'tourCount': 2,
        'locationProgress': 0.3,
      },
      {
        'id': 'there_will_be_blood',
        'title': 'There Will Be Blood',
        'year': 2007,
        'overview': 'A story of family, religion, hatred, oil and madness, focusing on a turn-of-the-century prospector in the early days of the business.',
        'rating': 4.8,
        'locationCount': 10,
        'tourCount': 1,
        'locationProgress': 0.2,
      },
      {
        'id': 'into_the_wild',
        'title': 'Into the Wild',
        'year': 2007,
        'overview': 'After graduating from Emory University, top student and athlete Christopher McCandless abandons his possessions, gives his entire \$24,000 savings account to charity and hitchhikes to Alaska to live in the wilderness.',
        'rating': 4.7,
        'locationCount': 25,
        'tourCount': 3,
        'locationProgress': 0.5,
      },
      {
        'id': 'raiders',
        'title': 'Raiders of the Lost Ark',
        'year': 1981,
        'overview': 'Archaeology professor Indiana Jones ventures to seize a biblical artefact known as the Ark of the Covenant. While doing so, he puts up a fight against Renee and a troop of Nazis.',
        'rating': 4.9,
        'locationCount': 12,
        'tourCount': 2,
        'locationProgress': 0.3,
      },
      {
        'id': 'back_to_the_future',
        'title': 'Back to the Future',
        'year': 1985,
        'overview': 'Marty McFly, a 17-year-old high school student, is accidentally sent thirty years into the past in a time-traveling DeLorean invented by his close friend, the eccentric scientist Doc Brown.',
        'rating': 4.9,
        'locationCount': 8,
        'tourCount': 1,
        'locationProgress': 0.5,
      },
      {
        'id': 'ghostbusters',
        'title': 'Ghostbusters',
        'year': 1984,
        'overview': 'After losing their academic posts at a prestigious university, a team of parapsychologists goes into business as proton-pack-toting "ghostbusters" who exterminate ghouls, hobgoblins and supernatural pests of all stripes.',
        'rating': 4.8,
        'locationCount': 15,
        'tourCount': 3,
        'locationProgress': 0.7,
      },
      {
        'id': 'goonies',
        'title': 'The Goonies',
        'year': 1985,
        'overview': 'A group of young misfits called The Goonies discover an ancient map and set out on an adventure to find a legendary pirate\'s long-lost treasure.',
        'rating': 4.8,
        'locationCount': 10,
        'tourCount': 2,
        'locationProgress': 0.6,
      },
      {
        'id': 'big',
        'title': 'Big',
        'year': 1988,
        'overview': 'When a young boy makes a wish at a carnival machine to be big—he wakes up the following morning to find that it has been granted and his body has grown older overnight. But he is still the same 13-year-old boy inside. Now he must learn how to cope with the consequences of his wish.',
        'rating': 4.8,
        'locationCount': 7,
        'tourCount': 1,
        'locationProgress': 0.3,
      },
    ];

    for (final data in movieData) {
      _movies.add(Movie(
        id: data['id'] as String,
        title: data['title'] as String,
        overview: data['overview'] as String,
        rating: (data['rating'] as num).toDouble(),
        posterUrl: null, // Posters will be loaded lazily
        releaseYear: data['year'] as int,
        locationCount: data['locationCount'] as int,
        tourCount: data['tourCount'] as int,
        locationProgress: (data['locationProgress'] as num).toDouble(),
      ));
    }

    _isInitialized = true;
    notifyListeners();

    // Start loading posters in the background
    for (final movie in _movies) {
      getPosterUrl(movie.id, movie.title, movie.releaseYear);
    }
  }

  List<Movie> getMovies() {
    if (_searchQuery.isEmpty) {
      return List.unmodifiable(_movies);
    }

    return _movies.where((movie) =>
      movie.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      movie.overview.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Movie? getMovieById(String id) {
    try {
      return _movies.firstWhere((movie) => movie.id == id);
    } catch (e) {
      return null;
    }
  }

  void addMovie(Map<String, dynamic> movieData) {
    final newMovie = Movie(
      id: movieData['title'].toLowerCase().replaceAll(' ', '_'),
      title: movieData['title'],
      overview: movieData['overview'],
      rating: 0.0,
      posterUrl: null,
      releaseYear: movieData['releaseYear'] ?? 0,
      locationCount: 0,
      tourCount: 0,
      locationProgress: 0.0,
    );
    _movies.add(newMovie);
    notifyListeners();

    // Load the poster in the background
    if (movieData['releaseYear'] != null) {
      getPosterUrl(newMovie.id, newMovie.title, movieData['releaseYear']);
    }
  }

  void updateMovie(String id, Map<String, dynamic> movieData) {
    final index = _movies.indexWhere((m) => m.id == id);
    if (index != -1) {
      final currentMovie = _movies[index];
      _movies[index] = Movie(
        id: id,
        title: movieData['title'] ?? currentMovie.title,
        overview: movieData['overview'] ?? currentMovie.overview,
        rating: currentMovie.rating,
        posterUrl: _posterCache[id],
        releaseYear: movieData['releaseYear'] ?? currentMovie.releaseYear,
        locationCount: currentMovie.locationCount,
        tourCount: currentMovie.tourCount,
        locationProgress: currentMovie.locationProgress,
      );
      notifyListeners();

      // Update poster if title or year changed
      if (movieData['title'] != null || movieData['releaseYear'] != null) {
        getPosterUrl(id, _movies[index].title, _movies[index].releaseYear);
      }
    }
  }

  void deleteMovie(String id) {
    _movies.removeWhere((movie) => movie.id == id);
    _posterCache.remove(id);
    notifyListeners();
  }
}
