import 'package:google_maps_flutter/google_maps_flutter.dart';

class Movie {
  final String id;
  final String title;
  final String overview;
  final double rating;
  final String posterUrl;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.rating,
    required this.posterUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      overview: json['overview'] as String,
      rating: (json['rating'] as num).toDouble(),
      posterUrl: json['posterUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'rating': rating,
      'posterUrl': posterUrl,
    };
  }

  Movie copyWith({
    String? id,
    String? title,
    String? overview,
    double? rating,
    String? posterUrl,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      rating: rating ?? this.rating,
      posterUrl: posterUrl ?? this.posterUrl,
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
