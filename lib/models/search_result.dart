class SearchResult {
  final String id;
  final String title;
  final String type; // 'movie', 'tv', 'location', 'tour'
  final String imageUrl;
  final String description;

  SearchResult({
    required this.id,
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.description,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
    );
  }
}
