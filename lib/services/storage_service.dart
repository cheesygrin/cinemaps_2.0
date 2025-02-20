import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageService {
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadMoviePoster(File file, String movieId) async {
    try {
      final fileName = '${movieId}_poster.jpg';
      // For now, just copy the file to local storage and return the path
      final appDir = await getApplicationDocumentsDirectory();
      final savedFile = await file.copy(path.join(appDir.path, fileName));
      return savedFile.path;
    } catch (e) {
      print('Error saving movie poster: $e');
      rethrow;
    }
  }

  Future<String> uploadGalleryImage(File file) async {
    try {
      final imageId = _uuid.v4();
      final fileName = '$imageId.jpg';
      // For now, just copy the file to local storage and return the path
      final appDir = await getApplicationDocumentsDirectory();
      final savedFile = await file.copy(path.join(appDir.path, fileName));
      return savedFile.path;
    } catch (e) {
      print('Error saving gallery image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final file = File(url);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }
} 