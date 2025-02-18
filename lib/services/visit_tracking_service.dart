class VisitStats {
  final int totalVisits;
  final int uniqueVisitors;
  final List<String> recentVisitorUsernames;
  final DateTime lastVisited;

  VisitStats({
    required this.totalVisits,
    required this.uniqueVisitors,
    required this.recentVisitorUsernames,
    required this.lastVisited,
  });
}

class VisitTrackingService {
  // In a real app, this would be backed by a database
  final Map<String, VisitStats> _locationStats = {};

  Future<void> recordVisit(
      String locationId, String userId, String username) async {
    // In a real app, this would make an API call
    final stats = _locationStats[locationId] ??
        VisitStats(
          totalVisits: 0,
          uniqueVisitors: 0,
          recentVisitorUsernames: [],
          lastVisited: DateTime.now(),
        );

    _locationStats[locationId] = VisitStats(
      totalVisits: stats.totalVisits + 1,
      uniqueVisitors: stats.uniqueVisitors +
          (stats.recentVisitorUsernames.contains(username) ? 0 : 1),
      recentVisitorUsernames: [
        username,
        ...stats.recentVisitorUsernames.where((u) => u != username).take(4),
      ],
      lastVisited: DateTime.now(),
    );
  }

  Future<VisitStats> getLocationStats(String locationId) async {
    // In a real app, this would make an API call
    return _locationStats[locationId] ??
        VisitStats(
          totalVisits: 0,
          uniqueVisitors: 0,
          recentVisitorUsernames: [],
          lastVisited: DateTime.now(),
        );
  }

  Future<List<String>> getMostVisitedLocations(int limit) async {
    // In a real app, this would make an API call
    final entries = _locationStats.entries.toList();
    entries.sort((a, b) => b.value.totalVisits.compareTo(a.value.totalVisits));
    return entries.take(limit).map((e) => e.key).toList();
  }
}
