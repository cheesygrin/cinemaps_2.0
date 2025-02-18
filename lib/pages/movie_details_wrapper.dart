import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/movie_details_service.dart';
import 'movie_details_page.dart';

class MovieDetailsWrapper extends StatelessWidget {
  final String movieId;
  final String userId;

  const MovieDetailsWrapper({
    super.key,
    required this.movieId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MovieDetailsPage(
      movieId: movieId,
      userId: userId,
    );
  }
} 