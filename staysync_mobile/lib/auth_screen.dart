import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'main.dart'; // Import your main app screen

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the Staff App',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep the auth prompt open on app resume
        ),
      );
      setState(() {
        _isAuthenticated = authenticated;
      });
    } on PlatformException catch (e) {
      // Handle error (e.g., user has no biometrics setup)
      print(e);
      // You might want to show a dialog or allow a password fallback here
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      // If authenticated, show the main HomeScreen
      return const HomeScreen();
    } else {
      // While not authenticated, show a lock screen with a retry button
      return Scaffold(
        backgroundColor: Colors.indigo,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 120),
              const SizedBox(height: 24),
              const Text(
                'Authentication Required',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Try Again'),
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.indigo, backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
