import 'package:flutter/material.dart';
import 'package:studentdb/Student/studentSubject.dart';
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

    final studentDbId = await authService.getStudentDbId();
    if (studentDbId == null) {
      setState(() {
        isLoading = false;
      });
      showSnackBar("Student ID not found. Please log in again.");
      return;
    }

    final profileData = await authService.fetchStudentDashboard(studentDbId);
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

  Widget _buildSectionCard({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueAccent),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
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
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
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
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "👋 Welcome, ${student!.name}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Student Info
              _buildSectionCard(
                title: "🎓 Student Information",
                items: [
                  _buildIconRow(Icons.person, "Name", student!.name),
                  _buildIconRow(Icons.email, "Email", student!.email),
                  _buildIconRow(Icons.school, "School", student!.teacher?.school),
                  _buildIconRow(Icons.account_circle_rounded, "Roll No", student!.rollNo)
                ],
              ),
              const SizedBox(height: 16),

              // Class Info
              _buildSectionCard(
                title: "🏫 Class Details",
                items: [
                  _buildIconRow(Icons.label, "Class Name", student!.classInfo?.name),
                  _buildIconRow(Icons.account_box_rounded, "Section", student!.classInfo?.section)
                ],
              ),
              const SizedBox(height: 16),

              // Teacher Info
              _buildSectionCard(
                title: "👩‍🏫 Class Teacher",
                items: [
                  _buildIconRow(Icons.person, "Name", student!.teacher?.name),
                  _buildIconRow(Icons.mail, "Email", student!.teacher?.email),
                ],
              ),
              const SizedBox(height: 30),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text("View Subjects"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentSubjectsScreen(student: student!),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await authService.logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}