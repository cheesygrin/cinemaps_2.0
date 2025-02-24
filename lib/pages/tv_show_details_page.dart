import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/cinemaps_theme.dart';
import '../theme/map_style.dart';
import '../models/filming_location.dart' as models;
import '../models/photo_gallery_item.dart';
import '../models/tv_show.dart';
import '../services/tv_shows_service.dart';
import '../widgets/photo_gallery.dart';
import '../services/movie_details_service.dart';
import '../services/location_sharing_service.dart';
import '../services/visit_tracking_service.dart';
import '../services/route_planning_service.dart';
import '../services/photo_upload_service.dart';
import '../services/location_reviews_service.dart';

class TVShowDetailsPage extends StatefulWidget {
  final String showId;
  final String userId;

  const TVShowDetailsPage({
    super.key,
    required this.showId,
    required this.userId,
  });

  @override
  State<TVShowDetailsPage> createState() => _TVShowDetailsPageState();
}

class _TVShowDetailsPageState extends State<TVShowDetailsPage>
    with SingleTickerProviderStateMixin {
  final TVShowsService _showsService = TVShowsService();
  final LocationSharingService _sharingService = LocationSharingService();
  final VisitTrackingService _visitService = VisitTrackingService();
  final RoutePlanningService _routeService = RoutePlanningService();
  final PhotoUploadService _photoService = PhotoUploadService();
  final LocationReviewsService _reviewService = LocationReviewsService();

  late TabController _tabController;
  TVShow? _show;
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  OptimizedRoute? _optimizedRoute;
  bool _showingRoute = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadShowDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadShowDetails() async {
    final show = _showsService.getShowById(widget.showId);
    setState(() {
      _show = show;
      if (show != null) {
        _updateMarkers();
      }
    });
  }

  void _updateMarkers() {
    if (_show == null) return;

    setState(() {
      _markers.clear();
      for (final location in _show!.filmingLocations) {
        _markers.add(
          Marker(
            markerId: MarkerId(location.id),
            position: location.coordinates,
            infoWindow: InfoWindow(
              title: location.name,
              snippet: location.description,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_show == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShowInfo(),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'LOCATIONS'),
                    Tab(text: 'PHOTOS'),
                  ],
                  labelColor: CinemapsTheme.neonPink,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: CinemapsTheme.neonPink,
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLocationsTab(),
                      _buildPhotosTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: CinemapsTheme.neonPink,
            size: 24,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Text(
            _show!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
        background: _show!.posterUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _show!.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.tv, size: 50),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[900],
                child: const Icon(Icons.tv, size: 50),
              ),
      ),
    );
  }

  Widget _buildShowInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_show!.startYear}${_show!.endYear != null ? ' - ${_show!.endYear}' : ''}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            _show!.description,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star, color: CinemapsTheme.neonYellow),
              const SizedBox(width: 8),
              Text(
                _show!.rating.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsTab() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _show!.filmingLocations.first.coordinates,
                  zoom: 12,
                ),
                markers: _markers,
                polylines: _showingRoute && _optimizedRoute != null
                    ? _optimizedRoute!.segments.map((segment) {
                        return Polyline(
                          polylineId: PolylineId(
                              '${segment.start.id}_${segment.end.id}'),
                          points: segment.polylinePoints,
                          color: CinemapsTheme.neonPink,
                          width: 3,
                        );
                      }).toSet()
                    : {},
                onMapCreated: (controller) {
                  _mapController = controller;
                  controller.setMapStyle(mapStyle.toString());

                  if (_show!.filmingLocations.length > 1) {
                    final bounds = _calculateBounds();
                    controller.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 50));
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'route',
                      backgroundColor:
                          _showingRoute ? CinemapsTheme.neonPink : Colors.white,
                      onPressed: () async {
                        if (!_showingRoute) {
                          final route = await _routeService.planRoute(
                            _show!.filmingLocations,
                            _show!.filmingLocations.first.coordinates,
                          );
                          setState(() {
                            _optimizedRoute = route;
                            _showingRoute = true;
                          });
                        } else {
                          setState(() {
                            _showingRoute = false;
                          });
                        }
                      },
                      child: Icon(
                        Icons.route,
                        color: _showingRoute
                            ? Colors.white
                            : CinemapsTheme.neonPink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'share',
                      backgroundColor: Colors.white,
                      onPressed: () {
                        _sharingService.shareRoute(
                            _show!.filmingLocations, _show!.title);
                      },
                      child: const Icon(Icons.share,
                          color: CinemapsTheme.neonPink),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _show!.filmingLocations.length,
            itemBuilder: (context, index) {
              final location = _show!.filmingLocations[index];
              return FutureBuilder<VisitStats>(
                future: _visitService.getLocationStats(location.id),
                builder: (context, snapshot) {
                  final stats = snapshot.data;
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white.withOpacity(0.1),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            location.name,
                            style:
                                const TextStyle(color: CinemapsTheme.neonPink),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.address,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Season ${location.season}, Episode ${location.episode}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                              if (stats != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.people,
                                        size: 16, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${stats.totalVisits} visits',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo_camera,
                                    color: CinemapsTheme.neonYellow),
                                onPressed: () async {
                                  final photo = await _photoService.pickImage(
                                      fromCamera: true);
                                  if (photo != null) {
                                    // Show upload dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Upload Photo'),
                                        content: TextField(
                                          decoration: InputDecoration(
                                            hintText: 'Add a caption...',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // TODO: Handle photo upload
                                              Navigator.pop(context);
                                            },
                                            child: Text('Upload'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share,
                                    color: CinemapsTheme.neonYellow),
                                onPressed: () {
                                  _sharingService.shareLocation(
                                      location, _show!.title);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.directions,
                                    color: CinemapsTheme.neonYellow),
                                onPressed: () {
                                  _mapController?.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                        location.coordinates, 16),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<List<LocationReview>>(
                          future: _reviewService
                              .getMostHelpfulReviews(location.id, limit: 1),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return SizedBox.shrink();
                            }
                            final review = snapshot.data!.first;
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(review.userPhotoUrl),
                                        radius: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        review.username,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (index) => Icon(
                                            index < review.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: CinemapsTheme.neonYellow,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review.review,
                                    style: TextStyle(color: Colors.white70),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosTab() {
    final photos = _show!.filmingLocations
        .map((models.FilmingLocation location) => PhotoGalleryItem(
              id: location.id,
              url: 'https://picsum.photos/seed/${location.id}/800/600',
              userId: 'system',
              username: 'Cinemaps',
              locationId: location.id,
              caption: '${location.name} - ${location.description}',
              timestamp: DateTime.now(),
              likeCount: 0,
              comments: [],
              tags: [
                'tv_show',
                _show!.title.toLowerCase().replaceAll(' ', '_')
              ],
            ))
        .toList();

    return PhotoGallery(
      photos: photos,
      onLike: (photoId) async {
        // TODO: Implement like functionality
      },
      onComment: (photoId, comment) async {
        // TODO: Implement comment functionality
      },
    );
  }

  LatLngBounds _calculateBounds() {
    double? minLat, maxLat, minLng, maxLng;

    for (final location in _show!.filmingLocations) {
      final lat = location.latitude;
      final lng = location.longitude;

      minLat = minLat != null ? math.min(minLat, lat) : lat;
      maxLat = maxLat != null ? math.max(maxLat, lat) : lat;
      minLng = minLng != null ? math.min(minLng, lng) : lng;
      maxLng = maxLng != null ? math.max(maxLng, lng) : lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}
