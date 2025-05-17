import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Data/studentData.dart';
import 'package:jwt_decode/jwt_decode.dart';


class StudentAuthService {
  final String baseUrl;

  StudentAuthService({required this.baseUrl});

  static const String _tokenKey = 'jwt_token';

  // Save JWT token persistently
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get saved JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove JWT token (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Register student (calls your register API)
  Future<bool> register({
    required String studentId,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/registerStudentAccount');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  // Login student, save token & return Student data
  Future<Student> login({
    required String studentId,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = response.headers['set-cookie'] != null
          ? _extractTokenFromCookie(response.headers['set-cookie']!)
          : data['token']; // fallback if your backend sends token in JSON
      if (token != null) {
        await _saveToken(token);
      }
      final studentJson = data['student'];
      return Student.fromJson(studentJson);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    try {

      return !Jwt.isExpired(token);
    } catch (_) {
      return false; // malformed token fallback
    }
  }
  // Helper to parse JWT from cookie header (if cookie based auth)
  String? _extractTokenFromCookie(String cookie) {
    // Example cookie: access_token=jwtstring; Path=/; HttpOnly
    final regex = RegExp(r'access_token=([^;]+)');
    final match = regex.firstMatch(cookie);
    return match?.group(1);
  }

  // Get student details using saved token
  Future<Student> getStudentDetails() async {
    final token = await getToken();
    if (token == null) throw Exception('User not logged in');

    final url = Uri.parse('$baseUrl/studentDetails');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Student.fromJson(data['student']);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to fetch student details');
    }
  }
}
