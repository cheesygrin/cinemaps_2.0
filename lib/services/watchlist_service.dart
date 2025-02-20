import 'package:flutter/foundation.dart';
import '../models/watchlist_item.dart';

class WatchlistService extends ChangeNotifier {
  final Map<String, List<WatchlistItem>> _userWatchlists = {};

  // Get all watchlist items for a user
  List<WatchlistItem> getWatchlist(String userId) {
    // Return empty list for now
    return [];
  }

  // Get filtered watchlist items
  List<WatchlistItem> getFilteredWatchlist(String userId, {
    WatchlistItemType? type,
    bool? isWatched,
  }) {
    final watchlist = getWatchlist(userId);
    return watchlist.where((item) {
      if (type != null && item.type != type) return false;
      if (isWatched != null && item.isWatched != isWatched) return false;
      return true;
    }).toList();
  }

  // Add item to watchlist
  Future<void> addToWatchlist({
    required String userId,
    required String mediaId,
    required WatchlistItemType type,
    String? note,
  }) async {
    final watchlist = _userWatchlists[userId] ?? [];
    
    // Check if already in watchlist
    if (watchlist.any((item) => item.mediaId == mediaId)) {
      return;
    }

    final item = WatchlistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      mediaId: mediaId,
      type: type,
      addedAt: DateTime.now(),
      note: note,
    );

    watchlist.add(item);
    _userWatchlists[userId] = watchlist;
    notifyListeners();
  }

  // Remove item from watchlist
  Future<void> removeFromWatchlist(String userId, String mediaId) async {
    final watchlist = _userWatchlists[userId] ?? [];
    watchlist.removeWhere((item) => item.mediaId == mediaId);
    _userWatchlists[userId] = watchlist;
    notifyListeners();
  }

  // Mark item as watched
  Future<void> markAsWatched(String userId, String mediaId) async {
    final watchlist = _userWatchlists[userId] ?? [];
    final index = watchlist.indexWhere((item) => item.mediaId == mediaId);
    
    if (index == -1) return;

    final updatedItem = watchlist[index].copyWith(
      isWatched: true,
      watchedAt: DateTime.now(),
    );

    watchlist[index] = updatedItem;
    _userWatchlists[userId] = watchlist;
    notifyListeners();
  }

  // Update note
  Future<void> updateNote(String userId, String mediaId, String note) async {
    final watchlist = _userWatchlists[userId] ?? [];
    final index = watchlist.indexWhere((item) => item.mediaId == mediaId);
    
    if (index == -1) return;

    final updatedItem = watchlist[index].copyWith(note: note);
    watchlist[index] = updatedItem;
    _userWatchlists[userId] = watchlist;
    notifyListeners();
  }

  // Check if media is in watchlist
  bool isInWatchlist(String userId, String mediaId) {
    final watchlist = _userWatchlists[userId] ?? [];
    return watchlist.any((item) => item.mediaId == mediaId);
  }

  // Get watchlist statistics
  Map<String, dynamic> getWatchlistStats(String userId) {
    final watchlist = _userWatchlists[userId] ?? [];
    
    return {
      'total': watchlist.length,
      'watched': watchlist.where((item) => item.isWatched).length,
      'movies': watchlist.where((item) => item.type == WatchlistItemType.movie).length,
      'tvShows': watchlist.where((item) => item.type == WatchlistItemType.tvShow).length,
    };
  }
}
