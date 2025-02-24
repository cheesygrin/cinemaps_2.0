import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tour_tracking.dart';
import '../services/tour_tracking_service.dart';
import '../theme/cinemaps_theme.dart';

class TourTrackingWidget extends StatelessWidget {
  final String tourId;
  final String userId;

  const TourTrackingWidget({
    super.key,
    required this.tourId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TourTrackingService>(
      builder: (context, trackingService, child) {
        final tour = trackingService.getActiveTour(tourId);

        if (tour == null) {
          return const Center(
            child: Text(
              'Tour not found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          children: [
            _buildProgressBar(tour),
            _buildCurrentStop(tour),
            if (tour.status == TourStatus.inProgress)
              _buildControlButtons(context, trackingService, tour),
            _buildStopsList(tour),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar(ActiveTour tour) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tour Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tour.completionPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: CinemapsTheme.hotPink,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: tour.completionPercentage / 100,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(
              CinemapsTheme.hotPink,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time Remaining: ${_formatDuration(tour.remainingTime)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${tour.stops.where((stop) => stop.isVisited).length}/${tour.stops.length} Stops',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStop(ActiveTour tour) {
    final currentStop = tour.currentStop;
    if (currentStop == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Stop',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentStop.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentStop.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: currentStop.scenes.map((scene) {
              return Chip(
                backgroundColor: CinemapsTheme.hotPink.withOpacity(0.2),
                label: Text(
                  scene,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(
    BuildContext context,
    TourTrackingService trackingService,
    ActiveTour tour,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (tour.status == TourStatus.inProgress)
            ElevatedButton.icon(
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
              onPressed: () => trackingService.pauseTour(tourId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            )
          else if (tour.status == TourStatus.paused)
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
              onPressed: () => trackingService.resumeTour(tourId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ElevatedButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel Tour'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: CinemapsTheme.deepSpaceBlack,
                  title: const Text(
                    'Cancel Tour?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to cancel this tour? Your progress will be saved but the tour will be marked as incomplete.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await trackingService.cancelTour(tourId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsList(ActiveTour tour) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tour.stops.length,
        itemBuilder: (context, index) {
          final stop = tour.stops[index];
          final isCurrentStop = index == tour.currentStopIndex;
          final isCompleted = stop.isVisited;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isCurrentStop
                  ? CinemapsTheme.hotPink.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: isCurrentStop
                  ? Border.all(color: CinemapsTheme.hotPink)
                  : null,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCompleted ? Colors.green : Colors.white24,
                child: Icon(
                  isCompleted ? Icons.check : Icons.location_on,
                  color: Colors.white,
                ),
              ),
              title: Text(
                stop.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isCurrentStop ? FontWeight.bold : null,
                ),
              ),
              subtitle: Text(
                isCompleted
                    ? 'Visited ${_formatTimeAgo(stop.visitedAt!)}'
                    : 'Estimated: ${_formatDuration(stop.estimatedDuration)}',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              trailing: stop.isOptional
                  ? const Chip(
                      backgroundColor: Colors.orange,
                      label: Text(
                        'Optional',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
