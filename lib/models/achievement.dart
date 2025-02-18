import 'package:flutter/material.dart';

enum AchievementType {
  toursCompleted,
  photosUploaded,
  locationsVisited,
  moviesWatched,
  socialInteractions,
  specialEvents,
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementTier tier;
  final int pointsRequired;
  final String iconPath;
  final int pointsReward;
  final bool isSecret;
  final Map<String, dynamic>? requirements;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.tier,
    required this.pointsRequired,
    required this.iconPath,
    required this.pointsReward,
    this.isSecret = false,
    this.requirements,
  });

  Color get tierColor {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  String get tierName {
    return tier.toString().split('.').last.toUpperCase();
  }

  bool checkRequirements(Map<String, dynamic> userStats) {
    if (requirements == null) return false;

    switch (type) {
      case AchievementType.toursCompleted:
        return userStats['toursCompleted'] >= requirements!['count'];
      case AchievementType.photosUploaded:
        return userStats['photosUploaded'] >= requirements!['count'];
      case AchievementType.locationsVisited:
        return userStats['locationsVisited'] >= requirements!['count'];
      case AchievementType.moviesWatched:
        return userStats['moviesWatched'] >= requirements!['count'];
      case AchievementType.socialInteractions:
        return userStats['socialInteractions'] >= requirements!['count'];
      case AchievementType.specialEvents:
        return requirements!['eventCompleted'] == true;
    }
  }
}

class UserAchievement {
  final Achievement achievement;
  final DateTime unlockedAt;
  final double progress;
  final bool isUnlocked;

  const UserAchievement({
    required this.achievement,
    required this.unlockedAt,
    required this.progress,
    required this.isUnlocked,
  });

  factory UserAchievement.locked(Achievement achievement, double progress) {
    return UserAchievement(
      achievement: achievement,
      unlockedAt: DateTime.now(),
      progress: progress,
      isUnlocked: false,
    );
  }

  factory UserAchievement.unlocked(Achievement achievement) {
    return UserAchievement(
      achievement: achievement,
      unlockedAt: DateTime.now(),
      progress: 1.0,
      isUnlocked: true,
    );
  }
}
