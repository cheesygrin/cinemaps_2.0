import 'package:flutter/material.dart';

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int points;
  final int rank;
  final List<String> achievements;
  final Map<String, int> stats;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.points,
    required this.rank,
    this.achievements = const [],
    this.stats = const {},
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final int points;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> requirements;
  final List<String> completedBy;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.startDate,
    required this.endDate,
    this.requirements = const {},
    this.completedBy = const [],
  });

  bool get isActive => DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final int points;
  final String iconName;
  final AchievementTier tier;
  final Map<String, dynamic> requirements;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.iconName,
    required this.tier,
    this.requirements = const {},
  });
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond
}

enum LeaderboardTimeframe {
  allTime,
  thisYear,
  thisMonth,
  thisWeek,
  today
}

enum LeaderboardCategory {
  global,
  localArea,
  friends,
  movieLocations,
  tours,
  photos
}

class LeaderboardService extends ChangeNotifier {
  final Map<String, List<LeaderboardEntry>> _leaderboards = {};
  final List<Challenge> _challenges = [];
  final Map<String, Achievement> _achievements = {};
  final Map<String, List<String>> _userAchievements = {};

  // Leaderboard Methods
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardCategory category,
    required LeaderboardTimeframe timeframe,
    String? locationId,
    int limit = 100,
  }) async {
    final key = '${category.name}_${timeframe.name}_${locationId ?? 'global'}';
    return _leaderboards[key] ?? [];
  }

  Future<LeaderboardEntry?> getUserRank(String userId, {
    required LeaderboardCategory category,
    required LeaderboardTimeframe timeframe,
    String? locationId,
  }) async {
    final leaderboard = await getLeaderboard(
      category: category,
      timeframe: timeframe,
      locationId: locationId,
    );
    return leaderboard.firstWhere(
      (entry) => entry.userId == userId,
      orElse: () => LeaderboardEntry(
        userId: userId,
        username: 'Unknown',
        points: 0,
        rank: -1,
      ),
    );
  }

  // Challenge Methods
  Future<List<Challenge>> getActiveChallenges() async {
    return _challenges.where((challenge) => challenge.isActive).toList();
  }

  Future<List<Challenge>> getUpcomingChallenges() async {
    final now = DateTime.now();
    return _challenges.where((challenge) => challenge.startDate.isAfter(now)).toList();
  }

  Future<void> participateInChallenge(String userId, String challengeId) async {
    final challenge = _challenges.firstWhere((c) => c.id == challengeId);
    if (!challenge.isActive) return;

    // TODO: Implement challenge participation logic
    notifyListeners();
  }

  Future<bool> checkChallengeProgress(String userId, String challengeId) async {
    // TODO: Implement challenge progress checking
    return false;
  }

  // Achievement Methods
  Future<List<Achievement>> getUserAchievements(String userId) async {
    final achievementIds = _userAchievements[userId] ?? [];
    return achievementIds
        .map((id) => _achievements[id])
        .whereType<Achievement>()
        .toList();
  }

  Future<void> checkAndAwardAchievements(String userId) async {
    for (final achievement in _achievements.values) {
      if (await _checkAchievementRequirements(userId, achievement)) {
        await _awardAchievement(userId, achievement.id);
      }
    }
  }

  Future<bool> _checkAchievementRequirements(String userId, Achievement achievement) async {
    // TODO: Implement achievement requirements checking
    return false;
  }

  Future<void> _awardAchievement(String userId, String achievementId) async {
    if (!_userAchievements.containsKey(userId)) {
      _userAchievements[userId] = [];
    }
    if (!_userAchievements[userId]!.contains(achievementId)) {
      _userAchievements[userId]!.add(achievementId);
      notifyListeners();
    }
  }

  // Stats Methods
  Future<Map<String, int>> getUserStats(String userId) async {
    final entry = await getUserRank(
      userId,
      category: LeaderboardCategory.global,
      timeframe: LeaderboardTimeframe.allTime,
    );
    return entry?.stats ?? {};
  }

  Future<void> updateUserStats(String userId, String stat, int value) async {
    // TODO: Implement stats updating
    notifyListeners();
  }

  // Weekly Reset
  Future<void> performWeeklyReset() async {
    // TODO: Implement weekly reset logic
    notifyListeners();
  }

  // Initialize with sample data
  Future<void> initialize() async {
    // Add sample achievements
    _achievements.addAll({
      'explorer_bronze': Achievement(
        id: 'explorer_bronze',
        title: 'Movie Explorer Bronze',
        description: 'Visit 10 movie locations',
        points: 100,
        iconName: 'location_on',
        tier: AchievementTier.bronze,
        requirements: {'locations_visited': 10},
      ),
      'photographer_silver': Achievement(
        id: 'photographer_silver',
        title: 'Set Photographer Silver',
        description: 'Upload 50 photos',
        points: 250,
        iconName: 'camera',
        tier: AchievementTier.silver,
        requirements: {'photos_uploaded': 50},
      ),
      'tour_guide_gold': Achievement(
        id: 'tour_guide_gold',
        title: 'Tour Guide Gold',
        description: 'Complete 20 movie tours',
        points: 500,
        iconName: 'movie_filter',
        tier: AchievementTier.gold,
        requirements: {'tours_completed': 20},
      ),
    });

    // Add sample challenges
    final now = DateTime.now();
    _challenges.addAll([
      Challenge(
        id: 'weekly_explorer',
        title: 'Weekly Explorer',
        description: 'Visit 5 new movie locations this week',
        points: 200,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        requirements: {'new_locations': 5},
      ),
      Challenge(
        id: 'photo_master',
        title: 'Photo Master',
        description: 'Get 100 likes on your photos this week',
        points: 300,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        requirements: {'photo_likes': 100},
      ),
    ]);

    // Add sample leaderboard entries
    _leaderboards['global_allTime_global'] = List.generate(
      100,
      (index) => LeaderboardEntry(
        userId: 'user_$index',
        username: 'Explorer ${index + 1}',
        points: 1000 - index * 10,
        rank: index + 1,
        achievements: index < 10 ? ['explorer_bronze', 'photographer_silver'] : [],
        stats: {
          'locations_visited': 50 - index,
          'photos_uploaded': 30 - index,
          'tours_completed': 20 - index,
        },
      ),
    );
  }
}
