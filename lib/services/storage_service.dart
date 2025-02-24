import 'dart:io';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'supabase_service.dart';

class StorageService {
  final _supabase = SupabaseService.instance;
  final _uuid = const Uuid();

  Future<String> uploadMoviePoster(File file, String movieId) async {
    try {
      final fileExtension = path.extension(file.path);
      final fileName = '$movieId${_uuid.v4()}$fileExtension';
      final bytes = await file.readAsBytes();
      
      final response = await _supabase.uploadFile(
        'movie-posters',
        fileName,
        bytes,
      );
      
      return response;
    } catch (e) {
      throw Exception('Failed to upload movie poster: $e');
    }
  }

  Future<String> uploadGalleryImage(File file) async {
    try {
      final imageId = _uuid.v4();
      final fileName = '$imageId.jpg';
      final bytes = await file.readAsBytes();
      
      final response = await _supabase.uploadFile(
        'gallery-images',
        'gallery_images/$fileName',
        bytes,
      );
      
      return response;
    } catch (e) {
      print('Error uploading gallery image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      await _supabase.deleteFile('public', path);
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  Future<String> uploadFile(String path, Uint8List fileBytes) async {
    final response = await _supabase.uploadFile('public', path, fileBytes);
    return response;
  }

  Future<Uint8List> downloadFile(String path) async {
    return await _supabase.downloadFile('public', path);
  }

  Future<void> deleteFile(String path) async {
    await _supabase.deleteFile('public', path);
  }
} 