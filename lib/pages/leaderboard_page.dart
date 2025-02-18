import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  final String userId;

  const LeaderboardPage({
    super.key,
    required this.userId,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  final LeaderboardService _leaderboardService = LeaderboardService();
  late TabController _tabController;
  LeaderboardCategory _selectedCategory = LeaderboardCategory.global;
  LeaderboardTimeframe _selectedTimeframe = LeaderboardTimeframe.thisWeek;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _leaderboardService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: CinemapsTheme.hotPink,
          tabs: const [
            Tab(text: 'RANKINGS'),
            Tab(text: 'CHALLENGES'),
            Tab(text: 'ACHIEVEMENTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingsTab(),
          _buildChallengesTab(),
          _buildAchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildRankingsTab() {
    return Column(
      children: [
        _buildLeaderboardFilters(),
        Expanded(
          child: FutureBuilder<List<LeaderboardEntry>>(
            future: _leaderboardService.getLeaderboard(
              category: _selectedCategory,
              timeframe: _selectedTimeframe,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState('No rankings available');
              }

              return _buildLeaderboardList(snapshot.data!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: CinemapsTheme.hotPink.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<LeaderboardCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                ),
              ),
            ),
            dropdownColor: CinemapsTheme.deepSpaceBlack,
            style: const TextStyle(color: Colors.white),
            items: LeaderboardCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<LeaderboardTimeframe>(
            value: _selectedTimeframe,
            decoration: InputDecoration(
              labelText: 'Timeframe',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: CinemapsTheme.hotPink.withOpacity(0.3),
                ),
              ),
            ),
            dropdownColor: CinemapsTheme.deepSpaceBlack,
            style: const TextStyle(color: Colors.white),
            items: LeaderboardTimeframe.values.map((timeframe) {
              return DropdownMenuItem(
                value: timeframe,
                child: Text(_formatTimeframe(timeframe)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTimeframe = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser = entry.userId == widget.userId;
        final rank = entry.rank;

        return Card(
          color: isCurrentUser
              ? CinemapsTheme.hotPink.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCurrentUser
                  ? CinemapsTheme.hotPink
                  : CinemapsTheme.hotPink.withOpacity(0.3),
              width: isCurrentUser ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: _buildRankBadge(rank),
            title: Text(
              entry.username,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${entry.points} points',
              style: TextStyle(
                color: isCurrentUser
                    ? CinemapsTheme.hotPink
                    : Colors.white.withOpacity(0.7),
              ),
            ),
            trailing: entry.achievements.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: CinemapsTheme.neonYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.achievements.length.toString(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildChallengesTab() {
    return FutureBuilder<List<Challenge>>(
      future: _leaderboardService.getActiveChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No active challenges');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final challenge = snapshot.data![index];
            return _buildChallengeCard(challenge);
          },
        );
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final timeLeft = challenge.endDate.difference(DateTime.now());
    final progress = challenge.completedBy.contains(widget.userId);

    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: progress
              ? CinemapsTheme.neonYellow
              : CinemapsTheme.hotPink.withOpacity(0.3),
          width: progress ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CinemapsTheme.hotPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge.points}',
                    style: const TextStyle(
                      color: CinemapsTheme.hotPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time left: ${_formatDuration(timeLeft)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                if (progress)
                  const Icon(
                    Icons.check_circle,
                    color: CinemapsTheme.neonYellow,
                  )
                else
                  TextButton(
                    onPressed: () => _leaderboardService.participateInChallenge(
                      widget.userId,
                      challenge.id,
                    ),
                    child: const Text(
                      'PARTICIPATE',
                      style: TextStyle(
                        color: CinemapsTheme.hotPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return FutureBuilder<List<Achievement>>(
      future: _leaderboardService.getUserAchievements(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No achievements yet');
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final achievement = snapshot.data![index];
            return _buildAchievementCard(achievement);
          },
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    Color tierColor;
    switch (achievement.tier) {
      case AchievementTier.bronze:
        tierColor = Colors.brown.shade300;
        break;
      case AchievementTier.silver:
        tierColor = Colors.grey.shade300;
        break;
      case AchievementTier.gold:
        tierColor = Colors.amber;
        break;
      case AchievementTier.platinum:
        tierColor = Colors.grey.shade50;
        break;
      case AchievementTier.diamond:
        tierColor = Colors.lightBlue.shade200;
        break;
    }

    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tierColor.withOpacity(0.7),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                color: tierColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${achievement.points} points',
              style: TextStyle(
                color: tierColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color;
    IconData icon;

    switch (rank) {
      case 1:
        color = Colors.amber;
        icon = Icons.looks_one;
        break;
      case 2:
        color = Colors.grey.shade300;
        icon = Icons.looks_two;
        break;
      case 3:
        color = Colors.brown.shade300;
        icon = Icons.looks_3;
        break;
      default:
        color = Colors.white.withOpacity(0.5);
        icon = Icons.tag;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: rank <= 3
            ? Icon(icon, color: color)
            : Text(
                '#$rank',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeframe(LeaderboardTimeframe timeframe) {
    switch (timeframe) {
      case LeaderboardTimeframe.allTime:
        return 'ALL TIME';
      case LeaderboardTimeframe.thisYear:
        return 'THIS YEAR';
      case LeaderboardTimeframe.thisMonth:
        return 'THIS MONTH';
      case LeaderboardTimeframe.thisWeek:
        return 'THIS WEEK';
      case LeaderboardTimeframe.today:
        return 'TODAY';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
