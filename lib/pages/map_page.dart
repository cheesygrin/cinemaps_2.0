import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/cinemaps_theme.dart';
import '../services/movies_service.dart';
import '../models/movie.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  // Default to New York City coordinates
  static const LatLng _defaultLocation = LatLng(40.7128, -74.0060);
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovieLocations();
    });
  }

  Future<void> _loadMovieLocations() async {
    if (!mounted) return;
    
    final moviesService = Provider.of<MoviesService>(context, listen: false);
    final movies = moviesService.getMovies();

    // Sample locations for demonstration (replace with actual movie locations)
    final locations = {
      'ghostbusters': const LatLng(40.7197, -74.0066), // Hook & Ladder 8
      'raiders': const LatLng(40.7589, -73.9851), // Metropolitan Museum
      'big_1988': const LatLng(40.7636, -73.9731), // FAO Schwarz
    };

    setState(() {
      for (var movie in movies) {
        if (locations.containsKey(movie.id)) {
          _markers.add(
            Marker(
              markerId: MarkerId(movie.id),
              position: locations[movie.id]!,
              infoWindow: InfoWindow(
                title: movie.title,
                snippet: 'Rating: ${movie.rating}',
              ),
              onTap: () {
                _showMoviePreview(movie);
              },
            ),
          );
        }
      }
    });

    // Center map on New York if markers exist
    if (_markers.isNotEmpty && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_defaultLocation, 12),
      );
    }
  }

  void _showMoviePreview(Movie movie) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: CinemapsTheme.deepSpaceBlack.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: _MoviePoster(posterUrl: movie.posterUrl),
              title: Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Rating: ${movie.rating}',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                movie.overview,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Movie Locations'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
                _loadMovieLocations();
              },
              initialCameraPosition: const CameraPosition(
                target: _defaultLocation,
                zoom: 12.0,
              ),
              markers: _markers,
              mapType: MapType.normal,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Movies',
                  style: TextStyle(
                    color: CinemapsTheme.neonYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: Consumer<MoviesService>(
                    builder: (context, moviesService, child) {
                      final movies = moviesService.getMovies();
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return Card(
                            margin: const EdgeInsets.only(right: 16),
                            color: Colors.white.withOpacity(0.1),
                            child: InkWell(
                              onTap: () {
                                final location = _markers.firstWhere(
                                  (marker) => marker.markerId.value == movie.id,
                                  orElse: () => _markers.first,
                                );
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    location.position,
                                    15,
                                  ),
                                );
                                _showMoviePreview(movie);
                              },
                              child: SizedBox(
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      _MoviePoster(posterUrl: movie.posterUrl),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              movie.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Rating: ${movie.rating}',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  final String posterUrl;
  const _MoviePoster({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        posterUrl,
        width: 40,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 40,
            height: 60,
            color: Colors.grey.shade800,
            child: const Icon(Icons.movie_outlined, color: Colors.white70),
          );
        },
      ),
    );
  }
}
