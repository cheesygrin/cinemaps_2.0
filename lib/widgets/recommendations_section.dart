import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recommendation.dart';
import '../services/recommendation_service.dart';
import '../theme/cinemaps_theme.dart';
import '../services/movies_service.dart';
import '../services/auth_service.dart';
import '../pages/movie_details_page.dart';

class RecommendationsSection extends StatelessWidget {
  final String userId;
  final RecommendationType? filterType;
  final int limit;

  const RecommendationsSection({
    super.key,
    required this.userId,
    this.filterType,
    this.limit = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationService>(
      builder: (context, recommendationService, child) {
        return FutureBuilder<List<Recommendation>>(
          future: filterType != null
              ? recommendationService.getRecommendationsByType(userId, filterType!)
              : recommendationService.getTopRecommendations(userId, limit: limit),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: CinemapsTheme.hotPink,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading recommendations',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 16,
                  ),
                ),
              );
            }

            final recommendations = snapshot.data ?? [];
            
            if (recommendations.isEmpty) {
              return const Center(
                child: Text(
                  'No recommendations available',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recommended for You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: CinemapsTheme.hotPink,
                        ),
                        onPressed: () {
                          recommendationService.refreshRecommendations(userId);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      return _RecommendationCard(
                        recommendation: recommendations[index],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const _RecommendationCard({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final moviesService = Provider.of<MoviesService>(context);
    final movie = moviesService.getMovieById(recommendation.targetId);
    
    if (movie == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsPage(
              movieId: movie.id,
              userId: Provider.of<AuthService>(context, listen: false).currentUser?.uid ?? 'guest',
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white.withOpacity(0.1),
        margin: const EdgeInsets.all(8.0),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getIcon(),
                color: CinemapsTheme.hotPink,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                recommendation.getReasonText(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(recommendation.score * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (recommendation.type) {
      case RecommendationType.movie:
        return Icons.movie_outlined;
      case RecommendationType.tvShow:
        return Icons.tv_outlined;
      case RecommendationType.location:
        return Icons.place_outlined;
      case RecommendationType.tour:
        return Icons.map_outlined;
    }
  }
}
