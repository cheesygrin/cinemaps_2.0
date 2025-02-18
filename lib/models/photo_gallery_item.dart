class PhotoGalleryItem {
  final String id;
  final String userId;
  final String username;
  final String locationId;
  final String url;
  final String caption;
  final List<String> tags;
  final DateTime timestamp;
  final int likeCount;
  final List<PhotoComment> comments;

  factory PhotoGalleryItem.fromJson(Map<String, dynamic> json) {
    return PhotoGalleryItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      locationId: json['locationId'] as String,
      url: json['url'] as String,
      caption: json['caption'] as String,
      tags: List<String>.from(json['tags'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      comments: List<PhotoComment>.from(
        (json['comments'] as List? ?? [])
            .map((e) => PhotoComment.fromJson(e as Map<String, dynamic>)),
      ),
    );
  }

  PhotoGalleryItem({
    required this.id,
    required this.userId,
    required this.username,
    required this.locationId,
    required this.url,
    required this.caption,
    required this.tags,
    required this.timestamp,
    this.likeCount = 0,
    this.comments = const [],
  });
}

class PhotoComment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final int likeCount;

  factory PhotoComment.fromJson(Map<String, dynamic> json) {
    return PhotoComment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
    );
  }

  PhotoComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    this.likeCount = 0,
  });
}
