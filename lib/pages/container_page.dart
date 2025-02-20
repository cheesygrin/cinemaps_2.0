import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth/auth_test_page.dart';
import 'movies_page.dart';
import 'map_page.dart';
import 'gallery_page.dart';
import 'tours_page.dart';
import 'home_page.dart';
import '../theme/cinemaps_theme.dart';
import 'admin_page.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  int _currentIndex = 2; // Start with Home page

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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
        title: Hero(
          tag: 'app_title',
          child: const Text(
            'Cinemaps',
            style: TextStyle(color: CinemapsTheme.neonYellow),
          ),
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
                _onNavigate(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie, color: CinemapsTheme.neonYellow),
              title: const Text('Movies', style: TextStyle(color: Colors.white)),
              onTap: () {
                _onNavigate(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: CinemapsTheme.neonYellow),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                _onNavigate(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: CinemapsTheme.neonYellow),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                _onNavigate(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tour, color: CinemapsTheme.neonYellow),
              title: const Text('Tours', style: TextStyle(color: Colors.white)),
              onTap: () {
                _onNavigate(4);
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
          HomePage(onNavigate: _onNavigate),
          const GalleryPage(userId: 'current_user'),
          const ToursPage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: CinemapsTheme.deepSpaceBlack,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigate,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: CinemapsTheme.neonYellow,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'Movies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tour),
              label: 'Tours',
            ),
          ],
        ),
      ),
    );
  }
} 