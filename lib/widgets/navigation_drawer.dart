import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';
import '../services/auth_service.dart';

class CinemapsDrawer extends StatelessWidget {
  final String userId;
  final String currentRoute;
  final Function(String) onNavigate;
  final AuthService _authService;

  CinemapsDrawer({
    super.key,
    required this.userId,
    required this.currentRoute,
    required this.onNavigate,
  }) : _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isGuest = user == null || user.isAnonymous;

    return Drawer(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: CinemapsTheme.hotPink,
              image: DecorationImage(
                image: AssetImage('assets/images/ui/drawer_header.jpg'),
                fit: BoxFit.cover,
                opacity: 0.6,
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            accountEmail: Text(
              user?.email ?? 'guest@cinemaps.app',
              style: const TextStyle(
                color: Colors.white70,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: CinemapsTheme.deepSpaceBlack,
              child: Text(
                (user?.displayName ?? 'G')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24.0,
                  color: CinemapsTheme.neonYellow,
                ),
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.map,
            title: 'Movie Locations',
            route: '/map',
          ),
          _buildDrawerItem(
            icon: Icons.movie,
            title: 'Movies',
            route: '/movies',
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Home',
            route: '/home',
          ),
          _buildDrawerItem(
            icon: Icons.photo_library,
            title: 'Gallery',
            route: '/gallery',
          ),
          _buildDrawerItem(
            icon: Icons.tour,
            title: 'Movie Tours',
            route: '/tours',
          ),
          if (!isGuest) ...[
            const Divider(color: Colors.white24),
            _buildDrawerItem(
              icon: Icons.bookmark,
              title: 'Watchlist',
              route: '/watchlist',
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profile',
              route: '/profile',
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              title: 'Settings',
              route: '/settings',
            ),
          ],
          const Divider(color: Colors.white24),
          if (isGuest)
            _buildDrawerItem(
              icon: Icons.login,
              title: 'Sign In',
              route: '/login',
              color: CinemapsTheme.neonYellow,
            )
          else
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Sign Out',
              route: '/logout',
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String route,
    Color? color,
  }) {
    final isSelected = currentRoute == route;
    final itemColor = color ?? (isSelected ? CinemapsTheme.hotPink : Colors.white);

    return ListTile(
      leading: Icon(
        icon,
        color: itemColor.withOpacity(isSelected ? 1 : 0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: itemColor.withOpacity(isSelected ? 1 : 0.9),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: CinemapsTheme.hotPink.withOpacity(0.1),
      onTap: () => onNavigate(route),
    );
  }
}
