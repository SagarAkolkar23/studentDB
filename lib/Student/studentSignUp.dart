import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class studentSignUp extends StatefulWidget {
  const studentSignUp({super.key});

  @override
  State<studentSignUp> createState() => _StudentSignUpState();
}

class _StudentSignUpState extends State<studentSignUp> {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String baseUrl = 'http://192.168.80.212:3000/API/student/register';

  Future<void> _registerStudent() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackbar("Passwords do not match");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'studentId': studentIdController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showSnackbar("Registered Successfully 🎉");
        print("Response: $data");
        Navigator.pushReplacementNamed(context, '/studentLogin');
      } else {
        final error = jsonDecode(response.body);
        _showSnackbar("${error['message'] ?? 'Registration failed'}");
        print("Failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
      _showSnackbar("Error connecting to server");
    }
  }

  @override
  void dispose() {
    studentIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Sign Up"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Create Account 👨‍🎓",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            TextField(
              controller: studentIdController,
              decoration: _inputDecoration("Student ID", "Enter your student ID", Icons.badge),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration("Email", "Enter your email", Icons.email),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputDecoration("Password", "Enter password", Icons.lock),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Confirm Password", "Re-enter password", Icons.lock_outline),
            ),
            const SizedBox(height: 30),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _registerStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Sign Up", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),

            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/studentLogin');
                },
                child: const Text("Already have an account? Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
