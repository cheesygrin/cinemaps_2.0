import 'package:flutter/material.dart';
import 'dart:math' as math;

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final int pointValue;
  final DateTime unlockedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.pointValue,
    required this.unlockedAt,
  });
}

class GamificationService extends ChangeNotifier {
  final Map<String, int> _userPoints = {};
  final Map<String, List<Badge>> _userBadges = {};
  final Map<String, List<String>> _userStreaks = {};

  // Badge definitions
  final Map<String, Map<String, dynamic>> _badgeDefinitions = {
    'first_check_in': {
      'name': 'First Steps',
      'description': 'Completed your first location check-in',
      'iconPath': 'assets/badges/first_steps.png',
      'pointValue': 100,
    },
    'adventurer': {
      'name': 'Adventurer',
      'description': 'Visited 5 different filming locations',
      'iconPath': 'assets/badges/adventurer.png',
      'pointValue': 250,
    },
    'explorer': {
      'name': 'Explorer',
      'description': 'Visited 10 different filming locations',
      'iconPath': 'assets/badges/explorer.png',
      'pointValue': 500,
    },
    'movie_buff': {
      'name': 'Movie Buff',
      'description': 'Visited 25 different filming locations',
      'iconPath': 'assets/badges/movie_buff.png',
      'pointValue': 1000,
    },
    'cinematic_legend': {
      'name': 'Cinematic Legend',
      'description': 'Visited 50 different filming locations',
      'iconPath': 'assets/badges/cinematic_legend.png',
      'pointValue': 2500,
    },
    'photo_master': {
      'name': 'Photo Master',
      'description': 'Shared 50 photos from filming locations',
      'iconPath': 'assets/badges/photo_master.png',
      'pointValue': 500,
    },
    'social_butterfly': {
      'name': 'Social Butterfly',
      'description': 'Made 100 friends on Cinemaps',
      'iconPath': 'assets/badges/social_butterfly.png',
      'pointValue': 750,
    },
    'tour_guide': {
      'name': 'Tour Guide',
      'description': 'Created and shared 5 custom movie tours',
      'iconPath': 'assets/badges/tour_guide.png',
      'pointValue': 1000,
    },
  };

  int getUserPoints(String userId) {
    return _userPoints[userId] ?? 0;
  }

  List<Badge> getUserBadges(String userId) {
    return _userBadges[userId] ?? [];
  }

  Future<void> awardPoints(String userId, int points) async {
    final currentPoints = getUserPoints(userId);
    _userPoints[userId] = currentPoints + points;
    notifyListeners();
  }

  Future<void> awardBadge(String userId, String badgeId) async {
    if (!_badgeDefinitions.containsKey(badgeId)) {
      throw Exception('Invalid badge ID: $badgeId');
    }

    final badgeData = _badgeDefinitions[badgeId]!;
    final badge = Badge(
      id: badgeId,
      name: badgeData['name'],
      description: badgeData['description'],
      iconPath: badgeData['iconPath'],
      pointValue: badgeData['pointValue'],
      unlockedAt: DateTime.now(),
    );

    _userBadges.putIfAbsent(userId, () => []).add(badge);
    await awardPoints(userId, badge.pointValue);
    notifyListeners();
  }

  int getUserLevel(String userId) {
    final points = getUserPoints(userId);
    // Level formula: level = floor(sqrt(points/100))
    return math.sqrt(points / 100).floor();
  }

  int getPointsToNextLevel(String userId) {
    final currentLevel = getUserLevel(userId);
    final nextLevelPoints = (currentLevel + 1) * (currentLevel + 1) * 100;
    return nextLevelPoints - getUserPoints(userId);
  }

  double getLevelProgress(String userId) {
    final points = getUserPoints(userId);
    final currentLevel = getUserLevel(userId);
    final currentLevelPoints = currentLevel * currentLevel * 100;
    final nextLevelPoints = (currentLevel + 1) * (currentLevel + 1) * 100;
    return (points - currentLevelPoints) / (nextLevelPoints - currentLevelPoints);
  }

  Future<void> updateStreak(String userId, String streakType) async {
    final streaks = _userStreaks[userId] ?? [];
    if (!streaks.contains(streakType)) {
      streaks.add(streakType);
      _userStreaks[userId] = streaks;

      // Award streak bonuses
      switch (streaks.length) {
        case 3:
          await awardBadge(userId, 'streak_3');
          await awardPoints(userId, 150);
          break;
        case 7:
          await awardBadge(userId, 'streak_7');
          await awardPoints(userId, 500);
          break;
        case 30:
          await awardBadge(userId, 'streak_30');
          await awardPoints(userId, 2000);
          break;
      }

      notifyListeners();
    }
  }

  List<String> getUserStreaks(String userId) {
    return _userStreaks[userId] ?? [];
  }

  void resetStreak(String userId, String streakType) {
    final streaks = _userStreaks[userId] ?? [];
    streaks.remove(streakType);
    _userStreaks[userId] = streaks;
    notifyListeners();
  }
}
