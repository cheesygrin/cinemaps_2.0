import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/cinemaps_theme.dart';
import '../models/movie_tour.dart';
import '../services/social_service.dart';
import '../services/user_data_service.dart';
import 'package:intl/intl.dart';

class TourCard extends StatelessWidget {
  final MovieTour tour;
  final VoidCallback onStart;
  final VoidCallback? onShare;

  const TourCard({
    super.key,
    required this.tour,
    required this.onStart,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: CinemapsTheme.hotPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created by ${tour.createdBy} on ${DateFormat.yMMMd().format(tour.timestamp)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CinemapsTheme.hotPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: CinemapsTheme.neonYellow,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tour.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.timer,
                  label: _formatDuration(tour.estimatedDuration),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.place,
                  label: '${tour.locations.length} stops',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.share,
                    color: CinemapsTheme.neonYellow,
                  ),
                  onPressed: () async {
                    if (onShare != null) {
                      onShare!();
                    } else {
                      final userId = Provider.of<UserDataService>(
                        context,
                        listen: false,
                      ).currentUserId;
                      
                      await Provider.of<SocialService>(
                        context,
                        listen: false,
                      ).shareTour(userId, tour.id);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tour shared successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
                _buildInfoChip(
                  icon: Icons.directions_walk,
                  label: '${tour.distance.toStringAsFixed(1)} km',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.location_on,
                  label: '${tour.locations.length} stops',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.people,
                  label: '${tour.completionCount} completed',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Locations:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tour.locations.length,
              itemBuilder: (context, index) {
                final location = tour.locations[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: CinemapsTheme.hotPink.withOpacity(0.2),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    location.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    location.address,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CinemapsTheme.hotPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'START TOUR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
