import 'package:flutter/material.dart';
import 'dart:convert';

class OfflineData {
  final Map<String, dynamic> locationData;
  final Map<String, dynamic> triviaData;
  final Map<String, dynamic> achievementData;
  final DateTime lastSync;

  OfflineData({
    required this.locationData,
    required this.triviaData,
    required this.achievementData,
    required this.lastSync,
  });

  Map<String, dynamic> toJson() => {
        'locationData': locationData,
        'triviaData': triviaData,
        'achievementData': achievementData,
        'lastSync': lastSync.toIso8601String(),
      };

  factory OfflineData.fromJson(Map<String, dynamic> json) => OfflineData(
        locationData: json['locationData'],
        triviaData: json['triviaData'],
        achievementData: json['achievementData'],
        lastSync: DateTime.parse(json['lastSync']),
      );
}

class OfflineService extends ChangeNotifier {
  bool _isOfflineMode = false;
  OfflineData? _cachedData;
  final Duration _maxCacheAge = const Duration(days: 7);

  bool get isOfflineMode => _isOfflineMode;
  bool get hasCachedData => _cachedData != null;
  DateTime? get lastSyncTime => _cachedData?.lastSync;

  Future<void> toggleOfflineMode(bool enable) async {
    if (enable && !hasCachedData) {
      await _downloadOfflineData();
    }
    _isOfflineMode = enable;
    notifyListeners();
  }

  Future<void> _downloadOfflineData() async {
    try {
      // Simulated API calls - replace with actual endpoints
      final locations = await _fetchLocationData();
      final trivia = await _fetchTriviaData();
      final achievements = await _fetchAchievementData();

      _cachedData = OfflineData(
        locationData: locations,
        triviaData: trivia,
        achievementData: achievements,
        lastSync: DateTime.now(),
      );

      await _saveCacheToStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error downloading offline data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _fetchLocationData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return {
      'version': '1.0',
      'locations': [
        {
          'id': 'central_perk',
          'name': 'Central Perk',
          'lat': 40.7326,
          'lng': -74.0063,
          'images': ['central_perk_1.jpg', 'central_perk_2.jpg'],
          'details': 'Famous coffee shop from Friends...',
        },
        // Add more locations
      ],
    };
  }

  Future<Map<String, dynamic>> _fetchTriviaData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return {
      'version': '1.0',
      'trivia': [
        {
          'id': 'friends_1',
          'locationId': 'central_perk',
          'question': 'What was the name of the Central Perk manager?',
          'options': ['Gunther', 'Terry', 'Eddie', 'Mark'],
          'correctOption': 0,
        },
        // Add more trivia
      ],
    };
  }

  Future<Map<String, dynamic>> _fetchAchievementData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return {
      'version': '1.0',
      'achievements': [
        {
          'id': 'first_visit',
          'title': 'Movie Scout',
          'description': 'Visit your first filming location',
          'points': 10,
        },
        // Add more achievements
      ],
    };
  }

  Future<void> _saveCacheToStorage() async {
    if (_cachedData == null) return;

    // Here you would implement actual storage logic
    // For example, using shared_preferences or hive
    final json = jsonEncode(_cachedData!.toJson());
    debugPrint('Saving cache to storage: $json');
  }

  Future<void> loadCacheFromStorage() async {
    // Here you would implement actual storage loading logic
    // For now, we'll just simulate it
    await Future.delayed(const Duration(milliseconds: 500));
  }

  bool isCacheExpired() {
    if (_cachedData == null) return true;
    final age = DateTime.now().difference(_cachedData!.lastSync);
    return age > _maxCacheAge;
  }

  Future<void> clearCache() async {
    _cachedData = null;
    // Here you would implement actual cache clearing logic
    notifyListeners();
  }

  Map<String, dynamic>? getOfflineData(String dataType) {
    if (!_isOfflineMode || _cachedData == null) return null;

    switch (dataType) {
      case 'locations':
        return _cachedData!.locationData;
      case 'trivia':
        return _cachedData!.triviaData;
      case 'achievements':
        return _cachedData!.achievementData;
      default:
        return null;
    }
  }
}
