import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class CinemapsUser {
  final String uid;
  final String email;
  final String displayName;
  final bool isAnonymous;

  CinemapsUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.isAnonymous = true,
  });

  factory CinemapsUser.fromSupabaseUser(User user) {
    return CinemapsUser(
      uid: user.id,
      email: user.email ?? 'guest@cinemaps.com',
      displayName: user.userMetadata?['name'] ?? 'Guest User',
      isAnonymous: user.email?.contains('guest-') ?? false,
    );
  }
}

class AuthService extends ChangeNotifier {
  CinemapsUser? _currentUser;
  final _supabase = SupabaseService.instance;
  DateTime? _lastGuestAttempt;

  AuthService() {
    _initializeAuth();
  }

  void _initializeAuth() {
    final session = _supabase.client.auth.currentSession;
    if (session != null) {
      _currentUser = CinemapsUser.fromSupabaseUser(session.user);
      notifyListeners();
    }

    _supabase.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
          if (session != null) {
            _currentUser = CinemapsUser.fromSupabaseUser(session.user);
            notifyListeners();
          }
          break;
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          notifyListeners();
          break;
        default:
          break;
      }
    });
  }

  CinemapsUser? get currentUser => _currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.signIn(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _currentUser = CinemapsUser.fromSupabaseUser(response.user!);
        notifyListeners();
      } else {
        throw Exception('Failed to sign in');
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final response = await _supabase.signInWithGoogle();
      if (response.user != null) {
        _currentUser = CinemapsUser.fromSupabaseUser(response.user!);
        notifyListeners();
      } else {
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  Future<void> signInAsGuest() async {
    try {
      // Create a simple guest user without actual authentication
      final guestId = 'guest-${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = CinemapsUser(
        uid: guestId,
        email: 'guest@cinemaps.app',
        displayName: 'Guest User',
        isAnonymous: true,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Guest login error: $e');
      throw Exception('Unable to continue as guest. Please try again later.');
    }
  }

  Future<void> signOut() async {
    try {
      if (_currentUser?.isAnonymous ?? false) {
        // Just clear the guest user
        _currentUser = null;
        notifyListeners();
      } else {
        // Sign out from Supabase
        await _supabase.signOut();
        _currentUser = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}

