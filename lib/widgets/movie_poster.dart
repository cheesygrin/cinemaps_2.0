import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MoviePoster extends StatelessWidget {
  final String? posterUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const MoviePoster({
    super.key,
    this.posterUrl,
    this.width = 120,
    this.height = 180,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (posterUrl == null || posterUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Center(
          child: Icon(
            Icons.movie,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: posterUrl ?? '',
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.white54,
            size: 48,
          ),
        ),
      ),
    );
  }
} 