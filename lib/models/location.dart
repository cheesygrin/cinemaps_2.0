class Location {
  final String id;
  final String name;
  final String address;
  final String description;
  final double rating;
  final double lat;
  final double lng;
  final List<String> photos;

  const Location({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.photos,
  });
} 