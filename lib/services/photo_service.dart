import 'package:flutter/material.dart';
import '../models/photo.dart';

class LocationPhoto {
  final String id;
  final String locationId;
  final String url;
  final String caption;
  final DateTime timestamp;
  final String userId;
  final List<String> tags;
  final int likeCount;
  final List<PhotoComment> comments;

  LocationPhoto({
    required this.id,
    required this.locationId,
    required this.url,
    required this.caption,
    required this.timestamp,
    required this.userId,
    this.tags = const [],
    this.likeCount = 0,
    this.comments = const [],
  });
}

class PhotoComment {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;
  final int likeCount;

  PhotoComment({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    this.likeCount = 0,
  });
}

class PhotoService extends ChangeNotifier {
  final Map<String, List<LocationPhoto>> _locationPhotos = {};
  final List<LocationPhoto> _recentPhotos = [];
  final int _maxRecentPhotos = 50;

  PhotoService() {
    // Add sample photos
    final samplePhotos = [
      LocationPhoto(
        id: '1',
        locationId: 'hobbiton',
        url: '',
        caption: 'Hobbiton Movie Set - The Lord of the Rings/The Hobbit (Matamata, New Zealand)',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'system',
        tags: ['lotr', 'hobbit', 'newzealand', 'movieset'],
        likeCount: 156,
      ),
      LocationPhoto(
        id: '2',
        locationId: 'platform934',
        url: '',
        caption: 'Platform 9¾ at King\'s Cross Station - Harry Potter (London, UK)',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'system',
        tags: ['harrypotter', 'london', 'kingscross', 'magic'],
        likeCount: 234,
      ),
      LocationPhoto(
        id: '3',
        locationId: 'petra',
        url: '',
        caption: 'The Treasury at Petra - Indiana Jones and the Last Crusade (Petra, Jordan)',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        userId: 'system',
        tags: ['indianajones', 'petra', 'jordan', 'adventure'],
        likeCount: 189,
      ),
      LocationPhoto(
        id: '4',
        locationId: 'skye',
        url: '',
        caption: 'Isle of Skye - James Bond: Skyfall (Scotland, UK)',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        userId: 'system',
        tags: ['jamesbond', 'skyfall', 'scotland', 'landscape'],
        likeCount: 145,
      ),
      LocationPhoto(
        id: '5',
        locationId: 'dubrovnik',
        url: '',
        caption: 'Dubrovnik Old Town - Game of Thrones (Dubrovnik, Croatia)',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'system',
        tags: ['got', 'gameofthrones', 'croatia', 'kingslanding'],
        likeCount: 278,
      ),
    ];

    // Add to recent photos
    _recentPhotos.addAll(samplePhotos);

    // Add to location photos
    for (var photo in samplePhotos) {
      _locationPhotos.update(
        photo.locationId,
        (photos) => [photo, ...photos],
        ifAbsent: () => [photo],
      );
    }
  }

  List<LocationPhoto> getPhotosForLocation(String locationId) {
    return _locationPhotos[locationId] ?? [];
  }

  Future<List<LocationPhoto>> getTourPhotos(String tourId) async {
    // TODO: Implement backend integration
    // For now, return sample photos
    return [
      LocationPhoto(
        id: '1',
        locationId: 'loc1',
        url: '',
        caption: 'Amazing scene from the movie!',
        timestamp: DateTime.now(),
        userId: 'user1',
        tags: ['movie', 'location', 'tour'],
      ),
      LocationPhoto(
        id: '2',
        locationId: 'loc2',
        url: '',
        caption: 'Beautiful filming location',
        timestamp: DateTime.now(),
        userId: 'user1',
        tags: ['movie', 'location', 'tour'],
      ),
    ];
  }

  List<LocationPhoto> get recentPhotos => _recentPhotos;

  Stream<List<Photo>> getUserPhotos(String userId) {
    // TODO: Implement real-time photo fetching
    // Convert LocationPhotos to Photos
    final photos = _recentPhotos
        .where((photo) => photo.userId == userId)
        .map((photo) => Photo(
              id: photo.id,
              userId: photo.userId,
              url: photo.url,
              timestamp: photo.timestamp,
              location: {'latitude': 0.0, 'longitude': 0.0}, // TODO: Add real location
              caption: photo.caption,
            ))
        .toList();
    return Stream.value(photos);
  }

  Future<Map<String, double>> getCurrentLocation() async {
    // TODO: Implement location fetching
    return {'latitude': 0.0, 'longitude': 0.0};
  }

