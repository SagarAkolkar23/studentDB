import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Backend/studentAuth.dart';

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
  final StudentAuthService _authService = StudentAuthService();


  bool _isLoading = false;


  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  Future<void> _registerStudent() async {
    final studentId = studentIdController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Basic validations...
    if (studentId.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackbar("Please fill in all fields.");
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackbar("Please enter a valid email address.");
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar("Passwords do not match.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the service here
      final result = await _authService.register(
        studentId: studentId,
        email: email,
        password: password,
      );

      if (result['success']) {
        _showSnackbar(result['message'] ?? "Registration successful!");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/studentLogin');
        });
      } else {
        _showSnackbar(result['message'] ?? "Registration failed");
      }
    } catch (e) {
      _showSnackbar("An error occurred, please try again.");
      print("Register error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                onPressed: _isLoading ? null : _registerStudent,
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
