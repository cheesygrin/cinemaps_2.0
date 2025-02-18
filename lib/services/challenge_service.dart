import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/achievement_service.dart';
import '../services/social_service.dart';

class ChallengeService extends ChangeNotifier {
  final Map<String, UserChallenge> _userChallenges = {};
  final List<Challenge> _availableChallenges = [];

  // Sample challenges - TODO: Move to backend
  final List<Challenge> _sampleChallenges = [
    Challenge(
      id: 'daily_tour',
      title: 'Daily Explorer',
      description: 'Complete a movie tour today',
      type: ChallengeType.daily,
      pointsReward: 100,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      requirements: {'toursCompleted': 1},
      iconPath: 'assets/icons/tour.png',
    ),
    Challenge(
      id: 'weekly_photographer',
      title: 'Weekly Photographer',
      description: 'Upload 10 photos from different movie locations this week',
      type: ChallengeType.weekly,
      pointsReward: 500,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      requirements: {'photosUploaded': 10, 'uniqueLocations': 5},
      iconPath: 'assets/icons/camera.png',
    ),
    Challenge(
      id: 'monthly_social',
      title: 'Social Butterfly',
      description: 'Share 20 locations and get 50 likes',
      type: ChallengeType.monthly,
      pointsReward: 1000,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      requirements: {'locationsShared': 20, 'likesReceived': 50},
      iconPath: 'assets/icons/social.png',
    ),
    Challenge(
      id: 'special_marathon',
      title: 'Movie Marathon Master',
      description: 'Visit all locations from a single movie in one day',
      type: ChallengeType.special,
      pointsReward: 2000,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365)),
      requirements: {'movieLocationsVisited': 1},
      isSecret: true,
      iconPath: 'assets/icons/movie.png',
    ),
  ];

  Future<void> initialize() async {
    // TODO: Fetch challenges from backend
    _availableChallenges.addAll(_sampleChallenges);
    notifyListeners();
  }

  List<Challenge> getAvailableChallenges() {
    return _availableChallenges.where((c) => c.isActive).toList();
  }

  List<UserChallenge> getUserChallenges(String userId) {
    return _userChallenges.values.toList();
  }

  List<UserChallenge> getActiveChallenges(String userId) {
    return _userChallenges.values
        .where((c) =>
            c.status == ChallengeStatus.inProgress && c.challenge.isActive)
        .toList();
  }

  Future<void> startChallenge(String userId, String challengeId) async {
    final challenge =
        _availableChallenges.firstWhere((c) => c.id == challengeId);

    if (!challenge.isActive) {
      throw Exception('Challenge is not active');
    }

    if (_userChallenges.containsKey(challengeId)) {
      throw Exception('Challenge already started');
    }

    // Check prerequisites
    if (challenge.prerequisiteChallenges != null) {
      for (final prereqId in challenge.prerequisiteChallenges!) {
        final prereq = _userChallenges[prereqId];
        if (prereq == null || prereq.status != ChallengeStatus.completed) {
          throw Exception('Prerequisites not met');
        }
      }
    }

    _userChallenges[challengeId] = UserChallenge.notStarted(challenge).start();
    notifyListeners();
  }

  Future<void> updateChallengeProgress(
    String userId,
    String challengeId,
    Map<String, dynamic> progress,
  ) async {
    final userChallenge = _userChallenges[challengeId];
    if (userChallenge == null) {
      throw Exception('Challenge not started');
    }

    final updatedChallenge = userChallenge.updateProgress(progress);
    _userChallenges[challengeId] = updatedChallenge;

    // If challenge was just completed
    if (updatedChallenge.status == ChallengeStatus.completed &&
        userChallenge.status != ChallengeStatus.completed) {
      await _onChallengeCompleted(userId, updatedChallenge);
    }

    notifyListeners();
  }

  Future<void> _onChallengeCompleted(
      String userId, UserChallenge challenge) async {
    // Add points
    SocialService().addPoints(userId, challenge.challenge.pointsReward);

    // Check for achievements
    if (challenge.challenge.type == ChallengeType.special) {
      await AchievementService().checkAndUnlockAchievement(
        userId,
        'challenge_master',
        {'specialChallengesCompleted': 1},
      );
    }

    // Update stats
    final stats = {
      'challengesCompleted': 1,
      'pointsEarned': challenge.challenge.pointsReward,
    };
    await SocialService().updateUserStats(userId, stats);
  }

  void checkExpiredChallenges() {
    bool hasChanges = false;
    final now = DateTime.now();

    for (final challenge in _userChallenges.values) {
      if (challenge.status == ChallengeStatus.inProgress &&
          now.isAfter(challenge.challenge.endDate)) {
        _userChallenges[challenge.challenge.id] = UserChallenge(
          challenge: challenge.challenge,
          status: ChallengeStatus.expired,
          progress: challenge.progress,
          startedAt: challenge.startedAt,
          userProgress: challenge.userProgress,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<void> refreshChallenges() async {
    // TODO: Fetch new challenges from backend
    checkExpiredChallenges();
  }
}
