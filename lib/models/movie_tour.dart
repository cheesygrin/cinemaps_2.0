import 'filming_location.dart';
import 'review.dart';

class MovieTour {
  final String id;
  final String name;
  final String description;
  final List<FilmingLocation> locations;
  final Duration estimatedDuration;
  final double distance;
  final int completionCount;
  final double rating;
  final List<Review> reviews;
  final String createdBy;
  final DateTime timestamp;

  MovieTour({
    required this.id,
    required this.name,
    required this.description,
    required this.locations,
    required this.estimatedDuration,
    required this.distance,
    required this.completionCount,
    required this.rating,
    required this.reviews,
    required this.createdBy,
    required this.timestamp,
  });
}
