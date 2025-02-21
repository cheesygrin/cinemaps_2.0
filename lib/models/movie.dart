import 'package:google_maps_flutter/google_maps_flutter.dart';

class Movie {
  final String id;
  final String title;
  final String overview;
  final double rating;
  final String? posterUrl;
  final int releaseYear;
  final int locationCount;
  final int tourCount;
  final double locationProgress;
  final bool isInWatchlist;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.rating,
    this.posterUrl,
    this.releaseYear = 0,
    this.locationCount = 0,
    this.tourCount = 0,
    this.locationProgress = 0.0,
    this.isInWatchlist = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      overview: json['overview'] as String,
      rating: (json['rating'] as num).toDouble(),
      posterUrl: json['posterUrl'] as String?,
      releaseYear: json['releaseYear'] as int? ?? 0,
      locationCount: json['locationCount'] as int? ?? 0,
      tourCount: json['tourCount'] as int? ?? 0,
      locationProgress: (json['locationProgress'] as num?)?.toDouble() ?? 0.0,
      isInWatchlist: json['isInWatchlist'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'rating': rating,
      'posterUrl': posterUrl,
      'releaseYear': releaseYear,
      'locationCount': locationCount,
      'tourCount': tourCount,
      'locationProgress': locationProgress,
      'isInWatchlist': isInWatchlist,
    };
  }

  Movie copyWith({
    String? id,
    String? title,
    String? overview,
    double? rating,
    String? posterUrl,
    int? releaseYear,
    int? locationCount,
    int? tourCount,
    double? locationProgress,
    bool? isInWatchlist,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      rating: rating ?? this.rating,
      posterUrl: posterUrl ?? this.posterUrl,
      releaseYear: releaseYear ?? this.releaseYear,
      locationCount: locationCount ?? this.locationCount,
      tourCount: tourCount ?? this.tourCount,
      locationProgress: locationProgress ?? this.locationProgress,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
    );
  }
}

class MovieLocation {
  final String id;
  final String name;
  final String address;
  final LatLng coordinates;
  final String description;
  final List<String> scenes;
  final List<String> photos;
  final double rating;
  final bool isVerified;
  final int visitCount;
  final List<String> reviews;

  MovieLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.description,
    required this.scenes,
    required this.photos,
    required this.rating,
    required this.isVerified,
    required this.visitCount,
    required this.reviews,
  });
}
