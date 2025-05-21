import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../Constant.dart';


Future<void> updateStudentSubjects(String studentId, List<String> subjects) async {
  final url = Uri.parse('$baseUrlMain/subject/$studentId/subjects');

  final response = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"subjects": subjects}),
  );

  debugPrint("🔁 Status Code: ${response.statusCode}");
  debugPrint("🔁 Response Body: '${response.body}'");

  if (response.statusCode == 200) {
    debugPrint("✅ Subjects updated successfully");
  } else {
    try {
      final error = jsonDecode(response.body);
      throw Exception("Failed to update subjects: ${error['message']}");
    } catch (e) {
      throw Exception("Failed to update subjects: Unexpected response from server");
    }
  }
}

Future<void> deleteSubjectFromStudent(String studentId, String subject) async {
  final url = Uri.parse('${baseUrlMain}/subject/$studentId/delete');

  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'subject': subject}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Subject deleted successfully: ${data['student']}");
    } else {
      final error = jsonDecode(response.body);
      print("❌ Failed to delete subject: ${error['message']}");
    }
  } catch (e) {
    print("⚠️ Error deleting subject: $e");
  }
}
