import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class teacherSignUp extends StatefulWidget {
  const teacherSignUp({super.key});

  @override
  State<teacherSignUp> createState() => _TeacherSignUpState();
}

class _TeacherSignUpState extends State<teacherSignUp> {
  // TextEditingControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  String baseUrl = 'http://192.168.80.212:3000/API/teacher/register';
  Future<void> _authenticate() async {
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
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'phone': phoneController.text,
          'school': collegeController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showSnackbar("Registered Successfully: ${data['name'] ?? 'Teacher'}");
        print("Response: $data");
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/teacherLogin');
        });
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
    // Clean up controllers
    nameController.dispose();
    emailController.dispose();
    collegeController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Sign Up"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Welcome 👋",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Name Field
            TextField(
              controller: nameController,
              decoration: _inputDecoration("Name", "Enter your full name", Icons.person),
            ),
            const SizedBox(height: 20),

            // Email Field
            TextField(
              controller: emailController,
              decoration: _inputDecoration("Email", "Enter your email", Icons.email),
            ),
            const SizedBox(height: 20),

            // School/College Field
            TextField(
              controller: collegeController,
              decoration: _inputDecoration("School/College", "Enter your institution name", Icons.school),
            ),
            const SizedBox(height: 20),

            // Phone Number Field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("Phone Number", "Enter your phone number", Icons.phone),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputDecoration("Password", "Enter a secure password", Icons.lock),
            ),
            const SizedBox(height: 20),

            // Confirm Password Field
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Confirm Password", "Re-enter your password", Icons.lock_outline),
            ),

            const SizedBox(height: 30),

            // Sign Up Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await _authenticate();
                  print("Name: ${nameController.text}");
                  print("Email: ${emailController.text}");
                  print("Phone: ${phoneController.text}");
                },
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

            // Already have account? Login
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/teacherLogin');
                },
                child: const Text("Already have an account? Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for input decoration
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
