import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/cinemaps_theme.dart';

class EditMovieDialog extends StatefulWidget {
  final Movie? movie;

  const EditMovieDialog({super.key, this.movie});

  @override
  State<EditMovieDialog> createState() => _EditMovieDialogState();
}

class _EditMovieDialogState extends State<EditMovieDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _posterUrlController;
  late TextEditingController _backdropUrlController;
  late TextEditingController _releaseYearController;
  late TextEditingController _descriptionController;
  late TextEditingController _genresController;
  late TextEditingController _castController;
  late TextEditingController _crewController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _posterUrlController = TextEditingController(text: widget.movie?.posterUrl ?? '');
    _backdropUrlController = TextEditingController(text: widget.movie?.posterUrl ?? '');
    _releaseYearController = TextEditingController(text: widget.movie?.releaseYear.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.movie?.description ?? '');
    _genresController = TextEditingController(text: widget.movie?.genres.join(', ') ?? '');
    _castController = TextEditingController(text: widget.movie?.cast.join(', ') ?? '');
    _crewController = TextEditingController(text: widget.movie?.crew.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _posterUrlController.dispose();
    _backdropUrlController.dispose();
    _releaseYearController.dispose();
    _descriptionController.dispose();
    _genresController.dispose();
    _castController.dispose();
    _crewController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getMovieData() {
    return {
      'title': _titleController.text,
      'posterUrl': _posterUrlController.text,
      'backdropUrl': _backdropUrlController.text,
      'releaseYear': int.parse(_releaseYearController.text),
      'description': _descriptionController.text,
      'genres': _genresController.text.split(',').map((e) => e.trim()).toList(),
      'cast': _castController.text.split(',').map((e) => e.trim()).toList(),
      'crew': _crewController.text.split(',').map((e) => e.trim()).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie == null ? 'Add Movie' : 'Edit Movie',
                  style: const TextStyle(
                    color: CinemapsTheme.neonYellow,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _posterUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Poster URL',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _backdropUrlController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Backdrop URL',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _releaseYearController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Release Year',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a release year';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _genresController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Genres (comma-separated)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one genre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _castController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Cast (comma-separated)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one cast member';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _crewController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Crew (comma-separated)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CinemapsTheme.neonYellow),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one crew member';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CinemapsTheme.hotPink,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, _getMovieData());
                        }
                      },
                      child: Text(widget.movie == null ? 'ADD' : 'SAVE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 