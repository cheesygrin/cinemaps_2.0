import 'package:flutter/material.dart';
import 'achievement_service.dart';

class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final List<String> followers;
  final List<String> following;
  final int points;
  final int rank;
  final List<String> completedTours;
  final List<String> visitedLocations;
  final List<String> achievements;

  UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.followers = const [],
    this.following = const [],
    this.points = 0,
    this.rank = 0,
    this.completedTours = const [],
    this.visitedLocations = const [],
    this.achievements = const [],
  });
}

class ActivityItem {
  final String id;
  final String userId;
  final String type;
  final String mediaType;
  final String mediaId;
  final DateTime timestamp;

  const ActivityItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.mediaType,
    required this.mediaId,
    required this.timestamp,
  });
}

enum UserActivityType {
  visitedLocation,
  completedTour,
  earnedAchievement,
  uploadedPhoto,
  likedPhoto,
  commentedPhoto,
  startedFollowing,
  sharedLocation,
  sharedTour,
  likedMovie,
  sharedMovie,
  checkedInMovie,
  commentedMovie,
  likedComment,
  repliedToComment,
}

class Comment {
  final String id;
  final String userId;
  final String content;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
  });
}

class Photo {
  final String id;
  final String userId;
  final String locationId;
  final String url;
  final String caption;
  final List<String> tags;
  final DateTime timestamp;
  int likes;
  List<Comment> comments;

  Photo({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.url,
    required this.caption,
    required this.tags,
    required this.timestamp,
    this.likes = 0,
    this.comments = const [],
  });
}

class SocialService extends ChangeNotifier {
  final Map<String, UserProfile> _users = {};
  final Map<String, List<ActivityItem>> _userActivity = {};
  final Map<String, List<Photo>> _locationPhotos = {};
  final Map<String, List<Photo>> _userPhotos = {};
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final List<ActivityItem> _globalFeed = [];

