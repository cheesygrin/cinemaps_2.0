import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/cinemaps_theme.dart';
import '../services/tour_management_service.dart';
import '../models/tour.dart';
import 'tour_navigation_page.dart';

class TourDetailsPage extends StatefulWidget {
  final CustomTour tour;
  final String userId;

  const TourDetailsPage({
    super.key,
    required this.tour,
    required this.userId,
  });

  @override
  State<TourDetailsPage> createState() => _TourDetailsPageState();
}

class _TourDetailsPageState extends State<TourDetailsPage> {
  final TourManagementService _tourService = TourManagementService();
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;
  bool _isEditing = false;
  final bool _showMovieDetails = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMap() {
    // Create markers for each stop
    _markers = widget.tour.stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return Marker(
        markerId: MarkerId(stop.id),
        position: stop.location,
        infoWindow: InfoWindow(
          title: '${index + 1}. ${stop.name}',
          snippet: stop.movieTitle,
        ),
      );
    }).toSet();

    // Create polyline connecting all stops
    if (widget.tour.stops.length > 1) {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(widget.tour.id),
          points: widget.tour.stops.map((stop) => stop.location).toList(),
          color: CinemapsTheme.hotPink,
          width: 3,
        ),
      );
    }
  }

  Future<void> _rateTour(int rating) async {
    try {
      await _tourService.rateTour(widget.tour.id, rating.toDouble());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for rating!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rating tour: $e')),
        );
      }
    }
  }

  Future<void> _deleteTour() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text(
          'Delete Tour',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this tour?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: CinemapsTheme.hotPink),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _tourService.deleteTour(widget.tour.id);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting tour: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Stack(
              children: [
                FlexibleSpaceBar(
                  background: widget.tour.imageUrl != null
                      ? Image.network(
                          widget.tour.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                CinemapsTheme.hotPink.withOpacity(0.3),
                                CinemapsTheme.deepSpaceBlack,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.movie_filter,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      widget.tour.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (widget.tour.creatorId == widget.userId)
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                ),
              if (widget.tour.creatorId == widget.userId)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteTour,
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: CinemapsTheme.neonYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.tour.rating}/5',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ' (${widget.tour.ratingCount} ratings)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (widget.tour.creatorId != widget.userId)
                        Row(
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                Icons.star,
                                color: index < widget.tour.rating
                                    ? CinemapsTheme.neonYellow
                                    : Colors.white.withOpacity(0.3),
                              ),
                              onPressed: () => _rateTour(index + 1),
                            );
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.tour.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.timer,
                          title: 'Duration',
                          value: '${widget.tour.totalDuration} min',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.directions_walk,
                          title: 'Distance',
                          value:
                              '${widget.tour.totalDistance.toStringAsFixed(1)} km',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.location_on,
                          title: 'Stops',
                          value: widget.tour.stops.length.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.tour.stops.first.location,
                  zoom: 12,
                ),
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (widget.tour.stops.length > 1) {
                    final bounds = _calculateBounds(widget.tour.stops.map((stop) => stop.location).toList());
                    controller.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 50),
                    );
                  }
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final stop = widget.tour.stops[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.white.withOpacity(0.05),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: CinemapsTheme.hotPink,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      stop.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      stop.movieTitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${stop.estimatedDuration} min',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (stop.scenes.isNotEmpty) ...[
                              const Text(
                                'Featured Scenes:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...stop.scenes.map((scene) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.movie,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          scene,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: widget.tour.stops.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TourNavigationPage(
                tour: widget.tour,
                userId: widget.userId,
              ),
            ),
          );
        },
        backgroundColor: CinemapsTheme.hotPink,
        icon: const Icon(Icons.navigation),
        label: const Text('START TOUR'),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CinemapsTheme.hotPink.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: CinemapsTheme.hotPink),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
