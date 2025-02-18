import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'photo_gallery_item.dart';
import 'review.dart';

class FilmingLocation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> scenes;
  final List<PhotoGalleryItem> photos;
  final bool isVerified;
  final int visitCount;
  final double rating;
  final List<Review> reviews;
  final int? season;  // Optional for TV shows
  final int? episode;  // Optional for TV shows

  FilmingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.scenes,
    this.photos = const [],
    this.isVerified = false,
    this.visitCount = 0,
    this.rating = 0.0,
    this.reviews = const [],
    this.season,
    this.episode,
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  factory FilmingLocation.fromJson(Map<String, dynamic> json) {
    return FilmingLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      scenes: List<String>.from(json['scenes'] as List),
      photos: List<PhotoGalleryItem>.from(
          (json['photos'] as List? ?? [])
              .map((e) => PhotoGalleryItem.fromJson(e as Map<String, dynamic>))
      ),
      isVerified: json['isVerified'] as bool? ?? false,
      visitCount: json['visitCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: List<Review>.from(
          (json['reviews'] as List? ?? [])
              .map((e) => Review.fromJson(e as Map<String, dynamic>))
      ),
      season: json['season'] as int?,
      episode: json['episode'] as int?,
    );
  }
}