  // User Profile Management
  Map<String, UserProfile> getUsers() {
    // TODO: Implement real user fetching
    return _users;
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    return _users[userId];
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? avatarUrl,
    String? bio,
  }) async {
    final existingProfile = _users[userId];
    if (existingProfile != null) {
      _users[userId] = UserProfile(
        id: userId,
        username: username ?? existingProfile.username,
        avatarUrl: avatarUrl ?? existingProfile.avatarUrl,
        bio: bio ?? existingProfile.bio,
        followers: existingProfile.followers,
        following: existingProfile.following,
        points: existingProfile.points,
        rank: existingProfile.rank,
        completedTours: existingProfile.completedTours,
        visitedLocations: existingProfile.visitedLocations,
        achievements: existingProfile.achievements,
      );
      notifyListeners();
    }
  }

  // Following Management
  Future<void> followUser(String followerId, String targetUserId) async {
    if (followerId == targetUserId) return;

    _followers.update(
      targetUserId,
      (followers) => [...followers, followerId],
      ifAbsent: () => [followerId],
    );

    _following.update(
      followerId,
      (following) => [...following, targetUserId],
      ifAbsent: () => [targetUserId],
    );

    await addActivity(
      userId: followerId,
      type: UserActivityType.startedFollowing,
      targetId: targetUserId,
    );

    notifyListeners();
  }

  Future<void> unfollowUser(String followerId, String targetUserId) async {
    _followers[targetUserId]?.remove(followerId);
    _following[followerId]?.remove(targetUserId);
    notifyListeners();
  }

  List<String> getFollowers(String userId) {
    return _followers[userId] ?? [];
  }

  Future<void> sendNotification({
    required String userId,
    required String type,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Implement notification sending
    print('Notification sent to $userId: $message');
  }

  List<String> getFollowing(String userId) {
    return _following[userId] ?? [];
  }

  Future<void> createPost({required String content, String? imageUrl}) async {
    // TODO: Implement real post creation with backend
    // For now, just simulate a delay
    await Future.delayed(const Duration(seconds: 1));
  }

  // Activity Feed
  Future<List<ActivityItem>> getUserFeed(String userId) async {
    final following = getFollowing(userId);
    return _globalFeed
        .where((activity) => following.contains(activity.userId))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<ActivityItem>> getUserActivity(String userId) async {
    // TODO: Implement actual user activity retrieval
    return [];
  }

  Future<List<ActivityItem>> getFriendsActivity(String userId) async {
    // TODO: Implement actual friends' activity retrieval
    return [];
  }

  final AchievementService achievementService = AchievementService();

  Future<void> addActivity({
    required String userId,
    required UserActivityType type,
    required String targetId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final activity = ActivityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: type.toString(),
      mediaType: '',
      mediaId: '',
      timestamp: DateTime.now(),
    );

    // Add to user's activity
    _userActivity.update(
      userId,
      (activities) => [activity, ...activities],
      ifAbsent: () => [activity],
    );

    // Add to global feed
    _globalFeed.insert(0, activity);
    if (_globalFeed.length > 1000) {
      _globalFeed.removeLast();
    }

    // Update user points based on activity type
    int points = _getPointsForActivity(type);
    if (points > 0) {
      addPoints(userId, points);
    }

    // Track achievement progress
    switch (type) {
      case UserActivityType.visitedLocation:
        achievementService.trackProgress(AchievementType.visitLocation);
        break;
      case UserActivityType.uploadedPhoto:
        achievementService.trackProgress(AchievementType.uploadPhoto);
        break;
      case UserActivityType.likedPhoto:
        achievementService.trackProgress(AchievementType.likePhoto);
        break;
      case UserActivityType.commentedPhoto:
        achievementService.trackProgress(AchievementType.commentPhoto);
        break;
      case UserActivityType.checkedInMovie:
        achievementService.trackProgress(AchievementType.checkInMovie);
        break;
      case UserActivityType.sharedMovie:
        achievementService.trackProgress(AchievementType.shareMovie);
        break;
      case UserActivityType.likedMovie:
        achievementService.trackProgress(AchievementType.likeMovie);
        break;
      case UserActivityType.commentedMovie:
        achievementService.trackProgress(AchievementType.commentMovie);
        break;
      default:
        break;
    }

    notifyListeners();
  }

  int _getPointsForActivity(UserActivityType type) {
    switch (type) {
      case UserActivityType.visitedLocation:
        return 50;
      case UserActivityType.completedTour:
        return 200;
      case UserActivityType.earnedAchievement:
        return 100;
      case UserActivityType.uploadedPhoto:
        return 30;
      case UserActivityType.likedPhoto:
        return 5;
      case UserActivityType.commentedPhoto:
        return 10;
      case UserActivityType.startedFollowing:
        return 5;
      case UserActivityType.sharedLocation:
        return 20;
      case UserActivityType.sharedTour:
        return 30;
      case UserActivityType.likedMovie:
        return 5;
      case UserActivityType.sharedMovie:
        return 20;
      case UserActivityType.checkedInMovie:
        return 40;
      case UserActivityType.commentedMovie:
        return 15;
      case UserActivityType.likedComment:
        return 5;
      case UserActivityType.repliedToComment:
        return 10;
    }
  }

  // Sharing
  Future<void> shareLocation(String userId, String locationId) async {
    await addActivity(
      userId: userId,
      type: UserActivityType.sharedLocation,
      targetId: locationId,
    );
  }

  Future<void> shareTour(String userId, String tourId) async {
    await addActivity(
      userId: userId,
      type: UserActivityType.sharedTour,
      targetId: tourId,
    );
  }

  // Photo management
  List<Photo> getPhotos(String locationId) {
    return _locationPhotos[locationId] ?? [];
  }

  List<Photo> getUserPhotos(String userId) {
    return _userPhotos[userId] ?? [];
  }

  Future<void> uploadPhoto({
    required String userId,
    required String locationId,
    required String photoUrl,
    required String caption,
    required List<String> tags,
  }) async {
    final photo = Photo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      locationId: locationId,
      url: photoUrl,
      caption: caption,
      tags: tags,
      timestamp: DateTime.now(),
      likes: 0,
      comments: [],
    );

    // Add to location photos
    _locationPhotos.update(
      locationId,
      (photos) => [photo, ...photos],
      ifAbsent: () => [photo],
    );

    // Add to user photos
    _userPhotos.update(
      userId,
      (photos) => [photo, ...photos],
      ifAbsent: () => [photo],
    );

    // Add activity
    await addActivity(
      userId: userId,
      type: UserActivityType.uploadedPhoto,
      targetId: photo.id,
      metadata: {
        'locationId': locationId,
        'photoUrl': photoUrl,
        'caption': caption,
      },
    );

    notifyListeners();
  }

  Future<void> likePhoto(String userId, Photo photo) async {
    photo.likes++;
    await addActivity(
      userId: userId,
      type: UserActivityType.likedPhoto,
      targetId: photo.id,
      metadata: {
        'locationId': photo.locationId,
        'photoUrl': photo.url,
      },
    );
    notifyListeners();
  }

  Future<void> likeComment(String userId, Comment comment) async {
    await addActivity(
      userId: userId,
      type: UserActivityType.likedComment,
      targetId: comment.id,
      metadata: {
        'commentId': comment.id,
        'commentContent': comment.content,
      },
    );
    notifyListeners();
  }

  Future<void> replyToComment(
      String userId, Comment parentComment, String content) async {
    final reply = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: content,
      timestamp: DateTime.now(),
    );

    await addActivity(
      userId: userId,
      type: UserActivityType.repliedToComment,
      targetId: parentComment.id,
      metadata: {
        'parentCommentId': parentComment.id,
        'replyContent': content,
      },
    );
    notifyListeners();
  }

  Future<void> commentOnPhoto(
      String userId, Photo photo, String comment) async {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      content: comment,
      timestamp: DateTime.now(),
    );
    photo.comments.add(newComment);
    await addActivity(
      userId: userId,
      type: UserActivityType.commentedPhoto,
      targetId: photo.id,
      metadata: {
        'locationId': photo.locationId,
        'photoUrl': photo.url,
        'comment': comment,
      },
    );
    notifyListeners();
  }

  // Points and Achievements
  void addPoints(String userId, int points) {
    final profile = _users[userId];
    if (profile != null) {
      _users[userId] = UserProfile(
        id: userId,
        username: profile.username,
        avatarUrl: profile.avatarUrl,
        bio: profile.bio,
        followers: profile.followers,
        following: profile.following,
        points: profile.points + points,
        rank: profile.rank,
        completedTours: profile.completedTours,
        visitedLocations: profile.visitedLocations,
        achievements: profile.achievements,
      );
      notifyListeners();
    }
  }

  Future<void> addAchievement(String userId, String achievementId) async {
    final profile = _users[userId];
    if (profile != null && !profile.achievements.contains(achievementId)) {
      final achievements = List<String>.from(profile.achievements)
        ..add(achievementId);
      _users[userId] = UserProfile(
        id: userId,
        username: profile.username,
        avatarUrl: profile.avatarUrl,
        bio: profile.bio,
        followers: profile.followers,
        following: profile.following,
        points: profile.points,
        rank: profile.rank,
        completedTours: profile.completedTours,
        visitedLocations: profile.visitedLocations,
        achievements: achievements,
      );

      await addActivity(
        userId: userId,
        type: UserActivityType.earnedAchievement,
        targetId: achievementId,
      );

      notifyListeners();
    }
  }

  // Search
  Future<List<UserProfile>> searchUsers(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _users.values
        .where((user) =>
            user.username.toLowerCase().contains(lowercaseQuery) ||
            (user.bio?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }
}
