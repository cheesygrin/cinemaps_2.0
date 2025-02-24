class CustomTour {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double? rating;
  final int? totalDuration;
  final double? totalDistance;
  final List<String> stops;

  CustomTour({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.rating,
    this.totalDuration,
    this.totalDistance,
    required this.stops,
  });

  factory CustomTour.fromJson(Map<String, dynamic> json) {
    return CustomTour(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalDuration: json['totalDuration'] as int?,
      totalDistance: (json['totalDistance'] as num?)?.toDouble(),
      stops: (json['stops'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalDuration': totalDuration,
      'totalDistance': totalDistance,
      'stops': stops,
    };
  }
} 