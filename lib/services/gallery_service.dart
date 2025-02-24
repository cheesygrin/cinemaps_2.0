import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/gallery_image.dart';
import 'storage_service.dart';

class GalleryService extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();
  List<GalleryImage> _images = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<GalleryImage> get images => List.unmodifiable(_images);

  // Placeholder images for testing
  final List<String> _placeholderImages = [
    'assets/images/gallery/placeholder1.jpg',
    'assets/images/gallery/placeholder2.jpg',
    'assets/images/gallery/placeholder3.jpg',
    'assets/images/gallery/placeholder4.jpg',
    'assets/images/gallery/placeholder5.jpg',
  ];

  Future<void> loadImages() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      // For now, load placeholder images
      _images = _placeholderImages
          .map((url) => GalleryImage(
                id: url,
                url: url,
                title: 'Sample Image',
                description: 'A placeholder image for testing',
                uploadDate: DateTime.now(),
                userId: 'system',
                likes: 0,
                isAsset: true,
              ))
          .toList();
    } catch (e) {
      print('Error loading gallery images: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addImage(GalleryImage image) async {
    try {
      _images.add(image);
      notifyListeners();
    } catch (e) {
      print('Error adding gallery image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imageId) async {
    try {
      _images.removeWhere((image) => image.id == imageId);
      notifyListeners();
    } catch (e) {
      print('Error deleting gallery image: $e');
      rethrow;
    }
  }

  Future<void> likeImage(String imageId) async {
    try {
      final index = _images.indexWhere((image) => image.id == imageId);
      if (index != -1) {
        _images[index] = _images[index].copyWith(
          likes: _images[index].likes + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error liking gallery image: $e');
      rethrow;
    }
  }
} 