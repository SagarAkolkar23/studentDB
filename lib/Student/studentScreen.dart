import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class studentScreen extends StatefulWidget{

  const studentScreen({super.key});

  @override
  State<studentScreen> createState() => _studentScreenState();

}

class _studentScreenState extends State<studentScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Dashboard"),
      ),
      body: Column(
        children: [
          Text("Welcome to student dashboard")
          ]
      ),
    );
  }
}