import 'package:flutter/material.dart';
import '../models/check_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'gamification_service.dart';

class CheckInService extends ChangeNotifier {
  final Map<String, List<CheckIn>> _locationCheckIns = {};
  final Map<String, List<CheckIn>> _userCheckIns = {};
  final GamificationService _gamificationService;

  CheckInService({
    required GamificationService gamificationService,
  }) : _gamificationService = gamificationService;

  Future<CheckIn?> checkIn({
    required String userId,
    required String locationId,
    required String movieId,
    required LatLng userLocation,
    String? note,
    List<String> photos = const [],
    CheckInPrivacy privacy = CheckInPrivacy.public,
    List<String> tags = const [],
  }) async {
    // Verify user is actually at the location (within 50 meters)
    final locationValid = await _verifyLocation(userLocation, locationId);
    if (!locationValid) {
      throw Exception('You must be at the location to check in');
    }

    final checkIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      locationId: locationId,
      movieId: movieId,
      timestamp: DateTime.now(),
      note: note,
      photos: photos,
      privacy: privacy,
      tags: tags,
      coordinates: userLocation,
      points: _calculatePoints(locationId, userId),
      unlockedBadges: await _calculateBadges(userId, locationId),
    );

    // Store check-in
    _locationCheckIns.putIfAbsent(locationId, () => []).add(checkIn);
    _userCheckIns.putIfAbsent(userId, () => []).add(checkIn);

    // Award points and badges
    await _gamificationService.awardPoints(userId, checkIn.points);
    for (final badge in checkIn.unlockedBadges) {
      await _gamificationService.awardBadge(userId, badge);
    }

    notifyListeners();
    return checkIn;
  }

  Future<bool> _verifyLocation(LatLng userLocation, String locationId) async {
    // TODO: Implement actual location verification
    // For now, always return true for testing
    return true;
  }

  int _calculatePoints(String locationId, String userId) {
    // Base points for check-in
    int points = 100;

    // Bonus points for first time visit
    if (!hasVisited(userId, locationId)) {
      points += 50;
    }

    // TODO: Add more point calculations based on:
    // - Streak bonuses
    // - Special events
    // - Time-based bonuses
    // - Group check-ins

    return points;
  }

  Future<List<String>> _calculateBadges(
      String userId, String locationId) async {
    List<String> newBadges = [];
    final userVisits = getUserCheckIns(userId);

    // First check-in badge
    if (userVisits.isEmpty) {
      newBadges.add('first_check_in');
    }

    // Milestone badges
    final visitCount = userVisits.length;
    if (visitCount == 5) newBadges.add('adventurer');
    if (visitCount == 10) newBadges.add('explorer');
    if (visitCount == 25) newBadges.add('movie_buff');
    if (visitCount == 50) newBadges.add('cinematic_legend');

    // TODO: Add more badge calculations based on:
    // - Visit streaks
    // - Location types
    // - Movie genres
    // - Special events
    // - Social interactions

    return newBadges;
  }

  List<CheckIn> getLocationCheckIns(String locationId) {
    return _locationCheckIns[locationId] ?? [];
  }

  List<CheckIn> getUserCheckIns(String userId) {
    return _userCheckIns[userId] ?? [];
  }

  bool hasVisited(String userId, String locationId) {
    final userVisits = getUserCheckIns(userId);
    return userVisits.any((checkIn) => checkIn.locationId == locationId);
  }

  Future<void> likeCheckIn(String checkInId, String userId) async {
    // Find and update the check-in
    for (final checkIns in _locationCheckIns.values) {
      for (final checkIn in checkIns) {
        if (checkIn.id == checkInId) {
          final likes = List<String>.from(checkIn.likedByUsers);
          if (likes.contains(userId)) {
            likes.remove(userId);
          } else {
            likes.add(userId);
          }
          // Create new check-in with updated likes
          final updatedCheckIn = CheckIn(
            id: checkIn.id,
            userId: checkIn.userId,
            locationId: checkIn.locationId,
            movieId: checkIn.movieId,
            timestamp: checkIn.timestamp,
            note: checkIn.note,
            photos: checkIn.photos,
            privacy: checkIn.privacy,
            tags: checkIn.tags,
            coordinates: checkIn.coordinates,
            points: checkIn.points,
            unlockedBadges: checkIn.unlockedBadges,
            likedByUsers: likes,
            comments: checkIn.comments,
          );
          // Replace old check-in with updated one
          final index = checkIns.indexOf(checkIn);
          checkIns[index] = updatedCheckIn;
          notifyListeners();
          break;
        }
      }
    }
  }

  Future<void> addComment({
    required String checkInId,
    required String userId,
    required String content,
  }) async {
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      timestamp: DateTime.now(),
    );

    // Find and update the check-in
    for (final checkIns in _locationCheckIns.values) {
      for (final checkIn in checkIns) {
        if (checkIn.id == checkInId) {
          final comments = List<Comment>.from(checkIn.comments)..add(comment);
          // Create new check-in with updated comments
          final updatedCheckIn = CheckIn(
            id: checkIn.id,
            userId: checkIn.userId,
            locationId: checkIn.locationId,
            movieId: checkIn.movieId,
            timestamp: checkIn.timestamp,
            note: checkIn.note,
            photos: checkIn.photos,
            privacy: checkIn.privacy,
            tags: checkIn.tags,
            coordinates: checkIn.coordinates,
            points: checkIn.points,
            unlockedBadges: checkIn.unlockedBadges,
            likedByUsers: checkIn.likedByUsers,
            comments: comments,
          );
          // Replace old check-in with updated one
          final index = checkIns.indexOf(checkIn);
          checkIns[index] = updatedCheckIn;
          notifyListeners();
          break;
        }
      }
    }
  }

  Future<List<CheckIn>> getNearbyCheckIns({
    required LatLng location,
    double radiusKm = 5,
  }) async {
    List<CheckIn> nearbyCheckIns = [];

    for (final checkIns in _locationCheckIns.values) {
      for (final checkIn in checkIns) {
        if (checkIn.privacy == CheckInPrivacy.private) continue;

        final distance = Geolocator.distanceBetween(
          location.latitude,
          location.longitude,
          checkIn.coordinates.latitude,
          checkIn.coordinates.longitude,
        );

        if (distance / 1000 <= radiusKm) {
          nearbyCheckIns.add(checkIn);
        }
      }
    }

    // Sort by most recent
    nearbyCheckIns.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return nearbyCheckIns;
  }
}
