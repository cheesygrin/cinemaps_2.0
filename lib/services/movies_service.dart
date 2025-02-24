import 'package:flutter/foundation.dart';
import 'package:cinemaps/models/movie.dart';
import 'package:cinemaps/services/supabase_service.dart';
import 'package:cinemaps/services/tmdb_service.dart';

class MoviesService extends ChangeNotifier {
  final SupabaseService _supabase;
  List<Movie> _movies = [];
  String _searchQuery = '';
  bool _isLoading = false;
  final Map<String, String?> _posterCache = {};

  MoviesService(this._supabase) {
    loadMovies();
  }

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;

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
      debugPrint('Error loading poster for $title: $e');
      return null;
    }
  }

  Future<void> loadMovies() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.client
          .from('movies')
          .select('*, movie_locations(*)')
          .order('title');

      _movies = response.map<Movie>((data) {
        final movieData = Map<String, dynamic>.from(data);
        if (data['movie_locations'] != null) {
          movieData['locations'] = data['movie_locations'];
        }
        return Movie.fromJson(movieData);
      }).toList();

      // Load missing posters
      for (final movie in _movies) {
        if (movie.posterUrl == null) {
          await _getPosterUrl(movie);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading movies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getPosterUrl(Movie movie) async {
    if (_posterCache.containsKey(movie.id)) {
      return;
    }

    try {
      final posterUrl = await TMDbService.getMoviePoster(
        movie.title,
        movie.releaseYear,
      );

      if (posterUrl != null) {
        _posterCache[movie.id] = posterUrl;
        await updateMovie(movie.copyWith(posterUrl: posterUrl));
      }
    } catch (e) {
      debugPrint('Error getting poster for ${movie.title}: $e');
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

  Future<void> addMovie(Movie movie) async {
    try {
      // Prepare movie data for Supabase
      final movieData = movie.toJson();
      movieData.remove('locations'); // Remove locations to insert separately

      // Insert movie into Supabase
      final response = await _supabase.client
          .from('movies')
          .insert(movieData)
          .select()
          .single();

      if (movie.locations != null && movie.locations!.isNotEmpty) {
        // Prepare location data for Supabase
        final locationData = movie.locations!.map((location) => {
          ...location.toJson(),
          'movie_id': movie.id,
        }).toList();

        // Insert locations into Supabase
        await _supabase.client
            .from('movie_locations')
            .insert(locationData);
      }

      // Try to get poster
      await _getPosterUrl(movie);

      // Add movie to local cache
      _movies.add(movie);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding movie: $e');
      rethrow;
    }
  }

  Future<void> updateMovie(Movie movie) async {
    try {
      // Update movie in Supabase
      await _supabase.client
          .from('movies')
          .update(movie.toJson()..remove('locations'))
          .eq('id', movie.id);

      // Update locations if they exist
      if (movie.locations != null) {
        // Delete existing locations
        await _supabase.client
            .from('movie_locations')
            .delete()
            .eq('movie_id', movie.id);

        // Insert new locations
        if (movie.locations!.isNotEmpty) {
          final locationData = movie.locations!.map((location) => {
            ...location.toJson(),
            'movie_id': movie.id,
          }).toList();

          await _supabase.client
              .from('movie_locations')
              .insert(locationData);
        }
      }

      // Update local cache
      final index = _movies.indexWhere((m) => m.id == movie.id);
      if (index != -1) {
        _movies[index] = movie;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating movie: $e');
      rethrow;
    }
  }

  Future<void> deleteMovie(String movieId) async {
    try {
      // Delete movie from Supabase (cascade will handle locations)
      await _supabase.client
          .from('movies')
          .delete()
          .eq('id', movieId);

      // Remove from local cache
      _movies.removeWhere((movie) => movie.id == movieId);
      _posterCache.remove(movieId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting movie: $e');
      rethrow;
    }
  }

  Future<void> addSampleMovies() async {
    final sampleMovies = [
      {
        'title': 'Raiders of the Lost Ark',
        'overview': 'Archaeologist and adventurer Indiana Jones is hired by the U.S. government to find the Ark of the Covenant before the Nazis.',
        'releaseYear': 1981,
        'locations': [
          {
            'name': 'Kauai, Hawaii',
            'address': 'Kauai, HI 96746, USA',
            'description': 'Opening sequence jungle scenes',
            'latitude': 22.0964,
            'longitude': -159.5261
          }
        ],
        'isInWatchlist': false,
        'isMovie': true
      },
      {
        'title': 'Back to the Future',
        'overview': 'Marty McFly, a 17-year-old high school student, is accidentally sent thirty years into the past in a time-traveling DeLorean invented by his close friend, the eccentric scientist Doc Brown.',
        'releaseYear': 1985,
        'locations': [
          {
            'name': 'Universal Studios Backlot',
            'address': '100 Universal City Plaza, Universal City, CA 91608',
            'description': 'Hill Valley town square scenes',
            'latitude': 34.1381,
            'longitude': -118.3534
          }
        ],
        'isInWatchlist': false,
        'isMovie': true
      },
      {
        'title': 'Jurassic Park',
        'overview': 'During a preview tour, a theme park suffers a major power breakdown that allows its cloned dinosaur exhibits to run amok.',
        'releaseYear': 1993,
        'locations': [
          {
            'name': 'Kualoa Ranch',
            'address': '49-560 Kamehameha Hwy, Kaneohe, HI 96744',
            'description': 'Gallimimus stampede scene',
            'latitude': 21.5217,
            'longitude': -157.8374
          }
        ],
        'isInWatchlist': false,
        'isMovie': true
      }
    ];

    for (final movieData in sampleMovies) {
      try {
        final String title = movieData['title'] as String;
        final String id = title.toLowerCase().replaceAll(' ', '_');
        final List<Map<String, dynamic>> locationsList = 
            (movieData['locations'] as List).cast<Map<String, dynamic>>();
        
        final movie = Movie.fromJson({
          'id': id,
          'title': title,
          'overview': movieData['overview'] as String,
          'rating': 0.0,
          'posterUrl': null,
          'releaseYear': movieData['releaseYear'] as int,
          'locationCount': locationsList.length,
          'tourCount': 0,
          'locationProgress': 0.0,
          'locations': locationsList,
          'isInWatchlist': movieData['isInWatchlist'] as bool,
          'isMovie': movieData['isMovie'] as bool
        });
        
        await addMovie(movie);
      } catch (e) {
        debugPrint('Error adding sample movie ${movieData['title']}: $e');
      }
    }
  }
}
