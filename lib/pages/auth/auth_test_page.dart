import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/cinemaps_theme.dart';

class AuthTestPage extends StatelessWidget {
  const AuthTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: CinemapsTheme.deepSpaceBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Cinemaps',
              style: TextStyle(
                color: CinemapsTheme.neonYellow,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              Text(
                'Welcome ${user.displayName}!',
                style: const TextStyle(
                  color: CinemapsTheme.neonYellow,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CinemapsTheme.hotPink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                onPressed: () => authService.signOut(),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ] else ...[
              const Text(
                'Not signed in',
                style: TextStyle(
                  color: CinemapsTheme.neonYellow,
                  fontSize: 24,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
