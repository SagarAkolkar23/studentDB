import 'package:flutter/material.dart';

import '../Backend/classList.dart'; // Import your ClassService here

class classList extends StatefulWidget {
  const classList({super.key});

  @override
  State<classList> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<classList> {
  final ClassService _classService = ClassService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

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
          return _buildClassCard(_classes[index]);
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
