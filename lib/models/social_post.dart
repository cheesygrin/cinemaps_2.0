class SocialPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final List<Comment> comments;

  SocialPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.comments = const [],
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      comments: (json['comments'] as List? ?? [])
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String content;
  final DateTime timestamp;
  final int likeCount;
  final bool isLiked;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    required this.timestamp,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }
}
