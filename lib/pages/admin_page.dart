import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_database_service.dart';
import '../services/movies_service.dart';
import '../theme/cinemaps_theme.dart';
import '../models/user_auth.dart';
import 'admin_movies_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDb = Provider.of<UserDatabaseService>(context);
    final moviesService = Provider.of<MoviesService>(context);
    final stats = userDb.getUserStatistics();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        appBar: AppBar(
          backgroundColor: CinemapsTheme.deepSpaceBlack,
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Content'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersTab(userDb, stats),
            _buildContentTab(moviesService),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(UserDatabaseService userDb, Map<String, int> stats) {
    final users = _searchQuery.isEmpty
        ? userDb.getAllUsers()
        : userDb.searchUsers(_searchQuery);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: CinemapsTheme.neonYellow),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Total Users', stats['total'] ?? 0),
              _buildStatCard('Verified', stats['verified'] ?? 0),
              _buildStatCard('Admins', stats['admins'] ?? 0),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final role = userDb.getUserRole(user.uid);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white.withOpacity(0.1),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: CinemapsTheme.hotPink,
                    child: Text(user.displayName[0].toUpperCase()),
                  ),
                  title: Text(
                    user.displayName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      Text(
                        'Role: ${role.toUpperCase()}',
                        style: TextStyle(
                          color: role == 'admin'
                              ? CinemapsTheme.hotPink
                              : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      switch (value) {
                        case 'role':
                          await _showChangeRoleDialog(context, userDb, user);
                          break;
                        case 'verify':
                          await userDb.updateUser(
                            user.copyWith(emailVerified: true),
                          );
                          break;
                        case 'delete':
                          await _showDeleteConfirmation(context, userDb, user);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'role',
                        child: Text('Change Role'),
                      ),
                      if (!user.emailVerified)
                        const PopupMenuItem(
                          value: 'verify',
                          child: Text('Verify Email'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete User'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentTab(MoviesService moviesService) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CinemapsTheme.hotPink,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.movie),
                  label: const Text('Manage Movies'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminMoviesPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                color: CinemapsTheme.neonYellow,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangeRoleDialog(
    BuildContext context,
    UserDatabaseService userDb,
    UserAuth user,
  ) async {
    final currentRole = userDb.getUserRole(user.uid);
    String? selectedRole = currentRole;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: Text(
          'Change Role: ${user.displayName}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('User', style: TextStyle(color: Colors.white)),
              value: 'user',
              groupValue: selectedRole,
              onChanged: (value) {
                selectedRole = value;
                Navigator.pop(context);
                userDb.updateUserRole(user.uid, value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Admin', style: TextStyle(color: Colors.white)),
              value: 'admin',
              groupValue: selectedRole,
              onChanged: (value) {
                selectedRole = value;
                Navigator.pop(context);
                userDb.updateUserRole(user.uid, value!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    UserDatabaseService userDb,
    UserAuth user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CinemapsTheme.deepSpaceBlack,
        title: const Text(
          'Delete User',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${user.displayName}? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await userDb.deleteUser(user.uid);
    }
  }
} 