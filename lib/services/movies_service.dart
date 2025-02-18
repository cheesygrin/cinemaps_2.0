import 'package:flutter/foundation.dart';
import '../models/movie.dart';

class MoviesService extends ChangeNotifier {
  final List<Movie> _movies = [];
  String _searchQuery = '';
  bool _isInitialized = false;

  MoviesService() {
    loadMovies();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadMovies() async {
    if (_isInitialized) return;
    
    _movies.addAll([
      Movie(
        id: 'raiders',
        title: 'Raiders of the Lost Ark',
        overview: 'Archaeology professor Indiana Jones ventures to seize a biblical artefact known as the Ark of the Covenant. While doing so, he puts up a fight against Renee and a troop of Nazis.',
        rating: 4.9,
        posterUrl: 'https://image.tmdb.org/t/p/w500/ceG9VzoRAVGwivFU403Wc3AHRys.jpg',
      ),
      Movie(
        id: 'back_to_the_future',
        title: 'Back to the Future',
        overview: 'Marty McFly, a 17-year-old high school student, is accidentally sent thirty years into the past in a time-traveling DeLorean invented by his close friend, the eccentric scientist Doc Brown.',
        rating: 4.9,
        posterUrl: 'https://image.tmdb.org/t/p/w500/fNOH9f1aA7XRTzl1sAOx9iF553Q.jpg',
      ),
      Movie(
        id: 'ghostbusters',
        title: 'Ghostbusters',
        overview: 'After losing their academic posts at a prestigious university, a team of parapsychologists goes into business as proton-pack-toting "ghostbusters" who exterminate ghouls, hobgoblins and supernatural pests of all stripes.',
        rating: 4.8,
        posterUrl: 'https://image.tmdb.org/t/p/w500/7E3qVxNJ0O7A19AjKRU6jZQKGZC.jpg',
      ),
      Movie(
        id: 'goonies',
        title: 'The Goonies',
        overview: 'A group of young misfits called The Goonies discover an ancient map and set out on an adventure to find a legendary pirate\'s long-lost treasure.',
        rating: 4.8,
        posterUrl: 'https://image.tmdb.org/t/p/w500/eBU7gCjTCj9n2LTxvCSIXXOvHkD.jpg',
      ),
      Movie(
        id: 'big_1988',
        title: 'Big',
        overview: 'When a young boy makes a wish at a carnival machine to be big—he wakes up the following morning to find that it has been granted and his body has grown older overnight. But he is still the same 13-year-old boy inside. Now he must learn how to cope with the consequences of his wish.',
        rating: 4.8,
        posterUrl: 'https://image.tmdb.org/t/p/w500/eWWyUx0NyHxn8iIE3cmxH6NlHYh.jpg',
      ),
      Movie(
        id: 'breakfast_club',
        title: 'The Breakfast Club',
        overview: 'Five high school students meet in Saturday detention and discover how they have a lot more in common than they thought.',
        rating: 4.7,
        posterUrl: 'https://image.tmdb.org/t/p/w500/c0bdxKVRevkw50LRu4WTtqH9jvX.jpg',
      ),
      Movie(
        id: 'et',
        title: 'E.T. the Extra-Terrestrial',
        overview: 'A lonely boy befriends an extraterrestrial who is stranded on Earth and helps him find his way home.',
        rating: 4.8,
        posterUrl: 'https://image.tmdb.org/t/p/w500/an0nD6uq6byfxXCfk6lQBzdL2J1.jpg',
      ),
    ]);
    _isInitialized = true;
    notifyListeners();
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
      posterUrl: movieData['posterUrl'],
    );
    _movies.add(newMovie);
    notifyListeners();
  }

  void updateMovie(String id, Map<String, dynamic> movieData) {
    final index = _movies.indexWhere((m) => m.id == id);
    if (index != -1) {
      _movies[index] = Movie(
        id: id,
        title: movieData['title'],
        overview: movieData['overview'],
        rating: _movies[index].rating,
        posterUrl: movieData['posterUrl'],
      );
      notifyListeners();
    }
  }

  void deleteMovie(String id) {
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
  }
}
