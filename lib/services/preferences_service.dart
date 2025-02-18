import 'package:flutter/material.dart';

class UserPreferences {
  final bool darkMode;
  final bool autoPlayMusic;
  final bool showNotifications;
  final bool vibrationEnabled;
  final bool autoDownloadMaps;
  final String defaultMapType;
  final int searchRadius;
  final List<String> favoriteGenres;
  final Map<String, bool> featureFlags;

  UserPreferences({
    this.darkMode = true,
    this.autoPlayMusic = true,
    this.showNotifications = true,
    this.vibrationEnabled = true,
    this.autoDownloadMaps = false,
    this.defaultMapType = 'retro',
    this.searchRadius = 5000,
    this.favoriteGenres = const ['Action', 'Comedy', 'Drama'],
    this.featureFlags = const {
      'tours': true,
      'trivia': true,
      'riddles': true,
      'achievements': true,
      'seasonalThemes': true,
    },
  });

  UserPreferences copyWith({
    bool? darkMode,
    bool? autoPlayMusic,
    bool? showNotifications,
    bool? vibrationEnabled,
    bool? autoDownloadMaps,
    String? defaultMapType,
    int? searchRadius,
    List<String>? favoriteGenres,
    Map<String, bool>? featureFlags,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      autoPlayMusic: autoPlayMusic ?? this.autoPlayMusic,
      showNotifications: showNotifications ?? this.showNotifications,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoDownloadMaps: autoDownloadMaps ?? this.autoDownloadMaps,
      defaultMapType: defaultMapType ?? this.defaultMapType,
      searchRadius: searchRadius ?? this.searchRadius,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      featureFlags: featureFlags ?? this.featureFlags,
    );
  }

  Map<String, dynamic> toJson() => {
    'darkMode': darkMode,
    'autoPlayMusic': autoPlayMusic,
    'showNotifications': showNotifications,
    'vibrationEnabled': vibrationEnabled,
    'autoDownloadMaps': autoDownloadMaps,
    'defaultMapType': defaultMapType,
    'searchRadius': searchRadius,
    'favoriteGenres': favoriteGenres,
    'featureFlags': featureFlags,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] ?? true,
      autoPlayMusic: json['autoPlayMusic'] ?? true,
      showNotifications: json['showNotifications'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      autoDownloadMaps: json['autoDownloadMaps'] ?? false,
      defaultMapType: json['defaultMapType'] ?? 'retro',
      searchRadius: json['searchRadius'] ?? 5000,
      favoriteGenres: List<String>.from(json['favoriteGenres'] ?? []),
      featureFlags: Map<String, bool>.from(json['featureFlags'] ?? {}),
    );
  }
}

class PreferencesService extends ChangeNotifier {
  UserPreferences _preferences = UserPreferences();
  final List<String> _availableMapTypes = [
    'retro',
    'night',
    'aubergine',
    'silver',
    'standard',
  ];

  final List<String> _availableGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'Horror',
    'Musical',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Western',
  ];

  UserPreferences get preferences => _preferences;
  List<String> get availableMapTypes => _availableMapTypes;
  List<String> get availableGenres => _availableGenres;

  Future<void> loadPreferences() async {
    // Here you would implement actual storage loading logic
    // For now, we'll just use the defaults
    debugPrint('Loading preferences...');
  }

  Future<void> savePreferences() async {
    // Here you would implement actual storage saving logic
    debugPrint('Saving preferences: ${_preferences.toJson()}');
  }

  void updateDarkMode(bool value) {
    _preferences = _preferences.copyWith(darkMode: value);
    notifyListeners();
    savePreferences();
  }

  void updateAutoPlayMusic(bool value) {
    _preferences = _preferences.copyWith(autoPlayMusic: value);
    notifyListeners();
    savePreferences();
  }

  void updateShowNotifications(bool value) {
    _preferences = _preferences.copyWith(showNotifications: value);
    notifyListeners();
    savePreferences();
  }

  void updateVibrationEnabled(bool value) {
    _preferences = _preferences.copyWith(vibrationEnabled: value);
    notifyListeners();
    savePreferences();
  }

  void updateAutoDownloadMaps(bool value) {
    _preferences = _preferences.copyWith(autoDownloadMaps: value);
    notifyListeners();
    savePreferences();
  }

  void updateDefaultMapType(String value) {
    if (_availableMapTypes.contains(value)) {
      _preferences = _preferences.copyWith(defaultMapType: value);
      notifyListeners();
      savePreferences();
    }
  }

  void updateSearchRadius(int value) {
    if (value >= 1000 && value <= 50000) {
      _preferences = _preferences.copyWith(searchRadius: value);
      notifyListeners();
      savePreferences();
    }
  }

  void addFavoriteGenre(String genre) {
    if (_availableGenres.contains(genre) &&
        !_preferences.favoriteGenres.contains(genre)) {
      final newGenres = List<String>.from(_preferences.favoriteGenres)
        ..add(genre);
      _preferences = _preferences.copyWith(favoriteGenres: newGenres);
      notifyListeners();
      savePreferences();
    }
  }

  void removeFavoriteGenre(String genre) {
    if (_preferences.favoriteGenres.contains(genre)) {
      final newGenres = List<String>.from(_preferences.favoriteGenres)
        ..remove(genre);
      _preferences = _preferences.copyWith(favoriteGenres: newGenres);
      notifyListeners();
      savePreferences();
    }
  }

  void updateFeatureFlag(String feature, bool enabled) {
    if (_preferences.featureFlags.containsKey(feature)) {
      final newFlags = Map<String, bool>.from(_preferences.featureFlags)
        ..[feature] = enabled;
      _preferences = _preferences.copyWith(featureFlags: newFlags);
      notifyListeners();
      savePreferences();
    }
  }

  bool isFeatureEnabled(String feature) {
    return _preferences.featureFlags[feature] ?? false;
  }

  void resetToDefaults() {
    _preferences = UserPreferences();
    notifyListeners();
    savePreferences();
  }
}
