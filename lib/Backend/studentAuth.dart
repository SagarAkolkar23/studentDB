import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentdb/Constant.dart';

class StudentAuthService {

  /// Register a student
  Future<Map<String, dynamic>> register({
    required String studentId,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrlMain/studentAuth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId,
          'email': email,
          'password': password,
        }),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print("Exception in register(): $e");
      return {
        'success': false,
        'message': 'An error occurred while registering student.',
      };
    }
  }

  static const String baseUrl = '${baseUrlMain}/studentAuth/login';

  // Login student with studentId and password
  Future<Map<String, dynamic>> loginStudent(String studentId, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"studentId": studentId, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final student = data['student'];

        if (token != null && student != null) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('jwtToken', token);
          await prefs.setString('userType', 'student');
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('studentData', jsonEncode(student));

          // Decode JWT for studentId and store it
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = base64Url.normalize(parts[1]);
            final decoded = utf8.decode(base64Url.decode(payload));
            final payloadMap = json.decode(decoded);
            final storedStudentId = payloadMap['studentId'] ?? payloadMap['_id'];
            final storedStudentDbId = student['_id'];
            if (storedStudentDbId != null) {
              await prefs.setString('studentDbId', storedStudentDbId);
            }
            if (storedStudentId != null) {
              await prefs.setString('studentId', storedStudentId);
            }

          }

          return {'success': true, 'message': 'Login successful'};
        } else {
          return {'success': false, 'message': 'Token or student data missing'};
        }
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed with status ${response.statusCode}'
        };
      }
    } catch (e) {
      print("Error during login: $e");
      return {'success': false, 'message': 'An error occurred during login'};
    }
  }

  // Check if student is logged in
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

  // Get stored user type (student)
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  // Logout student and clear stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
    await prefs.remove('userType');
    await prefs.remove('isLoggedIn');
    await prefs.remove('studentData');
    await prefs.remove('studentId');
  }



  Future<Map<String, dynamic>?> fetchStudentDashboard(String studentId) async   {
    final url = Uri.parse('${baseUrlMain}/student/me/$studentId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Error fetching student dashboard: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception caught: $e');
      return null;
    }
  }


  Future<String?> getStudentDbId() async {
    final prefs = await SharedPreferences.getInstance();

    // Try direct key first
    final dbId = prefs.getString('studentDbId');
    if (dbId != null) return dbId;

    // Fallback to parsing student data
    final studentData = prefs.getString('studentData');
    if (studentData != null) {
      final Map<String, dynamic> studentMap = json.decode(studentData);
      return studentMap['_id'];
    }

    return null;
  }

}


