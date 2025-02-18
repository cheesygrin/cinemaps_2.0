import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/social_service.dart';
import 'package:intl/intl.dart';

class SocialFeedPage extends StatefulWidget {
  final String userId;

  const SocialFeedPage({
    super.key,
    required this.userId,
  });

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage>
    with SingleTickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final results = await _socialService.searchUsers(query);
    setState(() => _searchResults = results);
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
            Tab(text: 'FEED'),
            Tab(text: 'DISCOVER'),
            Tab(text: 'PROFILE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeed(),
          _buildDiscover(),
          _buildProfile(),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return FutureBuilder<List<ActivityItem>>(
      future: _socialService.getUserFeed(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyFeed();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              _buildActivityCard(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildDiscover() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: CinemapsTheme.hotPink,
                ),
              ),
            ),
            onChanged: _performSearch,
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? _buildTrendingLocations()
              : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return FutureBuilder<UserProfile?>(
      future: _socialService.getUserProfile(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Profile not found'));
        }

        final profile = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(profile),
              const SizedBox(height: 24),
              _buildStatsGrid(profile),
              const SizedBox(height: 24),
              _buildActivityList(profile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyFeed() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Your feed is empty',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow other movie explorers to see their activity',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: CinemapsTheme.hotPink,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('DISCOVER USERS'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityItem activity) {
    return FutureBuilder<UserProfile?>(
      future: _socialService.getUserProfile(activity.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final user = snapshot.data!;
        return Card(
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: CinemapsTheme.hotPink.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: CinemapsTheme.hotPink.withOpacity(0.2),
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat.yMMMd()
                                .add_jm()
                                .format(activity.timestamp),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActivityContent(activity),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityContent(ActivityItem activity) {
    String message;
    IconData icon;
    Color color;

    switch (activity.type) {
      case UserActivityType.visitedLocation:
        message = 'visited a new movie location';
        icon = Icons.location_on;
        color = CinemapsTheme.neonYellow;
        break;
      case UserActivityType.completedTour:
        message = 'completed a movie tour';
        icon = Icons.movie_filter;
        color = CinemapsTheme.hotPink;
        break;
      case UserActivityType.earnedAchievement:
        message = 'earned a new achievement';
        icon = Icons.emoji_events;
        color = CinemapsTheme.neonYellow;
        break;
      case UserActivityType.uploadedPhoto:
        message = 'shared a new photo';
        icon = Icons.photo_camera;
        color = CinemapsTheme.cyberBlue;
        break;
      case UserActivityType.startedFollowing:
        message = 'started following someone';
        icon = Icons.person_add;
        color = CinemapsTheme.electricPurple;
        break;
      case UserActivityType.likedPhoto:
        message = 'liked a photo';
        icon = Icons.thumb_up;
        color = CinemapsTheme.cyberBlue;
        break;
      case UserActivityType.commentedPhoto:
        message = 'commented on a photo';
        icon = Icons.comment;
        color = CinemapsTheme.cyberBlue;
        break;
      case UserActivityType.sharedLocation:
        message = 'shared a location';
        icon = Icons.share;
        color = CinemapsTheme.neonYellow;
        break;
      case UserActivityType.sharedTour:
        message = 'shared a tour';
        icon = Icons.share;
        color = CinemapsTheme.hotPink;
        break;
      case UserActivityType.likedMovie:
        message = 'liked a movie';
        icon = Icons.thumb_up;
        color = CinemapsTheme.hotPink;
        break;
      case UserActivityType.sharedMovie:
        message = 'shared a movie';
        icon = Icons.share;
        color = CinemapsTheme.hotPink;
        break;
      case UserActivityType.checkedInMovie:
        message = 'checked in at a movie';
        icon = Icons.check_circle;
        color = CinemapsTheme.hotPink;
        break;
      case UserActivityType.commentedMovie:
        message = 'commented on a movie';
        icon = Icons.comment;
        color = CinemapsTheme.hotPink;
        break;
      case UserActivityType.likedComment:
        message = 'liked a comment';
        icon = Icons.thumb_up;
        color = CinemapsTheme.electricPurple;
        break;
      case UserActivityType.repliedToComment:
        message = 'replied to a comment';
        icon = Icons.reply;
        color = CinemapsTheme.electricPurple;
        break;
      default:
        message = 'did something';
        icon = Icons.star;
        color = CinemapsTheme.hotPink;
    }

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTrendingLocations() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for other movie explorers',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'or try some trending locations',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return Card(
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: CinemapsTheme.hotPink.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: CinemapsTheme.hotPink.withOpacity(0.2),
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              user.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: user.bio != null
                ? Text(
                    user.bio!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: TextButton(
              onPressed: () =>
                  _socialService.followUser(widget.userId, user.id),
              child: Text(
                'FOLLOW',
                style: TextStyle(
                  color: CinemapsTheme.hotPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: CinemapsTheme.hotPink.withOpacity(0.2),
          backgroundImage: profile.avatarUrl != null
              ? NetworkImage(profile.avatarUrl!)
              : null,
          child: profile.avatarUrl == null
              ? Text(
                  profile.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          profile.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (profile.bio != null) ...[
          const SizedBox(height: 8),
          Text(
            profile.bio!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('Following', profile.following.length),
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white.withOpacity(0.2),
            ),
            _buildStatItem('Followers', profile.followers.length),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: CinemapsTheme.hotPink,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(UserProfile profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Points',
          profile.points.toString(),
          Icons.stars,
          CinemapsTheme.neonYellow,
        ),
        _buildStatCard(
          'Global Rank',
          '#${profile.rank}',
          Icons.leaderboard,
          CinemapsTheme.hotPink,
        ),
        _buildStatCard(
          'Tours Completed',
          profile.completedTours.length.toString(),
          Icons.movie_filter,
          CinemapsTheme.electricPurple,
        ),
        _buildStatCard(
          'Locations Visited',
          profile.visitedLocations.length.toString(),
          Icons.location_on,
          CinemapsTheme.cyberBlue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(UserProfile profile) {
    return FutureBuilder<List<ActivityItem>>(
      future: _socialService.getUserActivity(profile.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: TextStyle(
                color: CinemapsTheme.neonYellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: CinemapsTheme.hotPink.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  _buildActivityCard(snapshot.data![index]),
            ),
          ],
        );
      },
    );
  }
}
