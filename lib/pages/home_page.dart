import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth/auth_test_page.dart';
import 'movies_page.dart';
import 'map_page.dart';
import 'search_page.dart';
import 'tours_page.dart';
import 'gallery_page.dart';
import 'social_feed_page.dart';
import 'leaderboard_page.dart';
import 'profile_page.dart';
import '../theme/cinemaps_theme.dart';
import 'watchlist_page.dart';
import 'admin_movies_page.dart';
import 'admin_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    // Safety check - if no user, show auth page
    if (user == null) {
      return const AuthTestPage();
    }

    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      appBar: AppBar(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text(
          'Cinemaps',
          style: TextStyle(color: CinemapsTheme.neonYellow),
        ),
      ),
      drawer: Drawer(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: CinemapsTheme.hotPink,
              ),
              accountName: Text(
                user.displayName,
                style: const TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                user.email,
                style: const TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: CinemapsTheme.deepSpaceBlack,
                child: Text(
                  user.displayName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24.0),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map, color: CinemapsTheme.neonYellow),
              title: const Text('Map', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie, color: CinemapsTheme.neonYellow),
              title: const Text('Movies', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tour, color: CinemapsTheme.neonYellow),
              title: const Text('Tours', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: CinemapsTheme.neonYellow),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: CinemapsTheme.neonYellow),
              title: const Text('Social', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _currentIndex = 4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: CinemapsTheme.neonYellow),
              title: const Text('Ranks', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _currentIndex = 5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: CinemapsTheme.neonYellow),
              title: const Text('Watchlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _currentIndex = 6);
                Navigator.pop(context);
              },
            ),
            const Divider(color: Colors.white24),
            if (!user.isAnonymous) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: CinemapsTheme.hotPink),
                title: const Text('Admin', style: TextStyle(color: CinemapsTheme.hotPink)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login, color: CinemapsTheme.neonYellow),
                title: const Text('Sign In', style: TextStyle(color: CinemapsTheme.neonYellow)),
                onTap: () {
                  // TODO: Implement sign in
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const MapPage(),
          const MoviesPage(),
          const ToursPage(),
          const GalleryPage(userId: 'current_user'),
          const SocialFeedPage(userId: 'current_user'),
          const LeaderboardPage(userId: 'current_user'),
          WatchlistPage(userId: 'current_user'),
        ],
      ),
    );
  }
}
