import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:studentdb/Backend/teacherAuth.dart';

import '../Constant.dart';

Future<void> addStudent({
  required String studentId,
  required String name,
  required String classId,
  required int rollNo,
  required String teacherId,
  required String email,
}) async {
  final url = Uri.parse('${baseUrlMain}/studentAuth/add');

  final body = json.encode({
    'studentId': studentId,
    'name': name,
    'classId': classId,
    'rollNo': rollNo,
    'email': email,
    'teacherId': teacherId,
  });


  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    final result = json.decode(response.body);
    print("✅ Student added: ${result['message']}");
  } else {
    final error = json.decode(response.body);
    print("❌ Failed response body: ${response.body}");
    throw Exception("Failed to add student: ${error['message'] ?? 'Unknown error'}");
  }

}


Future<List<Map<String, dynamic>>> getStudentsByClassAndTeacher(String classId) async {
  final TeacherAuthService _authService = TeacherAuthService();
  final teacherId = await _authService.getTeacherId();
  final response = await http.get(
    Uri.parse('$baseUrlMain/student/class/$classId/teacher/$teacherId'),
    headers: {
      'Content-Type': 'application/json',
      // optionally add auth headers if needed
      // 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List students = data['students'];
    return students.map((s) => {
      'name': s['name'],
      'rollNo': s['rollNo'].toString(),
      'class': s['classId']['name'], // because of populate
      'teacher': s['teacherId']['name']
    }).toList();
  } else {
    throw Exception('Failed to fetch students');
  }
}

