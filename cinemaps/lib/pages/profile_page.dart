import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/cinemaps_theme.dart';
import 'auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;

        if (user == null) {
          return Scaffold(
            backgroundColor: CinemapsTheme.deepSpaceBlack,
            appBar: AppBar(
              title: const Text('Profile'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sign in to access your profile',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CinemapsTheme.hotPink,
                    ),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: CinemapsTheme.deepSpaceBlack,
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authService.signOut();
                },
                tooltip: 'Sign Out',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: CinemapsTheme.hotPink,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Text(
                                user.displayName[0].toUpperCase() ?? user.email[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.white70),
                  title: const Text(
                    'Email Verification',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    user.emailVerified ? 'Verified' : 'Not verified',
                    style: TextStyle(
                      color: user.emailVerified ? Colors.green : Colors.grey,
                    ),
                  ),
                  trailing: user.emailVerified
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                      : TextButton(
                          onPressed: () {
                            // TODO: Implement email verification
                          },
                          child: const Text('Verify'),
                        ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.white70),
                  title: const Text(
                    'Member Since',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    user.createdAt.toString().split(' ')[0],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.white70),
                  title: const Text(
                    'Last Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    user.lastSignInTime.toString().split(' ')[0],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
