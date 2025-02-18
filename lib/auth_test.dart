import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthTestPage extends StatelessWidget {
  const AuthTestPage({super.key});

  Future<void> _signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account: ${userCredential.user?.uid}");
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.code} - ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Auth Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                if (snapshot.hasData) {
                  return Text('Signed in as: ${snapshot.data?.uid}');
                }
                
                return const Text('Not signed in');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInAnonymously,
              child: const Text('Test Anonymous Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
