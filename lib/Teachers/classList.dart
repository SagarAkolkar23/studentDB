import 'package:flutter/material.dart';
import '../Backend/classList.dart'; // Import your ClassService here

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassList> {
  final ClassService _classService = ClassService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  List<Map<String, String>> _classes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final classData = await _classService.getClassesByTeacher();
      setState(() {
        _classes = classData.map<Map<String, String>>((cls) {
          return {
            'id': cls['_id'],
            'name': "Class ${cls['name']} - Section ${cls['section']}"
          };
        }).toList();
      });
    } catch (e) {
      _showSnackbar("Failed to load classes: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addClass(String name, String section) async {
    try {
      bool success = await _classService.addClass(name, section);
      if (success) {
        await _loadClasses();
        Navigator.pop(context); // Close the dialog
        _showSnackbar("Class added successfully");
        nameController.clear();
        sectionController.clear();
      } else {
        _showSnackbar("Failed to add class");
      }
    } catch (e) {
      _showSnackbar("Error adding class: $e");
    }
  }

  Future<void> _addSubjects(String classId, List<String> subjects) async {
    try {
      bool success = await _classService.addSubjectsToClass(classId, subjects);
      if (success) {
        _showSnackbar("Subjects added successfully");
      } else {
        _showSnackbar("Failed to add subjects");
      }
    } catch (e) {
      _showSnackbar("Error adding subjects: $e");
    }
  }

  void _showAddSubjectsDialog(String classId) {
    final TextEditingController subjectController = TextEditingController();
    List<String> subjectList = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Subjects"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: "Subject Name",
                      hintText: "e.g., Mathematics",
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      final subject = subjectController.text.trim();
                      if (subject.isNotEmpty) {
                        setState(() {
                          subjectList.add(subject);
                          subjectController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add to List"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  subjectList.isEmpty
                      ? const Text("No subjects added yet.")
                      : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: subjectList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(subjectList[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                subjectList.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () async {
                    if (subjectList.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please add at least one subject")),
                      );
                      return;
                    }

                    final success = await _classService.addSubjectsToClass(classId, subjectList);
                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Subjects added successfully")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to add subjects")),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildClassCard(Map<String, String> classInfo) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        tileColor: Colors.teal.shade50,
        title: Text(
          classInfo['name'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontSize: 18,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
        onTap: () {
          Navigator.pushNamed(context, '/studentList');
        },
      ),
    );
  }


  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Class"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Class Name",
                  hintText: "e.g., 10",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: "Section",
                  hintText: "e.g., A",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.clear();
                sectionController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              onPressed: () {
                final name = nameController.text.trim();
                final section = sectionController.text.trim();

                if (name.isEmpty || section.isEmpty) {
                  _showSnackbar("Please fill all fields");
                  return;
                }
                _addClass(name, section);
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
        title: const Text("Class List"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
          ? const Center(
        child: Text(
          "No classes added yet.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final classInfo = _classes[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              tileColor: Colors.teal.shade50,
              title: Text(
                classInfo['name'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 18,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                  TextButton(
                    onPressed: () {
                      // Show dialog to add subjects for the class
                      _showAddSubjectsDialog(classInfo['id']!);
                    },
                    child: const Text(
                      "Add Subjects",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/studentList');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}



