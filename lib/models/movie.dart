import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cinemaps/services/supabase_service.dart';

class Location {
  final String name;
  final String address;
  final String description;
  final double latitude;
  final double longitude;

  Location({
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

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
  final List<Location>? locations;
  final bool isInWatchlist;
  final bool isMovie;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.rating,
    this.posterUrl,
    required this.releaseYear,
    required this.locationCount,
    required this.tourCount,
    required this.locationProgress,
    this.locations,
    this.isInWatchlist = false,
    this.isMovie = true,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      overview: json['overview'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      posterUrl: json['posterUrl'] as String?,
      releaseYear: json['releaseYear'] as int,
      locationCount: json['locationCount'] as int? ?? 0,
      tourCount: json['tourCount'] as int? ?? 0,
      locationProgress: (json['locationProgress'] as num?)?.toDouble() ?? 0.0,
      locations: json['locations'] != null
          ? (json['locations'] as List)
              .map((x) => Location.fromJson(x as Map<String, dynamic>))
              .toList()
          : null,
      isInWatchlist: json['isInWatchlist'] as bool? ?? false,
      isMovie: json['isMovie'] as bool? ?? true,
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
      'locations': locations?.map((x) => x.toJson()).toList(),
      'isInWatchlist': isInWatchlist,
      'isMovie': isMovie,
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
    List<Location>? locations,
    bool? isInWatchlist,
    bool? isMovie,
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
      locations: locations ?? this.locations,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isMovie: isMovie ?? this.isMovie,
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
