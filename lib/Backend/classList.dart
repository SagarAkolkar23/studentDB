import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:studentdb/Backend/teacherAuth.dart';
import 'package:studentdb/Constant.dart';

class ClassService {
  final TeacherAuthService _authService = TeacherAuthService();

  // Fetch classes for logged-in teacher
  Future<List<dynamic>> getClassesByTeacher() async {
    final teacherId = await _authService.getTeacherId();
    if (teacherId == null) throw Exception("Teacher ID not found");

    final url = Uri.parse('$baseUrlMain/class/teacher/$teacherId');
    final token = await _authService.getToken();

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['_class'] ?? [];
    } else {
      throw Exception('Failed to fetch classes');
    }
  }

  // Add new class
  Future<bool> addClass(String name, String section) async {
    final url = Uri.parse('$baseUrlMain/class/add');
    final token = await _authService.getToken();

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"name": name, "section": section}),
    );

    return response.statusCode == 200;
  }
}
