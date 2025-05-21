import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:studentdb/Backend/teacherAuth.dart';
import 'package:studentdb/Constant.dart';

class ClassService {
  final TeacherAuthService _authService = TeacherAuthService();

  // ✅ Fetch classes by teacher
  Future<List<Map<String, dynamic>>> getClassesByTeacher() async {
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
      final classList = List<Map<String, dynamic>>.from(data['_class']);
      return classList;
    } else {
      throw Exception('Failed to fetch classes');
    }
  }

  // ✅ Add new class
  Future<bool> addClass(String name, String section) async {
    final teacherId = await _authService.getTeacherId();
    if (teacherId == null) throw Exception("Teacher ID not found");

    final url = Uri.parse('$baseUrlMain/class/add');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "section": section,
        "teacherId": teacherId
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // ✅ Fetch subjects for a class
  Future<List<String>> getSubjectsForClass(String classId) async {
    final url = Uri.parse('$baseUrlMain/subject/$classId/subjects');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final subjects = List<String>.from(data['subjects']);
      return subjects;
    } else {
      throw Exception('Failed to fetch subjects for class');
    }
  }

  // ✅ Add or update subjects for a class
  Future<bool> addSubjectsToClass(String classId, List<String> subjects) async {
    final url = Uri.parse('$baseUrlMain/subject/$classId/subjects');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "subjects": subjects,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error: ${response.body}");
      return false;
    }
  }


}
