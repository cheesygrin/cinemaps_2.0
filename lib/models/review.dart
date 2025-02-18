class Review {
  final String id;
  final String userId;
  final String username;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime timestamp;
  final int likeCount;
  final List<ReviewComment> comments;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      photos: List<String>.from(json['photos'] as List? ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      comments: List<ReviewComment>.from(
        (json['comments'] as List? ?? [])
            .map((e) => ReviewComment.fromJson(e as Map<String, dynamic>)),
      ),
    );
  }

  Review({
    required this.id,
    required this.userId,
    required this.username,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.timestamp,
    this.likeCount = 0,
    this.comments = const [],
  });
}

class ReviewComment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final int likeCount;

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }

  ReviewComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    this.likeCount = 0,
  });
}
