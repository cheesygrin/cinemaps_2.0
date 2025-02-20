import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class VisitedLocation {
  final String id;
  final String name;
  final LatLng coordinates;
  final double distance;
  final String category;
  final DateTime visitDate;

  VisitedLocation({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.distance,
    required this.category,
    required this.visitDate,
  });
}

class LocationReview {
  final String id;
  final String locationId;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final double rating;
  final String review;
  final DateTime visitDate;
  final DateTime timestamp;
  final List<String> photos;
  final int helpfulCount;

  LocationReview({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.rating,
    required this.review,
    required this.visitDate,
    required this.timestamp,
    required this.photos,
    this.helpfulCount = 0,
  });
}

class LocationReviewsService extends ChangeNotifier {
  // In a real app, this would be backed by a database
  final Map<String, List<LocationReview>> _reviews = {};
  final Map<String, List<VisitedLocation>> _visitedLocations = {};

  Future<List<dynamic>> getVisitedLocations(String userId) async {
    // Return empty list for now
    return [];
  }

  Future<void> addReview({
    required String locationId,
    required String userId,
    required String username,
    required String userPhotoUrl,
    required double rating,
    required String review,
    required DateTime visitDate,
    required List<String> photos,
  }) async {
    final newReview = LocationReview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      locationId: locationId,
      userId: userId,
      username: username,
      userPhotoUrl: userPhotoUrl,
      rating: rating,
      review: review,
      visitDate: visitDate,
      timestamp: DateTime.now(),
      photos: photos,
    );

    _reviews.update(
      locationId,
      (reviews) => [newReview, ...reviews],
      ifAbsent: () => [newReview],
    );
  }

  Future<List<LocationReview>> getLocationReviews(String locationId) async {
    return _reviews[locationId] ?? [];
  }

  Future<double> getAverageRating(String locationId) async {
    final reviews = _reviews[locationId] ?? [];
    if (reviews.isEmpty) return 0.0;
    
    final total = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  Future<void> markReviewHelpful(String reviewId, String userId) async {
    for (final reviews in _reviews.values) {
      final review = reviews.firstWhere(
        (r) => r.id == reviewId,
        orElse: () => throw Exception('Review not found'),
      );

      final updatedReview = LocationReview(
        id: review.id,
        locationId: review.locationId,
        userId: review.userId,
        username: review.username,
        userPhotoUrl: review.userPhotoUrl,
        rating: review.rating,
        review: review.review,
        visitDate: review.visitDate,
        timestamp: review.timestamp,
        photos: review.photos,
        helpfulCount: review.helpfulCount + 1,
      );

      final index = reviews.indexOf(review);
      reviews[index] = updatedReview;
    }
  }

  Future<List<LocationReview>> getMostHelpfulReviews(String locationId, {int limit = 3}) async {
    final reviews = _reviews[locationId] ?? [];
    final sortedReviews = List<LocationReview>.from(reviews);
    sortedReviews.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
    return sortedReviews.take(limit).toList();
  }

  Future<List<LocationReview>> getRecentReviews(String locationId, {int limit = 10}) async {
    final reviews = _reviews[locationId] ?? [];
    final sortedReviews = List<LocationReview>.from(reviews);
    sortedReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedReviews.take(limit).toList();
  }
}
