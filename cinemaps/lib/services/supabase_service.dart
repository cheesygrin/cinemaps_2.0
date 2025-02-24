import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://qykabnvjwzhldlqcybwn.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5a2FibnZqd3pobGRscWN5YnduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAyNjA2MDYsImV4cCI6MjA1NTgzNjYwNn0.8wRftXMpB_01rx5Xahf7t5gdWCVk6Rd0Z0rR90nvchU',
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  Future<AuthResponse> signInWithGoogle() async {
    try {
      debugPrint('Starting Google sign in process...');
      
      final bool success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb 
            ? null 
            : 'com.cinemaps.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );
      
      debugPrint('OAuth flow completed with success: $success');
      
      if (!success) {
        debugPrint('Google sign in was cancelled or failed');
        throw Exception('Google sign in was cancelled or failed');
      }

      // Check if we already have a session
      final currentSession = _client.auth.currentSession;
      if (currentSession != null) {
        debugPrint('Session found immediately after sign in');
        return AuthResponse(
          session: currentSession,
          user: currentSession.user,
        );
      }

      debugPrint('No immediate session, waiting for auth state change...');
      
      // Listen for auth state changes
      final completer = Completer<AuthResponse>();
      StreamSubscription? subscription;
      
      subscription = _client.auth.onAuthStateChange.listen(
        (data) {
          debugPrint('Auth state changed: ${data.event}');
          final AuthChangeEvent event = data.event;
          final Session? session = data.session;

          if (event == AuthChangeEvent.signedIn && session != null) {
            debugPrint('Signed in successfully with session');
            completer.complete(AuthResponse(
              session: session,
              user: session.user,
            ));
            subscription?.cancel();
          } else if (event == AuthChangeEvent.signedOut) {
            debugPrint('Received signedOut event');
          }
        },
        onError: (error) {
          debugPrint('Auth state change error: $error');
          completer.completeError(error);
          subscription?.cancel();
        },
      );

      // Wait for auth state change or timeout
      try {
        final response = await completer.future.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            debugPrint('Timeout waiting for Google sign in');
            subscription?.cancel();
            throw Exception('Timeout waiting for Google sign in');
          },
        );
        return response;
      } catch (e) {
        subscription.cancel();
        debugPrint('Error during auth state change wait: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      if (e is AuthException) {
        debugPrint('Auth error details: ${e.message}');
      }
      rethrow;
    }
  }
} 