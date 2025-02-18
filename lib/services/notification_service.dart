import 'package:flutter/material.dart';

enum NotificationType {
  achievement,
  tourComplete,
  locationVisited,
  triviaComplete,
  riddleSolved,
  levelUp,
  newLocation,
  specialEvent,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.imageUrl,
    this.data,
    this.isRead = false,
  });
}

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  final int _maxNotifications = 50;

  List<AppNotification> get allNotifications => _notifications;
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      data: data,
    );

    _notifications.insert(0, notification);

    // Keep only the most recent notifications
    if (_notifications.length > _maxNotifications) {
      _notifications.removeLast();
    }

    notifyListeners();
    _showNotificationOverlay(notification);
  }

  void markAsRead(String notificationId) {
    final notification = _findNotificationById(notificationId);
    if (notification != null && !notification.isRead) {
      notification.isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    var hasUnread = false;
    for (final notification in _notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
        hasUnread = true;
      }
    }
    if (hasUnread) {
      notifyListeners();
    }
  }

  void clearAll() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      notifyListeners();
    }
  }

  AppNotification? _findNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  void _showNotificationOverlay(AppNotification notification) {
    // This method would be called by the UI layer to show a custom overlay
    debugPrint('Showing notification: ${notification.title}');
  }

  // Convenience methods for different notification types
  void showAchievementUnlocked(String achievementTitle, int points) {
    addNotification(
      title: 'Achievement Unlocked! 🏆',
      message: '$achievementTitle (+$points pts)',
      type: NotificationType.achievement,
      data: {'points': points},
    );
  }

  void showTourCompleted(String tourName, int points) {
    addNotification(
      title: 'Tour Completed! 🎯',
      message: 'You completed the $tourName tour! (+$points pts)',
      type: NotificationType.tourComplete,
      data: {'points': points},
    );
  }

  void showLocationVisited(String locationName) {
    addNotification(
      title: 'New Location Visited! 📍',
      message: 'You visited $locationName',
      type: NotificationType.locationVisited,
    );
  }

  void showTriviaCompleted(String locationName, int points) {
    addNotification(
      title: 'Trivia Master! 🎲',
      message: 'You completed trivia for $locationName (+$points pts)',
      type: NotificationType.triviaComplete,
      data: {'points': points},
    );
  }

  void showRiddleSolved(String riddleName, int points) {
    addNotification(
      title: 'Riddle Solved! 🔍',
      message: 'You solved the $riddleName riddle! (+$points pts)',
      type: NotificationType.riddleSolved,
      data: {'points': points},
    );
  }

  void showLevelUp(String newRank) {
    addNotification(
      title: 'Level Up! ⭐',
      message: 'You\'ve reached the rank of $newRank!',
      type: NotificationType.levelUp,
      data: {'rank': newRank},
    );
  }

  void showNewLocation(String locationName, String movieTitle) {
    addNotification(
      title: 'New Location Added! 🎬',
      message: 'Check out $locationName from $movieTitle',
      type: NotificationType.newLocation,
      data: {'movie': movieTitle},
    );
  }

  void showSpecialEvent(String eventName, String description) {
    addNotification(
      title: 'Special Event! 🎉',
      message: '$eventName: $description',
      type: NotificationType.specialEvent,
      data: {'event': eventName},
    );
  }
}
