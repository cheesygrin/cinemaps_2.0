import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/cinemaps_theme.dart';
import '../services/movies_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _showMovies = true;
  bool _showTVShows = true;
  // Default to New York City coordinates
  static const LatLng _defaultLocation = LatLng(40.7128, -74.0060);
  
  // Custom map style
  static const String _mapStyle = '''
[
  {
    "featureType": "all",
    "elementType": "all",
    "stylers": [
      {
        "saturation": -100
      }
    ]
  }
]
''';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMovieLocations();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print('Map controller created');
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        print('Attempting to apply map style...');
        print('Map style JSON: $_mapStyle');
        controller.setMapStyle(_mapStyle).then((_) {
          print('Map style applied successfully');
        }).catchError((e) {
          print('Error setting map style: $e');
          print('Stack trace: ${StackTrace.current}');
        });
      } catch (e) {
        print('Error in map style application: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    });
  }

  void _updateFilters() {
    setState(() {
      _loadMovieLocations();
    });
  }

  Future<void> _loadMovieLocations() async {
    if (!mounted) return;
    
    final moviesService = Provider.of<MoviesService>(context, listen: false);
    final movies = moviesService.getMovies();

    // Clear existing markers
    _markers.clear();

    // Sample locations for demonstration (replace with actual movie locations)
    final locations = {
      'ghostbusters': const LatLng(40.7197, -74.0066), // Hook & Ladder 8
      'raiders': const LatLng(40.7589, -73.9851), // Metropolitan Museum
      'big_1988': const LatLng(40.7636, -73.9731), // FAO Schwarz
      'dark_knight': const LatLng(40.7527, -73.9772), // Empire State Building
      'home_alone': const LatLng(40.7829, -73.9654), // Central Park
    };

    setState(() {
      for (var movie in movies) {
        // Only add markers based on filter settings
        if (locations.containsKey(movie.id)) {
          if ((movie.isMovie && _showMovies) || (!movie.isMovie && _showTVShows)) {
            _markers.add(
              Marker(
                markerId: MarkerId(movie.id),
                position: locations[movie.id]!,
                infoWindow: InfoWindow(
                  title: movie.title,
                  snippet: '${movie.locationCount} locations',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  movie.isMovie ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueAzure
                ),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: SafeArea(
        child: Column(
          children: [
            // App title with minimal padding
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Hero(
                    tag: 'map_page_title',
                    child: Text(
                      'Cinemaps',
                      style: TextStyle(
                        color: CinemapsTheme.neonYellow,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Movies'),
                    selected: _showMovies,
                    onSelected: (bool selected) {
                      setState(() {
                        _showMovies = selected;
                        _updateFilters();
                      });
                    },
                    selectedColor: CinemapsTheme.neonYellow.withOpacity(0.7),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: _showMovies ? Colors.black : Colors.white,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('TV Shows'),
                    selected: _showTVShows,
                    onSelected: (bool selected) {
                      setState(() {
                        _showTVShows = selected;
                        _updateFilters();
                      });
                    },
                    selectedColor: CinemapsTheme.neonYellow.withOpacity(0.7),
                    checkmarkColor: Colors.black,
                    labelStyle: TextStyle(
                      color: _showTVShows ? Colors.black : Colors.white,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ],
              ),
            ),
            // Map section
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: _defaultLocation,
                    zoom: 12,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  trafficEnabled: false,
                  buildingsEnabled: true,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: false,
                  tiltGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  liteModeEnabled: false,
                  compassEnabled: true,
                  padding: const EdgeInsets.all(0),
                ),
              ),
            ),
            // Movies section with template images
            Container(
              color: Colors.white.withOpacity(0.1),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.25,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                            final movies = moviesService.getMovies().where((movie) =>
                              (movie.isMovie && _showMovies) || (!movie.isMovie && _showTVShows)
                            ).toList();
                            
                            if (movies.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No movies or TV shows selected',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            }
                            
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
                                      final marker = _markers.firstWhere(
                                        (marker) => marker.markerId.value == movie.id,
                                        orElse: () => _markers.first,
                                      );
                                      _mapController?.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          marker.position,
                                          15,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 200,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade900,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.movie,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
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
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
