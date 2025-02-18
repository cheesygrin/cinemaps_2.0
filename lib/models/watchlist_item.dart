enum WatchlistItemType {
  movie,
  tvShow,
}

class WatchlistItem {
  final String id;
  final String userId;
  final String mediaId; // ID of the movie or TV show
  final WatchlistItemType type;
  final DateTime addedAt;
  final String? note; // Optional user note
  final bool isWatched;
  final DateTime? watchedAt;
  final List<String> genres;

  const WatchlistItem({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.type,
    required this.addedAt,
    this.note,
    this.isWatched = false,
    this.watchedAt,
    this.genres = const [],
  });

  WatchlistItem copyWith({
    String? id,
    String? userId,
    String? mediaId,
    WatchlistItemType? type,
    DateTime? addedAt,
    String? note,
    bool? isWatched,
    DateTime? watchedAt,
    List<String>? genres,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mediaId: mediaId ?? this.mediaId,
      type: type ?? this.type,
      addedAt: addedAt ?? this.addedAt,
      note: note ?? this.note,
      isWatched: isWatched ?? this.isWatched,
      watchedAt: watchedAt ?? this.watchedAt,
      genres: genres ?? this.genres,
    );
  }
}
