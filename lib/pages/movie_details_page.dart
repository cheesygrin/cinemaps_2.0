import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/cinemaps_theme.dart';
import '../theme/map_style.dart';
import '../services/movie_details_service.dart';
import '../services/route_planning_service.dart';
import 'package:geolocator/geolocator.dart';
import '../services/social_service.dart';
import '../services/watchlist_service.dart';
import '../models/watchlist_item.dart';
import '../widgets/photo_gallery.dart';
import '../widgets/review_card.dart';
import '../widgets/location_card.dart';
import '../widgets/tour_card.dart';
import '../widgets/comment_dialog.dart';
import '../widgets/photo_upload_dialog.dart';
import '../widgets/comment_list.dart';
import '../widgets/check_in_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MovieDetailsPage extends StatefulWidget {
  final String movieId;
  final String userId;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
    required this.userId,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage>
    with SingleTickerProviderStateMixin {
  late final MovieDetailsService _movieService;
  late final SocialService _socialService;
  late final WatchlistService _watchlistService;
  late TabController _tabController;
  MovieDetails? _movieDetails;
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isInWatchlist = false;
  Set<Marker> _locationMarkers = {};
  Set<Polyline> _routePolylines = {};
  bool _isRoutePlanning = false;
  OptimizedRoute? _currentRoute;
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapCompleter =
      Completer<GoogleMapController>();
  bool _isMapLoaded = false;

  @override
  void initState() {
    super.initState();
    _movieService = Provider.of<MovieDetailsService>(context, listen: false);
    _socialService = Provider.of<SocialService>(context, listen: false);
    _watchlistService = Provider.of<WatchlistService>(context, listen: false);
    _isInWatchlist =
        _watchlistService.isInWatchlist(widget.userId, widget.movieId);
    _tabController = TabController(length: 4, vsync: this);
    _loadMovieDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socialService.achievementService.setContext(context);
    });
  }

  Widget _buildSocialActions() {
    if (_movieDetails == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Like',
            color: _isLiked ? CinemapsTheme.hotPink : null,
            onTap: () {
              setState(() => _isLiked = !_isLiked);
              _socialService.addActivity(
                userId: widget.userId,
                type: UserActivityType.likedMovie,
                targetId: widget.movieId,
              );
            },
          ),
          _buildSocialButton(
            icon: Icons.share,
            label: 'Share',
            onTap: () {
              Share.share(
                'Check out ${_movieDetails!.title} on Cinemaps! Visit the filming locations and create your own movie tour!',
                subject: 'Movie recommendation from Cinemaps',
              );
              _socialService.addActivity(
                userId: widget.userId,
                type: UserActivityType.sharedMovie,
                targetId: widget.movieId,
              );
            },
          ),
          _buildSocialButton(
            icon: _isInWatchlist ? Icons.bookmark : Icons.bookmark_outline,
            label: _isInWatchlist ? 'In Watchlist' : 'Add to Watchlist',
            onTap: () async {
              if (_isInWatchlist) {
                await _watchlistService.removeFromWatchlist(
                    widget.userId, widget.movieId);
              } else {
                await _watchlistService.addToWatchlist(
                  userId: widget.userId,
                  mediaId: widget.movieId,
                  type: WatchlistItemType.movie,
                );
              }
              setState(() {
                _isInWatchlist = !_isInWatchlist;
              });
            },
            color: _isInWatchlist ? CinemapsTheme.hotPink : null,
          ),
          _buildSocialButton(
            icon: Icons.add_location,
            label: 'Check In',
            onTap: () => _showCheckInDialog(context),
          ),
          _buildSocialButton(
            icon: Icons.photo_camera,
            label: 'Photo',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => PhotoUploadDialog(
                  locationId: _movieDetails!.locationId,
                  userId: widget.userId,
                  onUpload: (image, caption, tags) async {
                    // TODO: Implement cloud storage
                    final photoUrl = image.path; // Temporary, use actual upload
                    await _socialService.uploadPhoto(
                      userId: widget.userId,
                      locationId: _movieDetails!.locationId,
                      photoUrl: photoUrl,
                      caption: caption,
                      tags: tags,
                    );
                  },
                ),
              );
            },
          ),
          _buildSocialButton(
            icon: Icons.comment,
            label: 'Comment',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: CinemapsTheme.deepSpaceBlack,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) => Column(
                    children: [
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: const Text('Comments'),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.add_comment),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => CommentDialog(
                                  targetId: widget.movieId,
                                  userId: widget.userId,
                                  onSubmit: (comment) async {
                                    await _socialService.addActivity(
                                      userId: widget.userId,
                                      type: UserActivityType.commentedMovie,
                                      targetId: widget.movieId,
                                      metadata: {'comment': comment},
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            CommentList(
                              comments: _movieDetails!.comments,
                              users: _socialService.getUsers(),
                              currentUserId: widget.userId,
                              onLike: (commentId) async {
                                final comment = _movieDetails!.comments
                                    .firstWhere((c) => c.id == commentId);
                                await _socialService.likeComment(
                                  widget.userId,
                                  comment,
                                );
                              },
                              onReply: (commentId) {
                                final comment = _movieDetails!.comments
                                    .firstWhere((c) => c.id == commentId);
                                showDialog(
                                  context: context,
                                  builder: (context) => CommentDialog(
                                    targetId: widget.movieId,
                                    userId: widget.userId,
                                    onSubmit: (content) async {
                                      await _socialService.replyToComment(
                                        widget.userId,
                                        comment,
                                        content,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color ?? Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showCheckInDialog(BuildContext context) async {
    if (_movieDetails == null) return;

    // Get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CheckInDialog(
        userId: widget.userId,
        locationId: _movieDetails!.locationId,
        movieId: widget.movieId,
        locationName: _movieDetails!.title,
        coordinates: LatLng(position.latitude, position.longitude),
      ),
    );

    if (result == true) {
      // Refresh the page to show updated check-in status
      _loadMovieDetails();
    }
  }

  Future<void> _loadMovieDetails() async {
    setState(() => _isLoading = true);
    try {
      final details = await _movieService.getMovieDetails(widget.movieId);
      setState(() {
        _movieDetails = details;
        _locationMarkers = details.filmingLocations
            .map((loc) => Marker(
                  markerId: MarkerId(loc.id),
                  position: LatLng(loc.latitude, loc.longitude),
                  infoWindow: InfoWindow(
                    title: loc.name,
                    snippet: loc.scenes.join(', '),
                  ),
                ))
            .toSet();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading movie details: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      floatingActionButton: _movieDetails != null ? FloatingActionButton(
        onPressed: () => _showAddReviewDialog(),
        backgroundColor: CinemapsTheme.hotPink,
        child: const Icon(Icons.rate_review),
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movieDetails == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load movie details',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMovieDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CinemapsTheme.hotPink,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildMovieInfo(),
                          const SizedBox(height: 16),
                          _buildSocialActions(),
                          const SizedBox(height: 16),
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white.withOpacity(0.5),
                            indicatorColor: CinemapsTheme.hotPink,
                            tabs: const [
                              Tab(text: 'LOCATIONS'),
                              Tab(text: 'TOURS'),
                              Tab(text: 'PHOTOS'),
                              Tab(text: 'REVIEWS'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLocationsTab(),
                          _buildToursTab(),
                          _buildPhotosTab(),
                          _buildReviewsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _movieDetails!.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_movieDetails!.backdropUrl != null)
              Image.network(
                _movieDetails!.backdropUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: Icon(
                        Icons.movie,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CinemapsTheme.hotPink,
                        ),
                      ),
                    ),
                  );
                },
              ),
            Container(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_movieDetails!.posterUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _movieDetails!.posterUrl!,
                width: 120,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black,
                    width: 120,
                    height: 180,
                    child: Center(
                      child: Icon(
                        Icons.movie,
                        size: 32,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.black,
                    width: 120,
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CinemapsTheme.hotPink,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_movieDetails!.releaseYear}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _movieDetails!.genres
                      .map((genre) => Chip(
                            label: Text(genre),
                            backgroundColor:
                                CinemapsTheme.hotPink.withOpacity(0.2),
                            labelStyle: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: CinemapsTheme.neonYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _movieDetails!.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${_movieDetails!.ratingCount})',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _movieDetails!.overview,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(
      String locationName, bool isVisited) async {
    return BitmapDescriptor.defaultMarkerWithHue(
      isVisited ? BitmapDescriptor.hueRose : BitmapDescriptor.hueViolet,
    );
  }

  Future<void> _planRoute() async {
    setState(() {
      _isRoutePlanning = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition();
      final startPoint = LatLng(position.latitude, position.longitude);

      final route = await RoutePlanningService().planRoute(
        _movieDetails!.filmingLocations,
        startPoint,
      );

      setState(() {
        _currentRoute = route;
        _routePolylines = route.segments.map((segment) {
          return Polyline(
            polylineId: PolylineId('${segment.start.id}_${segment.end.id}'),
            points: segment.polylinePoints,
            color: CinemapsTheme.hotPink,
            width: 3,
          );
        }).toSet();
      });

      if (_mapController != null) {
        final bounds = _getBoundsForLocations(
          [
            startPoint,
            ...route.orderedLocations
                .map((l) => LatLng(l.latitude, l.longitude))
          ],
        );
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50.0),
        );
      }
    } catch (e) {
      // Show error snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error planning route: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRoutePlanning = false;
      });
    }
  }

  void _clearRoute() {
    setState(() {
      _currentRoute = null;
      _routePolylines = {};
    });
  }

  LatLngBounds _getBoundsForLocations(List<LatLng> points) {
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

  Future<void> _updateMarkers() async {
    if (_movieDetails == null) return;

    final Set<Marker> markers = {};
    final List<LatLng> points = [];

    for (final location in _movieDetails!.filmingLocations) {
      final latLng = LatLng(location.latitude, location.longitude);
      points.add(latLng);

      final icon = await _createCustomMarkerIcon(
        location.name,
        location.visitCount > 0,
      );

      markers.add(Marker(
        markerId: MarkerId(location.id),
        position: latLng,
        icon: icon,
        infoWindow: InfoWindow(
          title: location.name,
          snippet: location.scenes.join(', '),
        ),
        onTap: () {
          _movieService.markLocationAsVisited(
            location.id,
            widget.userId,
          );
          _updateMarkers();
        },
      ));
    }

    setState(() {
      _locationMarkers = markers;
    });

    if (_mapController != null && points.isNotEmpty) {
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

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50.0),
      );
    }
  }

  Widget _buildLocationsTab() {
    return Column(
      children: [
        if (_currentRoute != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentRoute!.totalDurationMinutes} mins',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.straight,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentRoute!.totalDistanceKm.toStringAsFixed(1)} km',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 300,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _movieDetails!.filmingLocations.first.latitude,
                _movieDetails!.filmingLocations.first.longitude,
              ),
              zoom: 12,
            ),
            markers: _locationMarkers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            polylines: _routePolylines,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _movieDetails!.filmingLocations.length,
            itemBuilder: (context, index) {
              return LocationCard(
                location: _movieDetails!.filmingLocations[index],
                onVisited: () => _movieService.markLocationAsVisited(
                  _movieDetails!.filmingLocations[index].id,
                  widget.userId,
                ),
                showTitle: _movieDetails!.title,
                userId: widget.userId,
                username: 'User', // TODO: Get actual username from auth service
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToursTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movieDetails!.relatedTours.length,
      itemBuilder: (context, index) {
        return TourCard(
          tour: _movieDetails!.relatedTours[index],
          onStart: () => _movieService.startTour(
            _movieDetails!.relatedTours[index].id,
            widget.userId,
          ),
        );
      },
    );
  }

  Widget _buildPhotosTab() {
    return PhotoGallery(
      photos: _movieDetails!.photos,
      onLike: (photoId) => _movieService.likePhoto(photoId, widget.userId),
      onComment: (photoId, comment) => _movieService.addPhotoComment(
        photoId: photoId,
        userId: widget.userId,
        comment: comment,
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movieDetails!.reviews.length,
      itemBuilder: (context, index) {
        return ReviewCard(
          review: _movieDetails!.reviews[index],
          onLike: () => _movieService.likeReview(
            _movieDetails!.reviews[index].id,
            widget.userId,
          ),
          onComment: (comment) => _movieService.addReviewComment(
            reviewId: _movieDetails!.reviews[index].id,
            userId: widget.userId,
            content: comment,
          ),
        );
      },
    );
  }

  void _showAddReviewDialog() {
    double rating = 0;
    final reviewController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                backgroundColor: CinemapsTheme.deepSpaceBlack,
                title: const Text(
                  'Add Review',
                  style: TextStyle(color: Colors.white),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rating selector
                    const Text(
                      'Rate this movie',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starRating = (index + 1) * 1.0;
                        return IconButton(
                          onPressed: () {
                            setState(() => rating = starRating);
                          },
                          icon: Icon(
                            rating >= starRating
                                ? Icons.star
                                : Icons.star_border,
                            color: CinemapsTheme.neonYellow,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    // Review text field
                    TextField(
                      controller: reviewController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write your review...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: CinemapsTheme.hotPink.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: CinemapsTheme.hotPink.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: CinemapsTheme.hotPink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a rating'),
                            backgroundColor: CinemapsTheme.deepSpaceBlack,
                          ),
                        );
                        return;
                      }

                      if (reviewController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please write a review'),
                            backgroundColor: CinemapsTheme.deepSpaceBlack,
                          ),
                        );
                        return;
                      }

                      await _movieService.addReview(
                        movieId: widget.movieId,
                        userId: widget.userId,
                        rating: rating,
                        comment: reviewController.text.trim(),
                      );

                      // Refresh movie details to show the new review
                      await _loadMovieDetails();

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review submitted successfully'),
                            backgroundColor: CinemapsTheme.deepSpaceBlack,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CinemapsTheme.hotPink,
                    ),
                    child: const Text('SUBMIT'),
                  ),
                ],
              ),
            ));
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    setState(() => _isMapLoaded = true);
    
    // Center the map on the first location
    if (_movieDetails?.filmingLocations.isNotEmpty == true) {
      final firstLocation = _movieDetails!.filmingLocations.first;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(firstLocation.latitude, firstLocation.longitude),
          12.0,
        ),
      );
    }
  }
}
