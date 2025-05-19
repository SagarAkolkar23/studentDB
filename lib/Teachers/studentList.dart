import 'package:flutter/material.dart';
import '../Backend/addStudent.dart';
import '../Backend/classList.dart';
import '../Backend/teacherAuth.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  State<StudentList> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentList> {
  final ClassService _classService = ClassService();
  final TeacherAuthService _authService = TeacherAuthService();


  List<Map<String, dynamic>> _classes = [];
  String? _selectedClassId;
  bool _isLoadingClasses = false;

  late Future<List<Map<String, dynamic>>> studentListFuture;

  @override
  void initState() {
    super.initState();
    studentListFuture = Future.value([]); // ✅ Prevent LateInitializationError
    _fetchClasses(); // will update this once class is fetched
  }

  Future<void> _fetchClasses() async {
    setState(() {
      _isLoadingClasses = true;

    });
    try {
      final classes = await _classService.getClassesByTeacher();
      setState(() {
        _classes = classes;
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
          studentListFuture = getStudentsByClassAndTeacher(_selectedClassId!); // ✅ Initialize future
        }
      });
    } catch (e) {
      print('Failed to fetch classes: $e');
    } finally {
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  Widget _buildStudentCard(String name, String rollNumber) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        tileColor: Colors.teal.shade50,
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          "Roll No: $rollNumber",
          style: const TextStyle(
            color: Colors.teal,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
        onTap: () {
          Navigator.pushNamed(context, '/studentDetails');
        },
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    final studentIdController = TextEditingController();
    final rollNoController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Student"),
          content: _isLoadingClasses
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                ),
                TextField(
                  controller: rollNoController,
                  decoration: const InputDecoration(labelText: 'Roll No'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email ID'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    studentIdController.text.isEmpty ||
                    rollNoController.text.isEmpty ||
                    _selectedClassId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  final teacherId = await _authService.getTeacherId();
                  if (teacherId == null) throw Exception("Teacher ID not found");

                  await addStudent(
                    studentId: studentIdController.text,
                    name: nameController.text,
                    classId: _selectedClassId!,
                    rollNo: int.tryParse(rollNoController.text) ?? 0,
                    email: emailController.text,
                    teacherId: teacherId,
                  );

                  setState(() {
                    studentListFuture = getStudentsByClassAndTeacher(_selectedClassId!);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Student added successfully")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add student: $e')),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student List"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: studentListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No students found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final students = snapshot.data!;
            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(student['name'], student['rollNo'].toString());
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
