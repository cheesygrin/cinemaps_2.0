import 'package:flutter/material.dart';
import 'social_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int pointsValue;
  final AchievementType type;
  final int requiredCount;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.pointsValue,
    required this.type,
    required this.requiredCount,
  });
}

enum AchievementType {
  visitedLocations,
  completedTours,
  createdTours,
  sharedContent,
  uploadedPhotos,
  gainedFollowers,
}

class AchievementsService extends ChangeNotifier {
  static final AchievementsService _instance = AchievementsService._internal();
  factory AchievementsService() => _instance;
  AchievementsService._internal();

  final SocialService _socialService = SocialService();
  final Map<String, Achievement> _achievements = {
    'explorer_bronze': Achievement(
      id: 'explorer_bronze',
      title: 'Movie Explorer Bronze',
      description: 'Visit 5 filming locations',
      iconName: 'location_bronze',
      pointsValue: 100,
      type: AchievementType.visitedLocations,
      requiredCount: 5,
    ),
    'explorer_silver': Achievement(
      id: 'explorer_silver',
      title: 'Movie Explorer Silver',
      description: 'Visit 25 filming locations',
      iconName: 'location_silver',
      pointsValue: 500,
      type: AchievementType.visitedLocations,
      requiredCount: 25,
    ),
    'explorer_gold': Achievement(
      id: 'explorer_gold',
      title: 'Movie Explorer Gold',
      description: 'Visit 100 filming locations',
      iconName: 'location_gold',
      pointsValue: 2000,
      type: AchievementType.visitedLocations,
      requiredCount: 100,
    ),
    'tour_guide_bronze': Achievement(
      id: 'tour_guide_bronze',
      title: 'Tour Guide Bronze',
      description: 'Create 3 public tours',
      iconName: 'tour_bronze',
      pointsValue: 200,
      type: AchievementType.createdTours,
      requiredCount: 3,
    ),
    'tour_guide_silver': Achievement(
      id: 'tour_guide_silver',
      title: 'Tour Guide Silver',
      description: 'Create 10 public tours',
      iconName: 'tour_silver',
      pointsValue: 1000,
      type: AchievementType.createdTours,
      requiredCount: 10,
    ),
    'photographer_bronze': Achievement(
      id: 'photographer_bronze',
      title: 'Set Photographer Bronze',
      description: 'Upload 10 photos',
      iconName: 'camera_bronze',
      pointsValue: 150,
      type: AchievementType.uploadedPhotos,
      requiredCount: 10,
    ),
    'photographer_silver': Achievement(
      id: 'photographer_silver',
      title: 'Set Photographer Silver',
      description: 'Upload 50 photos',
      iconName: 'camera_silver',
      pointsValue: 750,
      type: AchievementType.uploadedPhotos,
      requiredCount: 50,
    ),
    'social_butterfly': Achievement(
      id: 'social_butterfly',
      title: 'Social Butterfly',
      description: 'Gain 100 followers',
      iconName: 'social',
      pointsValue: 1000,
      type: AchievementType.gainedFollowers,
      requiredCount: 100,
    ),
    'tour_master': Achievement(
      id: 'tour_master',
      title: 'Tour Master',
      description: 'Complete 20 tours',
      iconName: 'tour_gold',
      pointsValue: 2000,
      type: AchievementType.completedTours,
      requiredCount: 20,
    ),
  };

  List<Achievement> getAllAchievements() {
    return _achievements.values.toList();
  }

  List<Achievement> getUserAchievements(String userId) {
    return _achievements.values
        .where((a) => _hasUserEarnedAchievement(userId, a))
        .toList();
  }

  List<Achievement> getAvailableAchievements(String userId) {
    return _achievements.values
        .where((a) => !_hasUserEarnedAchievement(userId, a))
        .toList();
  }

  Future<bool> _hasUserEarnedAchievement(
      String userId, Achievement achievement) async {
    final profile = await _socialService.getUserProfile(userId);
    if (profile == null) return false;

    switch (achievement.type) {
      case AchievementType.visitedLocations:
        return profile.visitedLocations.length >= achievement.requiredCount;
      case AchievementType.completedTours:
        return profile.completedTours.length >= achievement.requiredCount;
      case AchievementType.gainedFollowers:
        return profile.followers.length >= achievement.requiredCount;
      case AchievementType.uploadedPhotos:
        // TODO: Implement photo count tracking
        return false;
      case AchievementType.createdTours:
        // TODO: Implement created tours tracking
        return false;
      case AchievementType.sharedContent:
        // TODO: Implement shared content tracking
        return false;
    }
  }

  void checkAndAwardAchievements(String userId) async {
    final availableAchievements = getAvailableAchievements(userId);
    for (final achievement in availableAchievements) {
      if (_hasUserEarnedAchievement(userId, achievement)) {
        _socialService.addAchievement(userId, achievement.id);
        _socialService.addPoints(userId, achievement.pointsValue);
      }
    }
  }
}
