import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentdb/Constant.dart';

class TeacherAuthService {
  static const String baseUrl = '${baseUrlMain}/teacher/login';

  // Login teacher with email & password
  Future<bool> loginTeacher(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwtToken', token);
          await prefs.setString('userType', 'teacher');
          await prefs.setBool('isLoggedIn', true);

          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = base64Url.normalize(parts[1]);
            final decoded = utf8.decode(base64Url.decode(payload));
            final payloadMap = json.decode(decoded);

            final teacherId = payloadMap['_id']; // or 'id', depending on your backend

            if (teacherId != null) {
              await prefs.setString('teacherId', teacherId);
            } else {
              print("Teacher ID not found in token payload.");
            }
          }
          return true;
        } else {
          print("Login succeeded but token missing");
          return false;
        }
      } else {
        print("Login failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token = prefs.getString('jwtToken');
    return loggedIn && token != null && token.isNotEmpty;
  }

  // Get stored JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  // Get stored user type (e.g. teacher)
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  // Logout user and clear stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    await prefs.remove('userType');
    await prefs.setBool('isLoggedIn', false);
  }

  // Fetch the teacher's profile data using saved JWT token
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final token = await getToken();
      if (token == null) {
        print("No JWT token found");
        return null;
      }

      final response = await http.get(
        Uri.parse('${baseUrlMain}/teacher/profile'),  // Adjust this URL to your backend route that returns user profile
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",          // Send JWT in Authorization header
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['teacher'] ?? data; // Adjust based on your backend response shape
      } else {
        print("Failed to fetch user data. Status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<String?> getTeacherId() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final payloadMap = json.decode(decoded);

      return payloadMap['_id'] as String?;
    } catch (e) {
      print("Error decoding JWT: $e");
      return null;
    }
  }
}


