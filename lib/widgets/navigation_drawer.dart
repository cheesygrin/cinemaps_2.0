import 'package:flutter/material.dart';
import '../theme/cinemaps_theme.dart';

class CinemapsDrawer extends StatelessWidget {
  final String userId;
  final String currentRoute;

  const CinemapsDrawer({
    super.key,
    required this.userId,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: CinemapsTheme.hotPink,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cinemaps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover Movie Locations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.map,
            title: 'Map',
            route: '/',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.movie,
            title: 'Movies',
            route: '/movies',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.place,
            title: 'Locations',
            route: '/locations',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.directions_walk,
            title: 'Tours',
            route: '/tours',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.bookmark,
            title: 'Watchlist',
            route: '/watchlist',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: 'Profile',
            route: '/profile',
          ),
          const Divider(color: Colors.white24),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            route: '/settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? CinemapsTheme.hotPink : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? CinemapsTheme.hotPink : Colors.white,
        ),
      ),
      selected: isSelected,
      selectedTileColor: CinemapsTheme.hotPink.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
