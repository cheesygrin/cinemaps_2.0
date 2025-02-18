import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CheckInPrivacy {
  public,
  friends,
  private,
}

class CheckIn {
  final String id;
  final String userId;
  final String locationId;
  final String movieId;
  final DateTime timestamp;
  final String? note;
  final List<String> photos;
  final CheckInPrivacy privacy;
  final List<String> tags;
  final LatLng coordinates;
  final int points;
  final List<String> unlockedBadges;
  final List<String> likedByUsers;
  final List<Comment> comments;

  const CheckIn({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.movieId,
    required this.timestamp,
    this.note,
    this.photos = const [],
    this.privacy = CheckInPrivacy.public,
    this.tags = const [],
    required this.coordinates,
    this.points = 0,
    this.unlockedBadges = const [],
    this.likedByUsers = const [],
    this.comments = const [],
  });
}

class Comment {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final List<String> likedByUsers;

  const Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.likedByUsers = const [],
  });
}
