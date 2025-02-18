import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../models/photo.dart';

class PhotoGrid extends StatelessWidget {
  final String userId;
  final PhotoService _photoService = PhotoService();

  PhotoGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Photo>>(
      stream: _photoService.getUserPhotos(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading photos: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final photos = snapshot.data ?? [];
        if (photos.isEmpty) {
          return const Center(
            child: Text(
              'No photos yet. Add some memories!',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return InkWell(
              onTap: () {
                // TODO: Show photo details
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
