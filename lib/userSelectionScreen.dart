import 'package:flutter/material.dart';
import '../Backend/studentAuth.dart';

class UserSelectionScreen extends StatelessWidget {
  UserSelectionScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select User"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Teacher Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                   onPressed: () {Navigator.pushNamed(context, '/teacherLogin');},
                  icon: const Icon(Icons.account_balance_outlined),
                  label: const Text("Teacher", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Student Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                   onPressed:() {Navigator.pushNamed(context, '/studentLogin');},
                  icon: const Icon(Icons.account_box_outlined),
                  label: const Text("Student", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
