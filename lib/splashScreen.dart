import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('userType');

    if (isLoggedIn && userType == 'teacher') {
      Navigator.pushReplacementNamed(context, '/classList');
    } else if (isLoggedIn && userType == 'student') {
      Navigator.pushReplacementNamed(context, '/studentScreen');
    } else {
      Navigator.pushReplacementNamed(context, '/userSelectionScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Student Record Book',
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
