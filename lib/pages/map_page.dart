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

  Future<void> _loadMovieLocations() async {
    if (!mounted) return;
    
    final moviesService = Provider.of<MoviesService>(context, listen: false);
    final movies = moviesService.getMovies();

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
        if (locations.containsKey(movie.id)) {
          _markers.add(
            Marker(
              markerId: MarkerId(movie.id),
              position: locations[movie.id]!,
              infoWindow: InfoWindow(
                title: movie.title,
                snippet: '${movie.locationCount} locations',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            ),
          );
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
                    tag: 'app_title',
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
                                          image: movie.id == 'raiders'
                                              ? const DecorationImage(
                                                  image: AssetImage('assets/images/movies/raiders.jpg'),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: movie.id != 'raiders'
                                            ? const Icon(
                                                Icons.movie_outlined,
                                                color: Colors.white70,
                                                size: 20,
                                              )
                                            : null,
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
          ],
        ),
      ),
    );
  }
}
