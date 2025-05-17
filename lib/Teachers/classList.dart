import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentdb/Constant.dart';

class classList extends StatefulWidget {
  const classList({super.key});

  @override
  State<classList> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<classList> {

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  final List<String> _classes = [];


  void _showAddClassDialog() {
    final nameController = TextEditingController();
    final sectionController = TextEditingController();

    String baseUrl = "${baseUrlMain}/class/add";

    Future<void> addClass() async {
      final className = nameController.text.trim();
      final section = sectionController.text.trim();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? teacherId = prefs.getString('teacherId');

      if (className.isEmpty || section.isEmpty || teacherId == null) {
        _showSnackbar("Please fill all fields and ensure you're logged in.");
        return;
      }

      try {
        print("Sending: { name: $className, section: $section, teacherId: $teacherId }");
        final response = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': className,
            'section': section,
            'teacherId': teacherId,
          }),
        );

        if (response.statusCode == 200) {
          final newClass = "Class $className - Section $section";
          setState(() {
            _classes.add(newClass);
          });
          Navigator.pop(context);
          _showSnackbar("Class $className added successfully");
        } else {
          _showSnackbar("Failed to add class. Status: ${response.statusCode}");
        }
      } catch (error) {
        _showSnackbar("Error occurred: $error");
      }
    }


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
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              onPressed: addClass,
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassCard(String className) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        tileColor: Colors.teal.shade50,
        title: Text(
          className,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontSize: 18,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
        onTap: () {
          // Navigate to class detail page if needed
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
      body: _classes.isEmpty
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
