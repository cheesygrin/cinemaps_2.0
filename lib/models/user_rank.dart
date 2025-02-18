class UserRank {
  final String userId;
  final String username;
  final String avatarUrl;
  final int rank;
  final int score;
  final String category;  // 'tours', 'photos', 'reviews'

  UserRank({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.rank,
    required this.score,
    required this.category,
  });

  factory UserRank.fromJson(Map<String, dynamic> json) {
    return UserRank(
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String,
      rank: json['rank'] as int,
      score: json['score'] as int,
      category: json['category'] as String,
    );
  }
}
