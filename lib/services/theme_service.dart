import 'package:flutter/material.dart';

enum Season {
  winter,
  spring,
  summer,
  fall,
  halloween,
  christmas,
}

class SeasonalTheme {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String backgroundPattern;
  final List<String> iconSet;
  final String musicTrack;
  final List<String> specialEffects;

  SeasonalTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundPattern,
    required this.iconSet,
    required this.musicTrack,
    required this.specialEffects,
  });
}

class ThemeService extends ChangeNotifier {
  Season _currentSeason = Season.winter;
  bool _isAutoTheme = true;

  final Map<Season, SeasonalTheme> _themes = {
    Season.winter: SeasonalTheme(
      name: 'Winter Wonderland',
      primaryColor: const Color(0xFF1B1B3A),
      secondaryColor: const Color(0xFF7B8CDE),
      accentColor: const Color(0xFFE8E8FF),
      backgroundPattern: 'assets/patterns/snowflakes.png',
      iconSet: ['snowflake', 'ice_crystal', 'winter_tree'],
      musicTrack: 'winter_ambience.mp3',
      specialEffects: ['snow_overlay', 'frost_borders'],
    ),
    Season.spring: SeasonalTheme(
      name: 'Spring Bloom',
      primaryColor: const Color(0xFF2D5A27),
      secondaryColor: const Color(0xFFFFB7C3),
      accentColor: const Color(0xFFFFE5D9),
      backgroundPattern: 'assets/patterns/cherry_blossoms.png',
      iconSet: ['flower', 'butterfly', 'spring_leaf'],
      musicTrack: 'spring_birds.mp3',
      specialEffects: ['falling_petals', 'rainbow_glow'],
    ),
    Season.summer: SeasonalTheme(
      name: 'Summer Vibes',
      primaryColor: const Color(0xFF1E88E5),
      secondaryColor: const Color(0xFFFFD700),
      accentColor: const Color(0xFFFF6B6B),
      backgroundPattern: 'assets/patterns/palm_leaves.png',
      iconSet: ['sun', 'beach', 'ice_cream'],
      musicTrack: 'beach_waves.mp3',
      specialEffects: ['heat_waves', 'sun_flare'],
    ),
    Season.fall: SeasonalTheme(
      name: 'Autumn Dreams',
      primaryColor: const Color(0xFF8B4513),
      secondaryColor: const Color(0xFFCD853F),
      accentColor: const Color(0xFFFF6B6B),
      backgroundPattern: 'assets/patterns/falling_leaves.png',
      iconSet: ['maple_leaf', 'acorn', 'pumpkin'],
      musicTrack: 'autumn_wind.mp3',
      specialEffects: ['falling_leaves', 'fog_overlay'],
    ),
    Season.halloween: SeasonalTheme(
      name: 'Spooky Season',
      primaryColor: const Color(0xFF2C003E),
      secondaryColor: const Color(0xFFFF6B00),
      accentColor: const Color(0xFF8B008B),
      backgroundPattern: 'assets/patterns/spooky.png',
      iconSet: ['ghost', 'pumpkin', 'bat'],
      musicTrack: 'spooky_ambience.mp3',
      specialEffects: ['floating_ghosts', 'lightning'],
    ),
    Season.christmas: SeasonalTheme(
      name: 'Holiday Magic',
      primaryColor: const Color(0xFF146B3A),
      secondaryColor: const Color(0xFFEA4630),
      accentColor: const Color(0xFFF8B229),
      backgroundPattern: 'assets/patterns/snowflakes_holiday.png',
      iconSet: ['christmas_tree', 'gift', 'candy_cane'],
      musicTrack: 'jingle_bells.mp3',
      specialEffects: ['snow_overlay', 'twinkling_lights'],
    ),
  };

  Season get currentSeason => _currentSeason;
  bool get isAutoTheme => _isAutoTheme;
  SeasonalTheme get currentTheme => _themes[_currentSeason]!;

  void setAutoTheme(bool value) {
    _isAutoTheme = value;
    if (_isAutoTheme) {
      _updateSeasonBasedOnDate();
    }
    notifyListeners();
  }

  void setSeason(Season season) {
    _isAutoTheme = false;
    _currentSeason = season;
    notifyListeners();
  }

  void _updateSeasonBasedOnDate() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // Special holiday checks
    if (month == 10 && day >= 1 && day <= 31) {
      _currentSeason = Season.halloween;
    } else if (month == 12 && day >= 1 && day <= 31) {
      _currentSeason = Season.christmas;
    } else {
      // Regular seasons
      switch (month) {
        case 12:
        case 1:
        case 2:
          _currentSeason = Season.winter;
          break;
        case 3:
        case 4:
        case 5:
          _currentSeason = Season.spring;
          break;
        case 6:
        case 7:
        case 8:
          _currentSeason = Season.summer;
          break;
        case 9:
        case 10:
        case 11:
          _currentSeason = Season.fall;
          break;
      }
    }
    notifyListeners();
  }

  void initialize() {
    if (_isAutoTheme) {
      _updateSeasonBasedOnDate();
    }
  }
}
