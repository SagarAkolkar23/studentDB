import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Backend/studentAuth.dart';
import '../Data/StudentModel.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final StudentAuthService authService = StudentAuthService();

  bool isLoading = true;
  StudentModel? student;
  void showSnackBar(String message, {Color bgColor = Colors.black}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: bgColor,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  Future<void> _loadStudentProfile() async {
    setState(() {
      isLoading = true;
    });

    // Get student DB ID from shared preferences using auth service
    final studentDbId = await authService.getStudentDbId();

    if (studentDbId == null) {
      setState(() {
        isLoading = false;
      });
      showSnackBar("Student ID not found. Please log in again.");
      return;
    }

    final profileData = await authService.fetchStudentDashboard(studentDbId);
    print(profileData);
    if (profileData != null && profileData['success'] == true) {
      setState(() {
        student = StudentModel.fromJson(profileData['student']);
        isLoading = false;
      });
      showSnackBar("Profile loaded successfully.");
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar("Failed to fetch student data.");
    }

  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildProfileRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : student == null
          ? const Center(child: Text("Failed to load profile"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${student!.name}",
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Student Data Section
              _buildSectionTitle("Student Information"),
              _buildProfileRow("Email", student!.email),
              _buildProfileRow("School", student!.teacher?.school),

              // Class Data Section
              _buildSectionTitle("Class Details"),
              _buildProfileRow("Class ID", student!.classInfo?.id),
              _buildProfileRow("Class Name", student!.classInfo?.name),

              // Teacher Data Section
              _buildSectionTitle("Class Teacher Details"),
              _buildProfileRow("Teacher Name", student!.teacher?.name),
              _buildProfileRow(
                  "Teacher Contact", student!.teacher?.email),

              const SizedBox(height: 30),

              // Subjects List Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text("View Subjects"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    // Navigate to Subjects List Screen
                    Navigator.pushNamed(context, '/subjectsList');
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      textStyle: const TextStyle(fontSize: 18)),
                  onPressed: () async {
                    await authService.logout();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text("Logout"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
