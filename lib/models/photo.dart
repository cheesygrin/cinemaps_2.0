class Photo {
  final String id;
  final String userId;
  final String url;
  final DateTime timestamp;
  final Map<String, double> location;
  final String? caption;

  Photo({
    required this.id,
    required this.userId,
    required this.url,
    required this.timestamp,
    required this.location,
    this.caption,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      userId: json['userId'] as String,
      url: json['url'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: Map<String, double>.from(json['location'] as Map),
      caption: json['caption'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'url': url,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'caption': caption,
    };
  }
}
