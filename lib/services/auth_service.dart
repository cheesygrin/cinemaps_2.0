import 'package:flutter/foundation.dart';

class User {
  final String uid;
  final String email;
  final String displayName;
  final bool isAnonymous;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.isAnonymous = true,
  });
}

class AuthService extends ChangeNotifier {
  User? _currentUser;

  AuthService() {
    // Initialize with a guest user
    _currentUser = User(
      uid: 'guest',
      email: 'guest@example.com',
      displayName: 'Guest User',
      isAnonymous: true,
    );
  }

  User? get currentUser => _currentUser;

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }
}
