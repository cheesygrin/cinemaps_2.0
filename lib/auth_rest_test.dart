import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthRestTestPage extends StatefulWidget {
  const AuthRestTestPage({super.key});

  @override
  State<AuthRestTestPage> createState() => _AuthRestTestPageState();
}

class _AuthRestTestPageState extends State<AuthRestTestPage> {
  String _status = 'Not signed in';
  bool _loading = false;

  Future<void> _signInAnonymously() async {
    setState(() {
      _loading = true;
      _status = 'Signing in...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyB504qGiqn29CBBYSbDkaLr7sTWGIOvks0'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _status = 'Signed in with ID: ${data['localId']}';
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _status = 'Error: ${error['error']['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth REST Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else
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
