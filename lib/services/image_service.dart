import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  static const String _cacheKey = 'cinemaps_image_cache';
  static const Duration _maxAge = Duration(days: 30);
  static const int _maxNrOfCacheObjects = 100;

  final _cacheManager = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: _maxAge,
      maxNrOfCacheObjects: _maxNrOfCacheObjects,
      repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      fileService: HttpFileService(),
    ),
  );

  Future<String> optimizeAndCacheImage(File imageFile) async {
    // Read the image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Could not decode image');

    // Resize if too large (maintain aspect ratio)
    img.Image optimizedImage = image;
    if (image.width > 2000 || image.height > 2000) {
      final aspectRatio = image.width / image.height;
      int newWidth = 2000;
      int newHeight = (2000 / aspectRatio).round();
      
      if (image.height > image.width) {
        newHeight = 2000;
        newWidth = (2000 * aspectRatio).round();
      }
      
      optimizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // Encode as high-quality JPEG
    final optimizedBytes = img.encodeJpg(optimizedImage, quality: 85);

    // Save to cache
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(optimizedBytes);

    // Put in cache manager
    await _cacheManager.putFile(
      tempFile.path,
      optimizedBytes,
      fileExtension: 'jpg',
    );

    return tempFile.path;
  }

  Widget buildOptimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? (context, url) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: errorWidget ?? (context, url, error) => Container(
        color: Colors.grey[900],
        child: const Icon(Icons.error),
      ),
      cacheManager: _cacheManager,
    );
  }

  Future<void> preloadImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await _cacheManager.downloadFile(url);
      } catch (e) {
        debugPrint('Error preloading image $url: $e');
      }
    }
  }

  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  Future<void> removeFromCache(String url) async {
    await _cacheManager.removeFile(url);
  }
} 