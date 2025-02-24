import 'dart:typed_data';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

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

  // Auth methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: data,
        emailRedirectTo: null, // Disable email confirmation
      );
    } catch (e) {
      if (e is AuthException && e.statusCode == 400 && e.message.contains('already registered')) {
        // If user already exists, try to sign in
        return await signIn(email: email, password: password);
      }
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is AuthException && e.statusCode == 400 && e.message.contains('not confirmed')) {
        // If email not confirmed, try to sign up again
        return await signUp(email: email, password: password);
      }
      rethrow;
    }
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      debugPrint('Starting Google sign in process...');
      
      final bool success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.cinemaps.app://login-callback',
        authScreenLaunchMode: LaunchMode.inAppWebView,
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
        subscription?.cancel();
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

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Database methods
  Future<List<Map<String, dynamic>>> getCollection(String table) async {
    final response = await _client
        .from(table)
        .select();
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertDocument(String table, Map<String, dynamic> data) async {
    await _client
        .from(table)
        .insert(data);
  }

  Future<void> updateDocument(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(table)
        .update(data)
        .eq('id', id);
  }

  Future<void> deleteDocument(String table, String id) async {
    await _client
        .from(table)
        .delete()
        .eq('id', id);
  }

  // Storage methods
  Future<String> uploadFile(String bucket, String path, Uint8List fileBytes) async {
    final response = await _client
        .storage
        .from(bucket)
        .uploadBinary(path, fileBytes);
    return response;
  }

  Future<Uint8List> downloadFile(String bucket, String path) async {
    final response = await _client
        .storage
        .from(bucket)
        .download(path);
    return response;
  }

  Future<void> deleteFile(String bucket, String path) async {
    await _client
        .storage
        .from(bucket)
        .remove([path]);
  }
} 