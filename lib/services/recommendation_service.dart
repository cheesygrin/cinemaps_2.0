import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../services/watchlist_service.dart';
import '../services/social_service.dart';
import '../services/location_reviews_service.dart';
import '../models/movie.dart';

class RecommendationService extends ChangeNotifier {
  final WatchlistService _watchlistService;
  final SocialService _socialService;
  final LocationReviewsService _locationService;
  
  // Cache recommendations for performance
  final Map<String, List<Recommendation>> _userRecommendations = {};
  final Map<String, DateTime> _lastUpdateTime = {};
  
  // How often to refresh recommendations
  static const refreshInterval = Duration(hours: 1);

  RecommendationService({
    required WatchlistService watchlistService,
    required SocialService socialService,
    required LocationReviewsService locationService,
  }) : _watchlistService = watchlistService,
       _socialService = socialService,
       _locationService = locationService;

  Future<List<Recommendation>> getRecommendations(String userId) async {
    // Return default recommendations for now
    return [
      Recommendation(
        id: 'rec_default_1',
        targetId: 'raiders',
        type: RecommendationType.movie,
        reasons: [RecommendationReason.trending],
        score: 0.95,
        createdAt: DateTime.now(),
      ),
      Recommendation(
        id: 'rec_default_2',
        targetId: 'ghostbusters',
        type: RecommendationType.movie,
        reasons: [RecommendationReason.trending],
        score: 0.92,
        createdAt: DateTime.now(),
      ),
      Recommendation(
        id: 'rec_default_3',
        targetId: 'back_to_the_future',
        type: RecommendationType.movie,
        reasons: [RecommendationReason.trending],
        score: 0.90,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _generateRecommendations(String userId) async {
    List<Recommendation> recommendations = [];
    
    // Get user's watchlist and extract genre preferences
    final watchlist = _watchlistService.getWatchlist(userId);
    final Map<String, int> genrePreferences = {};
    
    for (var item in watchlist) {
      if (item.type == 'movie') {
        // Increment genre counts for each genre in the movie
        for (var genre in item.genres) {
          genrePreferences[genre] = (genrePreferences[genre] ?? 0) + 1;
        }
      }
    }

    // Sort genres by frequency to get top preferences
    final preferredGenres = genrePreferences.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    // 1. Recommend based on genre preferences
    if (preferredGenres.isNotEmpty) {
      final topGenre = preferredGenres.first.key;
      recommendations.addAll([
        if (topGenre == 'Adventure')
          Recommendation(
            id: 'rec_genre_1',
            targetId: 'raiders_lost_ark',
            type: RecommendationType.movie,
            reasons: [RecommendationReason.similarGenre],
            score: 0.95,
            createdAt: DateTime.now(),
            metadata: {'genre': topGenre},
          ),
        if (topGenre == 'Comedy')
          Recommendation(
            id: 'rec_genre_2',
            targetId: 'ghostbusters',
            type: RecommendationType.movie,
            reasons: [RecommendationReason.similarGenre],
            score: 0.92,
            createdAt: DateTime.now(),
            metadata: {'genre': topGenre},
          ),
        if (topGenre == 'Sci-Fi')
          Recommendation(
            id: 'rec_genre_3',
            targetId: 'back_to_future',
            type: RecommendationType.movie,
            reasons: [RecommendationReason.similarGenre],
            score: 0.90,
            createdAt: DateTime.now(),
            metadata: {'genre': topGenre},
          ),
      ]);
    }

    // 2. Recommend based on location visits
    final visitedLocations = await _locationService.getVisitedLocations(userId);
    for (var location in visitedLocations) {
      // Find movies filmed at nearby locations
      final nearbyMovies = await _findMoviesNearLocation(location);
      for (var movie in nearbyMovies) {
        recommendations.add(
          Recommendation(
            id: 'rec_location_${movie.id}',
            targetId: movie.id,
            type: RecommendationType.movie,
            reasons: [RecommendationReason.nearbyLocation],
            score: 0.85,
            createdAt: DateTime.now(),
            metadata: {
              'location': location.id,
              'distance': location.distance,
            },
          ),
        );
      }
    }

    // 3. Social recommendations (from friends' favorites)
    final friendsActivity = await _socialService.getFriendsActivity(userId);
    for (var activity in friendsActivity) {
      if (activity.type == 'favorite' && activity.mediaType == 'movie') {
        recommendations.add(
          Recommendation(
            id: 'rec_social_${activity.mediaId}',
            targetId: activity.mediaId,
            type: RecommendationType.movie,
            reasons: [RecommendationReason.friendLiked],
            score: 0.80,
            createdAt: DateTime.now(),
            metadata: {
              'friendId': activity.userId,
            },
          ),
        );
      }
    }

    // 4. Add default recommendations if no personalized ones are available
    if (recommendations.isEmpty) {
      recommendations.addAll([
        Recommendation(
          id: 'rec_default_1',
          targetId: 'raiders_lost_ark',
          type: RecommendationType.movie,
          reasons: [RecommendationReason.trending],
          score: 0.75,
          createdAt: DateTime.now(),
        ),
        Recommendation(
          id: 'rec_default_2',
          targetId: 'ghostbusters',
          type: RecommendationType.movie,
          reasons: [RecommendationReason.trending],
          score: 0.72,
          createdAt: DateTime.now(),
        ),
        Recommendation(
          id: 'rec_default_3',
          targetId: 'back_to_future',
          type: RecommendationType.movie,
          reasons: [RecommendationReason.trending],
          score: 0.70,
          createdAt: DateTime.now(),
        ),
      ]);
    }

    // Sort by score and remove duplicates
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    final uniqueRecommendations = <Recommendation>[];
    final seenIds = <String>{};
    
    for (var rec in recommendations) {
      if (!seenIds.contains(rec.targetId)) {
        uniqueRecommendations.add(rec);
        seenIds.add(rec.targetId);
      }
    }

    // Update cache
    _userRecommendations[userId] = uniqueRecommendations;
    _lastUpdateTime[userId] = DateTime.now();
    
    notifyListeners();
  }

  // Helper method to find movies near a location
  Future<List<Movie>> _findMoviesNearLocation(dynamic location) async {
    // TODO: Implement actual nearby movie search
    return [];
  }

  // Get recommendations by type
  Future<List<Recommendation>> getRecommendationsByType(
    String userId,
    RecommendationType type,
  ) async {
    final allRecommendations = await getRecommendations(userId);
    return allRecommendations.where((r) => r.type == type).toList();
  }

  // Get top N recommendations
  Future<List<Recommendation>> getTopRecommendations(
    String userId,
    {int limit = 5}
  ) async {
    final allRecommendations = await getRecommendations(userId);
    return allRecommendations.take(limit).toList();
  }

  // Force refresh recommendations
  Future<void> refreshRecommendations(String userId) async {
    await _generateRecommendations(userId);
  }
}
