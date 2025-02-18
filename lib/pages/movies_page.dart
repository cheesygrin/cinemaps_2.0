import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/cinemaps_theme.dart';
import '../services/movies_service.dart';
import '../services/auth_service.dart';
import '../models/movie.dart';
import '../models/recommendation.dart';
import '../widgets/recommendations_section.dart';
import 'movie_details_wrapper.dart';

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

  Future<void> _loadMovies() async {
    await _moviesService.loadMovies();
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
      appBar: AppBar(
        title: const Text('Movies'),
      ),
      body: Column(
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white.withOpacity(0.1),
                  child: ExpansionTile(
                    leading: movie.posterUrl.isEmpty
                        ? Container(
                            width: 40,
                            height: 60,
                            color: Colors.grey,
                            child: const Icon(Icons.movie, color: Colors.white),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              movie.posterUrl,
                              width: 40,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 40,
                                  height: 60,
                                  color: Colors.grey,
                                  child: const Icon(Icons.error, color: Colors.white),
                                );
                              },
                            ),
                          ),
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overview',
                              style: TextStyle(
                                color: CinemapsTheme.neonYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.overview,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CinemapsTheme.hotPink,
                                    padding: const EdgeInsets.all(16),
                                  ),
                                  icon: const Icon(Icons.map),
                                  label: const Text('View on Map'),
                                  onPressed: () {
                                    // TODO: Navigate to map view for this movie
                                  },
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CinemapsTheme.neonYellow,
                                    padding: const EdgeInsets.all(16),
                                  ),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('View Gallery'),
                                  onPressed: () {
                                    // TODO: Navigate to gallery view for this movie
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
