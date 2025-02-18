import 'package:flutter/material.dart';

class Review {
  final String locationId;
  final String userId;
  final String text;
  final double rating;
  final DateTime timestamp;

  Review({
    required this.locationId,
    required this.userId,
    required this.text,
    required this.rating,
    required this.timestamp,
  });
}

class UserDataService extends ChangeNotifier {
  final Set<String> _favorites = {};
  final Map<String, List<Review>> _reviews = {};
  String? _currentUserId;

  String get currentUserId => _currentUserId ?? 'default_user';
  
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
  
  bool isFavorite(String locationId) => _favorites.contains(locationId);
  
  void toggleFavorite(String locationId) {
    if (_favorites.contains(locationId)) {
      _favorites.remove(locationId);
    } else {
      _favorites.add(locationId);
    }
    notifyListeners();
  }
  
  List<Review> getReviews(String locationId) => _reviews[locationId] ?? [];
  
  void addReview(Review review) {
    if (!_reviews.containsKey(review.locationId)) {
      _reviews[review.locationId] = [];
    }
    _reviews[review.locationId]!.add(review);
    notifyListeners();
  }
  
  double getAverageRating(String locationId) {
    final reviews = _reviews[locationId];
    if (reviews == null || reviews.isEmpty) return 0;
    
    final sum = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }
  
  List<String> getFavoriteLocations() => _favorites.toList();
}
