import 'package:flutter/material.dart';
import '../widgets/achievement_notification.dart';

enum AchievementType {
  visitLocation,
  addReview,
  shareLocation,
  solveRiddle,
  completeTour,
  uploadPhoto,
  likePhoto,
  commentPhoto,
  checkInMovie,
  shareMovie,
  likeMovie,
  commentMovie,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final AchievementType type;
  final int requiredCount;
  final int points;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.requiredCount,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

class AchievementService extends ChangeNotifier {
  final Map<String, Achievement> _achievements = {
    'first_visit': Achievement(
      id: 'first_visit',
      title: 'Movie Scout',
      description: 'Visit your first filming location',
      iconPath: 'assets/badges/movie_scout.png',
      type: AchievementType.visitLocation,
      requiredCount: 1,
      points: 10,
    ),
    'reviewer': Achievement(
      id: 'reviewer',
      title: 'Film Critic',
      description: 'Write 5 location reviews',
      iconPath: 'assets/badges/critic.png',
      type: AchievementType.addReview,
      requiredCount: 5,
      points: 50,
    ),
    'social_butterfly': Achievement(
      id: 'social_butterfly',
      title: 'Location Scout',
      description: 'Share 3 locations with friends',
      iconPath: 'assets/badges/share.png',
      type: AchievementType.shareLocation,
      requiredCount: 3,
      points: 30,
    ),
    'riddle_master': Achievement(
      id: 'riddle_master',
      title: 'Riddle Master',
      description: 'Solve 10 location riddles',
      iconPath: 'assets/badges/riddle.png',
      type: AchievementType.solveRiddle,
      requiredCount: 10,
      points: 100,
    ),
    'tour_guide': Achievement(
      id: 'tour_guide',
      title: 'Tour Guide',
      description: 'Complete your first movie tour',
      iconPath: 'assets/badges/tour.png',
      type: AchievementType.completeTour,
      requiredCount: 1,
      points: 75,
    ),
    'photographer': Achievement(
      id: 'photographer',
      title: 'Set Photographer',
      description: 'Upload 10 photos of filming locations',
      iconPath: 'assets/badges/photographer.png',
      type: AchievementType.uploadPhoto,
      requiredCount: 10,
      points: 50,
    ),
    'photo_enthusiast': Achievement(
      id: 'photo_enthusiast',
      title: 'Photo Enthusiast',
      description: 'Like 20 photos from other users',
      iconPath: 'assets/badges/like.png',
      type: AchievementType.likePhoto,
      requiredCount: 20,
      points: 30,
    ),
    'commenter': Achievement(
      id: 'commenter',
      title: 'Active Commenter',
      description: 'Leave 15 comments on photos',
      iconPath: 'assets/badges/comment.png',
      type: AchievementType.commentPhoto,
      requiredCount: 15,
      points: 40,
    ),
    'movie_explorer': Achievement(
      id: 'movie_explorer',
      title: 'Movie Explorer',
      description: 'Check in at 5 different movie locations',
      iconPath: 'assets/badges/checkin.png',
      type: AchievementType.checkInMovie,
      requiredCount: 5,
      points: 60,
    ),
    'movie_promoter': Achievement(
      id: 'movie_promoter',
      title: 'Movie Promoter',
      description: 'Share 10 movies with friends',
      iconPath: 'assets/badges/share_movie.png',
      type: AchievementType.shareMovie,
      requiredCount: 10,
      points: 35,
    ),
    'movie_fan': Achievement(
      id: 'movie_fan',
      title: 'Movie Fan',
      description: 'Like 30 movies',
      iconPath: 'assets/badges/movie_like.png',
      type: AchievementType.likeMovie,
      requiredCount: 30,
      points: 45,
    ),
    'movie_critic': Achievement(
      id: 'movie_critic',
      title: 'Movie Critic',
      description: 'Write 20 movie comments',
      iconPath: 'assets/badges/movie_comment.png',
      type: AchievementType.commentMovie,
      requiredCount: 20,
      points: 55,
    ),
  };

  final Map<AchievementType, int> _progress = {};
  int _totalPoints = 0;

  List<Achievement> get allAchievements => _achievements.values.toList();
  List<Achievement> get unlockedAchievements => 
      _achievements.values.where((a) => a.isUnlocked).toList();
  int get totalPoints => _totalPoints;

  void trackProgress(AchievementType type) {
    _progress[type] = (_progress[type] ?? 0) + 1;
    _checkAchievements(type);
  }

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void _showAchievementNotification(Achievement achievement) {
    if (_context != null) {
      showDialog(
        context: _context!,
        barrierColor: Colors.transparent,
        builder: (context) => AchievementNotification(
          achievement: achievement,
        ),
      );
    }
  }

  void _checkAchievements(AchievementType type) {
    final currentCount = _progress[type] ?? 0;
    
    for (final achievement in _achievements.values) {
      if (!achievement.isUnlocked && 
          achievement.type == type && 
          currentCount >= achievement.requiredCount) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now();
        _totalPoints += achievement.points;
        _showAchievementNotification(achievement);
        notifyListeners();
      }
    }
  }

  String getRank() {
    if (_totalPoints >= 500) return 'Movie Mogul';
    if (_totalPoints >= 250) return 'Director';
    if (_totalPoints >= 100) return 'Producer';
    if (_totalPoints >= 50) return 'Actor';
    return 'Extra';
  }

  double getProgress(Achievement achievement) {
    if (achievement.isUnlocked) return 1.0;
    final current = _progress[achievement.type] ?? 0;
    return current / achievement.requiredCount;
  }
}
