enum RecommendationType {
  movie,
  tvShow,
  location,
  tour,
}

enum RecommendationReason {
  trending,
  similarToWatched, // Similar to content user has watched
  nearbyLocation, // Near locations user has visited
  similarGenre,
  friendLiked, // Liked by user's friends
  popularInArea, // Popular in user's current area
  newRelease, // New release in user's interests
  continueSeries, // Next in a series user is watching
}

class Recommendation {
  final String id;
  final String targetId; // ID of the recommended item (movie, location, etc.)
  final RecommendationType type;
  final List<RecommendationReason> reasons;
  final double score; // Recommendation score (0-1)
  final DateTime createdAt;
  final Map<String, dynamic> metadata; // Additional context

  const Recommendation({
    required this.id,
    required this.targetId,
    required this.type,
    required this.reasons,
    required this.score,
    required this.createdAt,
    this.metadata = const {},
  });

  String getReasonText() {
    if (reasons.isEmpty) return '';

    switch (reasons.first) {
      case RecommendationReason.similarToWatched:
        return 'Similar to content you\'ve watched';
      case RecommendationReason.nearbyLocation:
        return 'Near places you\'ve visited';
      case RecommendationReason.popularInArea:
        return 'Popular in your area';
      case RecommendationReason.friendLiked:
        return 'Liked by friends';
      case RecommendationReason.trending:
        return 'Trending now';
      case RecommendationReason.newRelease:
        return 'New release';
      case RecommendationReason.continueSeries:
        return 'Continue watching';
      default:
        return '';
    }
  }
}
