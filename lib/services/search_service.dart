import 'package:flutter/material.dart';

class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.metadata = const {},
  });
}

enum SearchResultType {
  movie,
  tvShow,
  location,
  tour,
  user,
}

class SearchFilters {
  final List<String>? genres;
  final int? yearStart;
  final int? yearEnd;
  final double? minRating;
  final double? maxDistance;
  final List<SearchResultType>? types;
  final String? sortBy;
  final bool sortAscending;

  SearchFilters({
    this.genres,
    this.yearStart,
    this.yearEnd,
    this.minRating,
    this.maxDistance,
    this.types,
    this.sortBy,
    this.sortAscending = true,
  });

  SearchFilters copyWith({
    List<String>? genres,
    int? yearStart,
    int? yearEnd,
    double? minRating,
    double? maxDistance,
    List<SearchResultType>? types,
    String? sortBy,
    bool? sortAscending,
  }) {
    return SearchFilters(
      genres: genres ?? this.genres,
      yearStart: yearStart ?? this.yearStart,
      yearEnd: yearEnd ?? this.yearEnd,
      minRating: minRating ?? this.minRating,
      maxDistance: maxDistance ?? this.maxDistance,
      types: types ?? this.types,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class SearchService extends ChangeNotifier {
  final List<String> _recentSearches = [];
  final Map<String, List<String>> _userSearchHistory = {};
  final int _maxRecentSearches = 10;

  // Available filter options
  final List<String> availableGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
  ];

  final List<String> sortOptions = [
    'relevance',
    'rating',
    'distance',
    'popularity',
    'year',
  ];

  // Search methods
  Future<List<SearchResult>> search(
    String query, {
    SearchFilters? filters,
    String? userId,
  }) async {
    if (query.isNotEmpty && userId != null) {
      _addToRecentSearches(query, userId);
    }

    // TODO: Implement actual search logic
    // This is a placeholder that returns empty results
    return [];
  }

  Future<List<SearchResult>> getRecommendations({
    required String userId,
    SearchResultType? type,
  }) async {
    // TODO: Implement recommendation logic based on user preferences and history
    return [];
  }

  // Recent searches management
  List<String> getRecentSearches(String userId) {
    return _userSearchHistory[userId] ?? [];
  }

  void clearRecentSearches(String userId) {
    _userSearchHistory.remove(userId);
    notifyListeners();
  }

  void _addToRecentSearches(String query, String userId) {
    final searches = _userSearchHistory[userId] ?? [];
    searches.remove(query); // Remove if exists to avoid duplicates
    searches.insert(0, query);
    
    if (searches.length > _maxRecentSearches) {
      searches.removeLast();
    }

    _userSearchHistory[userId] = searches;
    notifyListeners();
  }

  // Filter helpers
  List<SearchResult> _applyFilters(
    List<SearchResult> results,
    SearchFilters filters,
  ) {
    var filteredResults = List<SearchResult>.from(results);

    // Apply type filter
    if (filters.types != null && filters.types!.isNotEmpty) {
      filteredResults = filteredResults
          .where((result) => filters.types!.contains(result.type))
          .toList();
    }

    // Apply genre filter
    if (filters.genres != null && filters.genres!.isNotEmpty) {
      filteredResults = filteredResults.where((result) {
        final resultGenres = result.metadata['genres'] as List<String>? ?? [];
        return filters.genres!.any((genre) => resultGenres.contains(genre));
      }).toList();
    }

    // Apply year filter
    if (filters.yearStart != null || filters.yearEnd != null) {
      filteredResults = filteredResults.where((result) {
        final year = result.metadata['year'] as int?;
        if (year == null) return false;
        if (filters.yearStart != null && year < filters.yearStart!) return false;
        if (filters.yearEnd != null && year > filters.yearEnd!) return false;
        return true;
      }).toList();
    }

    // Apply rating filter
    if (filters.minRating != null) {
      filteredResults = filteredResults.where((result) {
        final rating = result.metadata['rating'] as double?;
        return rating != null && rating >= filters.minRating!;
      }).toList();
    }

    // Apply distance filter
    if (filters.maxDistance != null) {
      filteredResults = filteredResults.where((result) {
        final distance = result.metadata['distance'] as double?;
        return distance != null && distance <= filters.maxDistance!;
      }).toList();
    }

    // Apply sorting
    if (filters.sortBy != null) {
      filteredResults.sort((a, b) {
        dynamic valueA = a.metadata[filters.sortBy];
        dynamic valueB = b.metadata[filters.sortBy];

        if (valueA == null || valueB == null) return 0;

        int comparison;
        if (valueA is num && valueB is num) {
          comparison = valueA.compareTo(valueB);
        } else {
          comparison = valueA.toString().compareTo(valueB.toString());
        }

        return filters.sortAscending ? comparison : -comparison;
      });
    }

    return filteredResults;
  }

  // Analytics and trending
  Future<List<String>> getTrendingSearches() async {
    // TODO: Implement trending searches based on user activity
    return [
      'Harry Potter',
      'Friends',
      'Marvel',
      'Game of Thrones',
      'Breaking Bad',
    ];
  }

  Future<Map<String, int>> getPopularGenres() async {
    // TODO: Implement popular genres based on search history
    return {
      'Action': 100,
      'Drama': 80,
      'Comedy': 60,
      'Sci-Fi': 40,
      'Romance': 20,
    };
  }

  // Auto-complete suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];

    // TODO: Implement actual auto-complete logic
    return [
      '$query in Movies',
      '$query in TV Shows',
      '$query Locations',
      '$query Tours',
    ];
  }
}
