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

  void loadMovies() {
    if (_isInitialized) return;
    
    const placeholderUrl = 'https://placehold.co/300x450/png?text=Placeholder';
    
    _movies.addAll([
      Movie(
        id: 'raiders',
        title: 'Raiders of the Lost Ark',
        overview: 'Archaeology professor Indiana Jones ventures to seize a biblical artefact known as the Ark of the Covenant. While doing so, he puts up a fight against Renee and a troop of Nazis.',
        rating: 4.9,
        posterUrl: placeholderUrl,
        releaseYear: 1981,
        locationCount: 12,
        tourCount: 2,
        locationProgress: 0.3,
      ),
      Movie(
        id: 'back_to_the_future',
        title: 'Back to the Future',
        overview: 'Marty McFly, a 17-year-old high school student, is accidentally sent thirty years into the past in a time-traveling DeLorean invented by his close friend, the eccentric scientist Doc Brown.',
        rating: 4.9,
        posterUrl: placeholderUrl,
        releaseYear: 1985,
        locationCount: 8,
        tourCount: 1,
        locationProgress: 0.5,
      ),
      Movie(
        id: 'ghostbusters',
        title: 'Ghostbusters',
        overview: 'After losing their academic posts at a prestigious university, a team of parapsychologists goes into business as proton-pack-toting "ghostbusters" who exterminate ghouls, hobgoblins and supernatural pests of all stripes.',
        rating: 4.8,
        posterUrl: placeholderUrl,
        releaseYear: 1984,
        locationCount: 15,
        tourCount: 3,
        locationProgress: 0.7,
      ),
      Movie(
        id: 'goonies',
        title: 'The Goonies',
        overview: 'A group of young misfits called The Goonies discover an ancient map and set out on an adventure to find a legendary pirate\'s long-lost treasure.',
        rating: 4.8,
        posterUrl: placeholderUrl,
        releaseYear: 1985,
        locationCount: 10,
        tourCount: 2,
        locationProgress: 0.6,
      ),
      Movie(
        id: 'big',
        title: 'Big',
        overview: 'When a young boy makes a wish at a carnival machine to be big—he wakes up the following morning to find that it has been granted and his body has grown older overnight. But he is still the same 13-year-old boy inside. Now he must learn how to cope with the consequences of his wish.',
        rating: 4.8,
        posterUrl: placeholderUrl,
        releaseYear: 1988,
        locationCount: 7,
        tourCount: 1,
        locationProgress: 0.3,
      ),
      Movie(
        id: 'breakfast_club',
        title: 'The Breakfast Club',
        overview: 'Five high school students meet in Saturday detention and discover how they have a lot more in common than they thought.',
        rating: 4.7,
        posterUrl: placeholderUrl,
        releaseYear: 1985,
        locationCount: 5,
        tourCount: 1,
        locationProgress: 0.2,
      ),
      Movie(
        id: 'et',
        title: 'E.T. the Extra-Terrestrial',
        overview: 'A lonely boy befriends an extraterrestrial who is stranded on Earth and helps him find his way home.',
        rating: 4.8,
        posterUrl: placeholderUrl,
        releaseYear: 1982,
        locationCount: 8,
        tourCount: 2,
        locationProgress: 0.4,
      ),
      Movie(
        id: 'dark_knight',
        title: 'The Dark Knight',
        overview: 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets.',
        rating: 4.9,
        posterUrl: placeholderUrl,
        releaseYear: 2008,
        locationCount: 20,
        tourCount: 4,
        locationProgress: 0.2,
      ),
      Movie(
        id: 'home_alone',
        title: 'Home Alone',
        overview: 'Eight-year-old Kevin McCallister makes the most of the situation after his family unwittingly leaves him behind when they go on Christmas vacation.',
        rating: 4.7,
        posterUrl: placeholderUrl,
        releaseYear: 1990,
        locationCount: 6,
        tourCount: 1,
        locationProgress: 0.4,
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
      releaseYear: movieData['releaseYear'] ?? 0,
      locationCount: 0,
      tourCount: 0,
      locationProgress: 0.0,
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
        releaseYear: movieData['releaseYear'] ?? _movies[index].releaseYear,
        locationCount: _movies[index].locationCount,
        tourCount: _movies[index].tourCount,
        locationProgress: _movies[index].locationProgress,
      );
      notifyListeners();
    }
  }

  void deleteMovie(String id) {
    _movies.removeWhere((movie) => movie.id == id);
    notifyListeners();
  }
}
