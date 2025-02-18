import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/cinemaps_theme.dart';
import '../services/movies_service.dart';
import '../models/movie.dart';

class AdminMoviesPage extends StatefulWidget {
  const AdminMoviesPage({super.key});

  @override
  State<AdminMoviesPage> createState() => _AdminMoviesPageState();
}

class _AdminMoviesPageState extends State<AdminMoviesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddMovieDialog(BuildContext context) {
    final titleController = TextEditingController();
    final overviewController = TextEditingController();
    final posterUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Movie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: overviewController,
                decoration: const InputDecoration(labelText: 'Overview'),
                maxLines: 3,
              ),
              TextField(
                controller: posterUrlController,
                decoration: const InputDecoration(labelText: 'Poster URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && overviewController.text.isNotEmpty) {
                final moviesService = Provider.of<MoviesService>(context, listen: false);
                moviesService.addMovie({
                  'title': titleController.text,
                  'overview': overviewController.text,
                  'posterUrl': posterUrlController.text,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditMovieDialog(BuildContext context, Movie movie) {
    final titleController = TextEditingController(text: movie.title);
    final overviewController = TextEditingController(text: movie.overview);
    final posterUrlController = TextEditingController(text: movie.posterUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Movie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: overviewController,
                decoration: const InputDecoration(labelText: 'Overview'),
                maxLines: 3,
              ),
              TextField(
                controller: posterUrlController,
                decoration: const InputDecoration(labelText: 'Poster URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && overviewController.text.isNotEmpty) {
                final moviesService = Provider.of<MoviesService>(context, listen: false);
                moviesService.updateMovie(movie.id, {
                  'title': titleController.text,
                  'overview': overviewController.text,
                  'posterUrl': posterUrlController.text,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Movie'),
        content: Text('Are you sure you want to delete "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final moviesService = Provider.of<MoviesService>(context, listen: false);
              moviesService.deleteMovie(movie.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        title: const Text('Manage Movies'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                Provider.of<MoviesService>(context, listen: false)
                    .setSearchQuery(value);
              },
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
            child: Consumer<MoviesService>(
              builder: (context, moviesService, child) {
                final movies = moviesService.getMovies();
                
                return ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.white.withOpacity(0.1),
                      child: ListTile(
                        leading: movie.posterUrl.isEmpty
                            ? Container(
                                width: 40,
                                height: 60,
                                color: Colors.grey,
                                child: const Icon(Icons.movie, color: Colors.white),
                              )
                            : Image.network(
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
                        title: Text(
                          movie.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Rating: ${movie.rating}',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _showEditMovieDialog(context, movie);
                                break;
                              case 'delete':
                                _showDeleteConfirmation(context, movie);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMovieDialog(context),
        backgroundColor: CinemapsTheme.neonYellow,
        child: const Icon(Icons.add),
      ),
    );
  }
} 