import '../models/filming_location.dart';

class TVShow {
  final String id;
  final String title;
  final String posterUrl;
  final double rating;
  final String overview;
  final List<String> genres;
  final int startYear;
  final int? endYear;
  final String description;
  final List<FilmingLocation> filmingLocations;
  final bool isWatchlisted;

  TVShow({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.overview,
    required this.genres,
    required this.startYear,
    this.endYear,
    required this.description,
    List<FilmingLocation>? filmingLocations,
    bool? isWatchlisted,
  })  : filmingLocations = filmingLocations ?? [],
        isWatchlisted = isWatchlisted ?? false;

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['posterUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      overview: json['overview'] as String,
      genres: List<String>.from(json['genres'] as List),
      startYear: json['startYear'] as int,
      endYear: json['endYear'] as int?,
      description: json['description'] as String,
      filmingLocations: (json['filmingLocations'] as List? ?? [])
          .map((e) => FilmingLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
      isWatchlisted: json['isWatchlisted'] as bool? ?? false,
    );
  }
}
