import 'package:flutter/material.dart';
import 'package:studentdb/Student/studentLogin.dart';
import 'package:studentdb/Student/studentScreen.dart';
import 'package:studentdb/Teachers/teacherSignUp.dart';
import 'package:studentdb/splashScreen.dart';
import 'package:studentdb/userSelectionScreen.dart';

import 'Student/studentSignUp.dart';
import 'Teachers/classList.dart';
import 'Teachers/studentList.dart';
import 'Teachers/teacherLogin.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentDB',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/teacherSignUp': (context) => const teacherSignUp(),
        '/userSelectionScreen': (context) =>  UserSelectionScreen(),
        '/studentSignUp': (context) => const studentSignUp(),
        '/teacherLogin': (context) => const teacherLogin(),
        '/classList': (context) => const classList(),
        '/studentLogin': (context) => const studentLogin(),
        '/studentScreen': (context) => const StudentScreen(),
        '/studentList': (context) => const StudentList()
      },


      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFE0F2F1), // Light teal background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF009688), // Teal
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF009688), // Teal
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.teal),
        dialogBackgroundColor: Color(0xFFE0F2F1),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

