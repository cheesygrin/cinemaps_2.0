import 'package:flutter/foundation.dart';
import '../models/user_auth.dart';

class AuthService extends ChangeNotifier {
  UserAuth? _currentUser;
  UserAuth? get currentUser => _currentUser;

  AuthService() {
    // Initialize with a guest user
    signInAsGuest();
  }

  Future<void> signInAsGuest() async {
    _currentUser = UserAuth.guest();
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }
}
