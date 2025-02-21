import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TMDbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  
  static String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  static Future<String> getMoviePoster(String title, int year) async {
    if (_apiKey.isEmpty) {
      print('Warning: TMDB_API_KEY not found in environment variables');
      return _getBackupPosterUrl(title);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(title)}&year=$year'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        if (results.isNotEmpty) {
          final posterPath = results[0]['poster_path'];
          if (posterPath != null && posterPath.isNotEmpty) {
            return '$_imageBaseUrl$posterPath';
          }
        }
      }
      return _getBackupPosterUrl(title);
    } catch (e) {
      print('Error fetching movie poster: $e');
      return _getBackupPosterUrl(title);
    }
  }

  static String _getBackupPosterUrl(String title) {
    // Use Picsum for unique placeholder images based on the movie title's hash
    final hash = title.hashCode.abs() % 1000; // Get a number between 0-999
    return 'https://picsum.photos/seed/$hash/300/450';
  }

  static Future<Map<String, dynamic>?> getMovieDetails(String movieTitle, int releaseYear) async {
    if (_apiKey.isEmpty) {
      print('Warning: TMDB_API_KEY not found in environment variables');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(movieTitle)}&year=$releaseYear'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results[0];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching movie details: $e');
      return null;
    }
  }
} 