class GalleryImage {
  final String id;
  final String url;
  final String title;
  final String description;
  final DateTime uploadDate;
  final String userId;
  final int likes;
  final bool isAsset;

  GalleryImage({
    required this.id,
    required this.url,
    required this.title,
    required this.description,
    required this.uploadDate,
    required this.userId,
    this.likes = 0,
    this.isAsset = false,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      userId: json['userId'] as String,
      likes: json['likes'] as int? ?? 0,
      isAsset: json['isAsset'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'uploadDate': uploadDate.toIso8601String(),
      'userId': userId,
      'likes': likes,
      'isAsset': isAsset,
    };
  }

  GalleryImage copyWith({
    String? id,
    String? url,
    String? title,
    String? description,
    DateTime? uploadDate,
    String? userId,
    int? likes,
    bool? isAsset,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      uploadDate: uploadDate ?? this.uploadDate,
      userId: userId ?? this.userId,
      likes: likes ?? this.likes,
      isAsset: isAsset ?? this.isAsset,
    );
  }
} 