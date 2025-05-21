import 'package:flutter/material.dart';
import '../Backend/studentSubjects.dart';
import '../Data/StudentModel.dart';

class StudentSubjectsScreen extends StatefulWidget {
  final StudentModel student;

  const StudentSubjectsScreen({super.key, required this.student});

  @override
  State<StudentSubjectsScreen> createState() => _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends State<StudentSubjectsScreen> {
  late List<String> subjects;

  @override
  void initState() {
    super.initState();
    subjects = widget.student.subjects ?? [];
  }

  Future<void> deleteSubject(String subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm"),
        content: Text("Are you sure you want to delete \"$subject\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await deleteSubjectFromStudent(widget.student.id, subject); // 🧠 This should call your API
      setState(() {
        subjects.remove(subject); // 🧼 Update local state to refresh UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Subjects"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: subjects.isEmpty
            ? const Center(
          child: Text(
            "No subjects added yet.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.separated(
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return ListTile(
              leading: const Icon(Icons.book, color: Colors.deepPurple),
              title: Text(
                subject,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteSubject(subject),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/addSubject');
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Subject"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