  Future<void> uploadPhoto({
    required String locationId,
    required String imagePath,
    required String caption,
    required String userId,
    List<String> tags = const [],
  }) async {
    // Here you would implement actual photo upload logic
    // For now, we'll simulate it
    final photo = LocationPhoto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      locationId: locationId,
      url: imagePath,
      caption: caption,
      timestamp: DateTime.now(),
      userId: userId,
      tags: tags,
    );

    _locationPhotos.update(
      locationId,
      (photos) => [photo, ...photos],
      ifAbsent: () => [photo],
    );

    _recentPhotos.insert(0, photo);
    if (_recentPhotos.length > _maxRecentPhotos) {
      _recentPhotos.removeLast();
    }

    notifyListeners();
  }

  void likePhoto(String photoId, String userId) {
    _updatePhoto(photoId, (photo) {
      return LocationPhoto(
        id: photo.id,
        locationId: photo.locationId,
        url: photo.url,
        caption: photo.caption,
        timestamp: photo.timestamp,
        userId: photo.userId,
        tags: photo.tags,
        likeCount: photo.likeCount + 1,
        comments: photo.comments,
      );
    });
  }

  void addComment({
    required String photoId,
    required String userId,
    required String content,
  }) {
    _updatePhoto(photoId, (photo) {
      final comments = List<PhotoComment>.from(photo.comments);
      comments.add(PhotoComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        content: content,
        timestamp: DateTime.now(),
      ));
      return LocationPhoto(
        id: photo.id,
        locationId: photo.locationId,
        url: photo.url,
        caption: photo.caption,
        timestamp: photo.timestamp,
        userId: photo.userId,
        tags: photo.tags,
        likeCount: photo.likeCount,
        comments: comments,
      );
    });
  }

  void likeComment({
    required String photoId,
    required String commentId,
    required String userId,
  }) {
    _updatePhoto(photoId, (photo) {
      final comments = photo.comments.map((comment) {
        if (comment.id == commentId) {
          return PhotoComment(
            id: comment.id,
            userId: comment.userId,
            content: comment.content,
            timestamp: comment.timestamp,
            likeCount: comment.likeCount + 1,
          );
        }
        return comment;
      }).toList();

      return LocationPhoto(
        id: photo.id,
        locationId: photo.locationId,
        url: photo.url,
        caption: photo.caption,
        timestamp: photo.timestamp,
        userId: photo.userId,
        tags: photo.tags,
        likeCount: photo.likeCount,
        comments: comments,
      );
    });
  }

  void _updatePhoto(String photoId, LocationPhoto Function(LocationPhoto) update) {
    bool updated = false;

    // Update in location photos
    for (final locationId in _locationPhotos.keys) {
      final photos = _locationPhotos[locationId]!;
      for (var i = 0; i < photos.length; i++) {
        if (photos[i].id == photoId) {
          photos[i] = update(photos[i]);
          updated = true;
          break;
        }
      }
      if (updated) break;
    }

    // Update in recent photos
    if (!updated) {
      for (var i = 0; i < _recentPhotos.length; i++) {
        if (_recentPhotos[i].id == photoId) {
          _recentPhotos[i] = update(_recentPhotos[i]);
          break;
        }
      }
    }

    notifyListeners();
  }

  List<LocationPhoto> searchPhotos({
    String? locationId,
    String? userId,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final allPhotos = _locationPhotos.values.expand((photos) => photos).toList();
    return allPhotos.where((photo) {
      if (locationId != null && photo.locationId != locationId) return false;
      if (userId != null && photo.userId != userId) return false;
      if (tags != null && !tags.any((tag) => photo.tags.contains(tag))) {
        return false;
      }
      if (startDate != null && photo.timestamp.isBefore(startDate)) return false;
      if (endDate != null && photo.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<String> getPopularTags() {
    final tagCounts = <String, int>{};
    for (final photos in _locationPhotos.values) {
      for (final photo in photos) {
        for (final tag in photo.tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }
    final sortedEntries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(10).map((e) => e.key).toList();
  }

  void deletePhoto(String photoId) {
    String? locationIdToUpdate;
    LocationPhoto? photoToDelete;

    // Find and remove from location photos
    for (final locationId in _locationPhotos.keys) {
      final photos = _locationPhotos[locationId]!;
      final index = photos.indexWhere((p) => p.id == photoId);
      if (index != -1) {
        photoToDelete = photos[index];
        photos.removeAt(index);
        locationIdToUpdate = locationId;
        break;
      }
    }

    // Remove from recent photos if present
    if (photoToDelete != null) {
      _recentPhotos.removeWhere((p) => p.id == photoId);
      
      // Clean up empty location entries
      if (locationIdToUpdate != null &&
          _locationPhotos[locationIdToUpdate]!.isEmpty) {
        _locationPhotos.remove(locationIdToUpdate);
      }

      notifyListeners();
    }
  }
}
