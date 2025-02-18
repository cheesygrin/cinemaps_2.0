import 'package:flutter/foundation.dart';
import '../models/user_auth.dart';

class UserDatabaseService extends ChangeNotifier {
  final Map<String, UserAuth> _users = {};
  final Map<String, String> _roles = {}; // userId -> role mapping

  UserDatabaseService() {
    _initializeDefaultUsers();
  }

  void _initializeDefaultUsers() {
    // Add admin user
    final adminUser = UserAuth(
      uid: 'admin',
      email: 'admin@cinemaps.app',
      displayName: 'Admin User',
      photoURL: null,
      emailVerified: true,
      createdAt: DateTime.now(),
      lastSignInTime: DateTime.now(),
      isAnonymous: false,
    );
    _users[adminUser.uid] = adminUser;
    _roles[adminUser.uid] = 'admin';

    // Add some test users
    final testUsers = [
      UserAuth(
        uid: 'user1',
        email: 'user1@example.com',
        displayName: 'Test User 1',
        photoURL: null,
        emailVerified: true,
        createdAt: DateTime.now(),
        lastSignInTime: DateTime.now(),
        isAnonymous: false,
      ),
      UserAuth(
        uid: 'user2',
        email: 'user2@example.com',
        displayName: 'Test User 2',
        photoURL: null,
        emailVerified: false,
        createdAt: DateTime.now(),
        lastSignInTime: DateTime.now(),
        isAnonymous: false,
      ),
    ];

    for (final user in testUsers) {
      _users[user.uid] = user;
      _roles[user.uid] = 'user';
    }
  }

  // Get all users
  List<UserAuth> getAllUsers() => _users.values.toList();

  // Get user by ID
  UserAuth? getUserById(String uid) => _users[uid];

  // Get user role
  String getUserRole(String uid) => _roles[uid] ?? 'user';

  // Check if user is admin
  bool isAdmin(String uid) => getUserRole(uid) == 'admin';

  // Add new user
  Future<void> addUser(UserAuth user, {String role = 'user'}) async {
    _users[user.uid] = user;
    _roles[user.uid] = role;
    notifyListeners();
  }

  // Update user
  Future<void> updateUser(UserAuth user) async {
    if (_users.containsKey(user.uid)) {
      _users[user.uid] = user;
      notifyListeners();
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    _users.remove(uid);
    _roles.remove(uid);
    notifyListeners();
  }

  // Update user role
  Future<void> updateUserRole(String uid, String role) async {
    if (_users.containsKey(uid)) {
      _roles[uid] = role;
      notifyListeners();
    }
  }

  // Search users
  List<UserAuth> searchUsers(String query) {
    query = query.toLowerCase();
    return _users.values.where((user) =>
      user.displayName.toLowerCase().contains(query) ||
      user.email.toLowerCase().contains(query)
    ).toList();
  }

  // Get user statistics
  Map<String, int> getUserStatistics() {
    return {
      'total': _users.length,
      'verified': _users.values.where((u) => u.emailVerified).length,
      'admins': _roles.values.where((role) => role == 'admin').length,
    };
  }
} 