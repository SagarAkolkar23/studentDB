import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class studentLogin extends StatefulWidget {
  const studentLogin({super.key});

  @override
  State<studentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<studentLogin> {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    studentIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String baseUrl = 'http://192.168.236.212:3000/API/student/login';

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'studentId': studentIdController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _showSnackbar("Login Successful");
        print("Response: $responseData");

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/studentScreen');
        });
      } else {
        final responseData = jsonDecode(response.body);
        _showSnackbar("Login failed: ${responseData['message']}");
        print("Login failed with status: ${response.statusCode}");
      }
    } catch (error) {
      _showSnackbar("Something went wrong. Try again later.");
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Login"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Welcome Back 👋",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Student ID Field
              TextField(
                controller: studentIdController,
                decoration: _inputDecoration("Student ID", "Enter your ID", Icons.person),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Login", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 15),

              // Sign Up Link
              Center(
                child: OutlinedButton(
                  onPressed: () {
                     Navigator.pushNamed(context, '/studentSignUp');
                  },
                  child: const Text("New student? Register here."),
                ),
              ),
            ],
          ),
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
