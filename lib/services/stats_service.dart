import 'package:flutter/material.dart';

class UserStats {
  final int totalPoints;
  final int locationsVisited;
  final int toursCompleted;
  final int triviaCompleted;
  final int riddlesSolved;
  final int achievementsUnlocked;
  final Map<String, int> genreStats;
  final Map<String, Duration> timeSpent;
  final List<String> recentActivities;

  UserStats({
    this.totalPoints = 0,
    this.locationsVisited = 0,
    this.toursCompleted = 0,
    this.triviaCompleted = 0,
    this.riddlesSolved = 0,
    this.achievementsUnlocked = 0,
    this.genreStats = const {},
    this.timeSpent = const {},
    this.recentActivities = const [],
  });

  UserStats copyWith({
    int? totalPoints,
    int? locationsVisited,
    int? toursCompleted,
    int? triviaCompleted,
    int? riddlesSolved,
    int? achievementsUnlocked,
    Map<String, int>? genreStats,
    Map<String, Duration>? timeSpent,
    List<String>? recentActivities,
  }) {
    return UserStats(
      totalPoints: totalPoints ?? this.totalPoints,
      locationsVisited: locationsVisited ?? this.locationsVisited,
      toursCompleted: toursCompleted ?? this.toursCompleted,
      triviaCompleted: triviaCompleted ?? this.triviaCompleted,
      riddlesSolved: riddlesSolved ?? this.riddlesSolved,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      genreStats: genreStats ?? this.genreStats,
      timeSpent: timeSpent ?? this.timeSpent,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }
}

class StatsService extends ChangeNotifier {
  UserStats _stats = UserStats();
  final int _maxRecentActivities = 50;

  UserStats get stats => _stats;

  void addPoints(int points, {String? source}) {
    _stats = _stats.copyWith(
      totalPoints: _stats.totalPoints + points,
    );
    _addActivity('Earned $points points${source != null ? ' from $source' : ''}');
    notifyListeners();
  }

  void incrementLocationVisits() {
    _stats = _stats.copyWith(
      locationsVisited: _stats.locationsVisited + 1,
    );
    _addActivity('Visited a new location');
    notifyListeners();
  }

  void incrementToursCompleted() {
    _stats = _stats.copyWith(
      toursCompleted: _stats.toursCompleted + 1,
    );
    _addActivity('Completed a movie tour');
    notifyListeners();
  }

  void incrementTriviaCompleted() {
    _stats = _stats.copyWith(
      triviaCompleted: _stats.triviaCompleted + 1,
    );
    _addActivity('Completed a trivia challenge');
    notifyListeners();
  }

  void incrementRiddlesSolved() {
    _stats = _stats.copyWith(
      riddlesSolved: _stats.riddlesSolved + 1,
    );
    _addActivity('Solved a location riddle');
    notifyListeners();
  }

  void incrementAchievementsUnlocked() {
    _stats = _stats.copyWith(
      achievementsUnlocked: _stats.achievementsUnlocked + 1,
    );
    _addActivity('Unlocked a new achievement');
    notifyListeners();
  }

  void addGenreVisit(String genre) {
    final newGenreStats = Map<String, int>.from(_stats.genreStats);
    newGenreStats[genre] = (newGenreStats[genre] ?? 0) + 1;
    _stats = _stats.copyWith(genreStats: newGenreStats);
    notifyListeners();
  }

  void addTimeSpent(String activity, Duration duration) {
    final newTimeSpent = Map<String, Duration>.from(_stats.timeSpent);
    newTimeSpent[activity] = (newTimeSpent[activity] ?? Duration.zero) + duration;
    _stats = _stats.copyWith(timeSpent: newTimeSpent);
    notifyListeners();
  }

  void _addActivity(String activity) {
    final newActivities = List<String>.from(_stats.recentActivities);
    newActivities.insert(0, activity);
    if (newActivities.length > _maxRecentActivities) {
      newActivities.removeLast();
    }
    _stats = _stats.copyWith(recentActivities: newActivities);
  }

  String getMostVisitedGenre() {
    if (_stats.genreStats.isEmpty) return 'None';
    return _stats.genreStats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Duration getTotalTimeSpent() {
    return _stats.timeSpent.values.fold(
      Duration.zero,
      (total, duration) => total + duration,
    );
  }

  Map<String, double> getGenreDistribution() {
    if (_stats.genreStats.isEmpty) return {};

    final total = _stats.genreStats.values.reduce((a, b) => a + b);
    return Map.fromEntries(
      _stats.genreStats.entries.map(
        (entry) => MapEntry(
          entry.key,
          entry.value / total,
        ),
      ),
    );
  }

  List<MapEntry<String, Duration>> getTimeSpentByActivity() {
    return _stats.timeSpent.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  void resetStats() {
    _stats = UserStats();
    notifyListeners();
  }

  // Rank calculation based on total points
  String calculateRank() {
    final points = _stats.totalPoints;
    if (points >= 10000) return 'Movie Mogul';
    if (points >= 5000) return 'Director';
    if (points >= 2500) return 'Producer';
    if (points >= 1000) return 'Actor';
    if (points >= 500) return 'Extra';
    return 'Movie Fan';
  }

  // Level calculation (1-100)
  int calculateLevel() {
    return (_stats.totalPoints / 100).floor().clamp(1, 100);
  }

  // Progress to next level (0.0 - 1.0)
  double getLevelProgress() {
    final level = calculateLevel();
    final pointsForCurrentLevel = level * 100;
    final pointsForNextLevel = (level + 1) * 100;
    final progress = (_stats.totalPoints - pointsForCurrentLevel) /
        (pointsForNextLevel - pointsForCurrentLevel);
    return progress.clamp(0.0, 1.0);
  }

  // Get points needed for next level
  int getPointsToNextLevel() {
    final level = calculateLevel();
    final pointsForNextLevel = (level + 1) * 100;
    return pointsForNextLevel - _stats.totalPoints;
  }
}
