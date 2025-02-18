enum ChallengeType {
  daily,
  weekly,
  monthly,
  special,
}

enum ChallengeStatus {
  notStarted,
  inProgress,
  completed,
  expired,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int pointsReward;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> requirements;
  final List<String>? prerequisiteChallenges;
  final String? iconPath;
  final bool isSecret;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsReward,
    required this.startDate,
    required this.endDate,
    required this.requirements,
    this.prerequisiteChallenges,
    this.iconPath,
    this.isSecret = false,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Duration get timeRemaining {
    return endDate.difference(DateTime.now());
  }

  String get formattedTimeRemaining {
    final duration = timeRemaining;
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

class UserChallenge {
  final Challenge challenge;
  final ChallengeStatus status;
  final double progress;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> userProgress;

  const UserChallenge({
    required this.challenge,
    required this.status,
    required this.progress,
    this.startedAt,
    this.completedAt,
    required this.userProgress,
  });

  factory UserChallenge.notStarted(Challenge challenge) {
    return UserChallenge(
      challenge: challenge,
      status: ChallengeStatus.notStarted,
      progress: 0.0,
      userProgress: {},
    );
  }

  UserChallenge start() {
    return UserChallenge(
      challenge: challenge,
      status: ChallengeStatus.inProgress,
      progress: 0.0,
      startedAt: DateTime.now(),
      userProgress: {},
    );
  }

  UserChallenge updateProgress(Map<String, dynamic> newProgress) {
    final updatedProgress = {...userProgress, ...newProgress};
    double progressPercentage = 0.0;

    // Calculate progress based on challenge requirements
    for (final req in challenge.requirements.entries) {
      final current = updatedProgress[req.key] ?? 0;
      final target = req.value;
      progressPercentage += (current / target).clamp(0.0, 1.0);
    }

    progressPercentage /= challenge.requirements.length;

    final newStatus = progressPercentage >= 1.0
        ? ChallengeStatus.completed
        : !challenge.isActive
            ? ChallengeStatus.expired
            : ChallengeStatus.inProgress;

    return UserChallenge(
      challenge: challenge,
      status: newStatus,
      progress: progressPercentage,
      startedAt: startedAt,
      completedAt:
          newStatus == ChallengeStatus.completed ? DateTime.now() : null,
      userProgress: updatedProgress,
    );
  }
}
