import 'package:flutter/material.dart';
import '../Backend/classList.dart';
import '../Backend/studentAuth.dart';
import '../Backend/studentSubjects.dart';
import '../Data/StudentModel.dart'; // Assuming getSubjectsForClass is in ClassService

class addSubjectsPage extends StatefulWidget {

  const addSubjectsPage({super.key});

  @override
  State<addSubjectsPage> createState() => _StudentSubjectsPageState();
}

class _StudentSubjectsPageState extends State<addSubjectsPage> {
  final StudentAuthService authService = StudentAuthService();
  final ClassService _classService = ClassService();

  List<String> allSubjects = [];
  List<String> selectedSubjects = [];
  bool isLoading = true;
  StudentModel? student;


  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
    fetchSubjects();

  }
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


  Future<void> fetchSubjects() async {
    try {
      final studentDbId = await authService.getStudentDbId();
      final profileData = await authService.fetchStudentDashboard(studentDbId!);

      if (profileData != null && profileData['success'] == true) {
        final studentModel = StudentModel.fromJson(profileData['student']);
        final classId = studentModel.classInfo!.id;

        final subjects = await _classService.getSubjectsForClass(classId);

        setState(() {
          student = studentModel;
          allSubjects = subjects;
          isLoading = false;
        });

        showSnackBar("Subjects loaded successfully.");
      } else {
        setState(() => isLoading = false);
        showSnackBar("Failed to load student profile.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      showSnackBar("Error fetching subjects: $e", bgColor: Colors.red);
    }
  }

  void submitSelectedSubjects() async {
    if (student == null) {
      showSnackBar("Student not loaded yet", bgColor: Colors.red);
      return;
    }

    try {
      await updateStudentSubjects(student!.id, selectedSubjects);
      showSnackBar("Subjects submitted successfully!", bgColor: Colors.green);

      Navigator.of(context).pop(true);
    } catch (e) {
      showSnackBar("Failed to submit subjects: $e", bgColor: Colors.red);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Subjects"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📚 Available Subjects",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: allSubjects.map((subject) {
                  bool isSelected = selectedSubjects.contains(subject);
                  return CheckboxListTile(
                    title: Text(subject),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedSubjects.add(subject);
                        } else {
                          selectedSubjects.remove(subject);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "✅ Your Selected Subjects",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (selectedSubjects.isEmpty)
                const Text("No subjects selected yet."),
              ...selectedSubjects.map((subject) {
                return ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(subject),
                );
              }).toList(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: submitSelectedSubjects,
                  icon: const Icon(Icons.done),
                  label: const Text("Submit Selection"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
