import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/cinemaps_theme.dart';
import '../services/movies_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../models/movie.dart';
import '../models/recommendation.dart';
import '../widgets/recommendations_section.dart';
import 'movie_details_page.dart';
import '../widgets/movie_card.dart';
import 'package:geocoding/geocoding.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  late MoviesService _moviesService;
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];

  @override
  void initState() {
    super.initState();
    _moviesService = Provider.of<MoviesService>(context, listen: false);
    _loadMovies();
  }

  void _loadMovies() {
    _moviesService.loadMovies();
    setState(() {
      _movies = _moviesService.getMovies();
    });
  }

  void _onSearchChanged(String query) {
    _moviesService.setSearchQuery(query);
    setState(() {
      _movies = _moviesService.getMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;
    
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecommendationsSection(
              userId: user?.uid ?? 'guest',
              filterType: RecommendationType.movie,
              limit: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: CinemapsTheme.neonYellow),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsPage(
                              movieId: movie.id,
                              userId: user?.uid ?? 'guest',
                            ),
                          ),
                        );
                      } catch (e) {
                        print('Error navigating to MovieDetailsPage: $e');
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_movie_fab',
        onPressed: () => _showAddMovieDialog(context),
        backgroundColor: CinemapsTheme.neonYellow,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<void> _showAddMovieDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final yearController = TextEditingController();
    final overviewController = TextEditingController();
    final locationNameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedImage;
    final storageService = StorageService();
    bool isUploading = false;
    final List<Map<String, dynamic>> locations = [];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: CinemapsTheme.deepSpaceBlack,
          title: const Text(
            'Add New Movie',
            style: TextStyle(color: CinemapsTheme.neonYellow),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Movie Details Section
                const Text(
                  'Movie Details',
                  style: TextStyle(
                    color: CinemapsTheme.neonYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                TextField(
                  controller: yearController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Release Year',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: overviewController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Overview',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        selectedImage = File(pickedFile.path);
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Select Poster'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CinemapsTheme.neonYellow,
                    foregroundColor: Colors.black,
                  ),
                ),
                if (selectedImage != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImage!,
                      height: 150,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],

                // Locations Section
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filming Locations',
                      style: TextStyle(
                        color: CinemapsTheme.neonYellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_location, color: CinemapsTheme.neonYellow),
                      onPressed: () async {
                        if (locationNameController.text.isNotEmpty && 
                            addressController.text.isNotEmpty) {
                          try {
                            final geocodedLocations = await locationFromAddress(addressController.text);
                            if (geocodedLocations.isNotEmpty) {
                              final geocodedLocation = geocodedLocations.first;
                              setState(() {
                                locations.add({
                                  'name': locationNameController.text,
                                  'address': addressController.text,
                                  'description': descriptionController.text,
                                  'latitude': geocodedLocation.latitude,
                                  'longitude': geocodedLocation.longitude,
                                });
                                locationNameController.clear();
                                addressController.clear();
                                descriptionController.clear();
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error finding location: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: locationNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                TextField(
                  controller: addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Location Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  maxLines: 2,
                ),
                
                // Added Locations List
                if (locations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...locations.map((loc) => ListTile(
                    title: Text(
                      loc['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      loc['address'],
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          locations.remove(loc);
                        });
                      },
                    ),
                  )).toList(),
                ],

                if (isUploading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(CinemapsTheme.neonYellow),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (titleController.text.isNotEmpty &&
                          overviewController.text.isNotEmpty &&
                          selectedImage != null) {
                        setState(() {
                          isUploading = true;
                        });

                        try {
                          final movieId = titleController.text.toLowerCase().replaceAll(' ', '_');
                          // Upload image to Firebase Storage
                          final posterUrl = await storageService.uploadMoviePoster(
                            selectedImage!,
                            movieId,
                          );

                          final movieData = {
                            'title': titleController.text,
                            'overview': overviewController.text,
                            'releaseYear': int.tryParse(yearController.text) ?? 0,
                            'posterUrl': posterUrl,
                            'locations': locations,
                          };

                          if (!context.mounted) return;
                          
                          final moviesService = Provider.of<MoviesService>(
                            context,
                            listen: false,
                          );
                          moviesService.addMovie(movieData);
                          Navigator.pop(context);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error uploading movie: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            isUploading = false;
                          });
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: CinemapsTheme.neonYellow,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(isUploading ? 'Uploading...' : 'Add Movie'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
