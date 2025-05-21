import 'package:flutter/material.dart';
import 'package:studentdb/Student/studentLogin.dart';
import 'package:studentdb/Student/studentScreen.dart';
import 'package:studentdb/Teachers/teacherSignUp.dart';
import 'package:studentdb/splashScreen.dart';
import 'package:studentdb/userSelectionScreen.dart';

import 'Data/StudentModel.dart';
import 'Student/studentSignUp.dart';
import 'Student/studentSubject.dart';
import 'Student/addSubject.dart';
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
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/teacherSignUp':
            return MaterialPageRoute(builder: (_) => const teacherSignUp());
          case '/userSelectionScreen':
            return MaterialPageRoute(builder: (_) => UserSelectionScreen());
          case '/studentSignUp':
            return MaterialPageRoute(builder: (_) => const studentSignUp());
          case '/teacherLogin':
            return MaterialPageRoute(builder: (_) => const teacherLogin());
          case '/classList':
            return MaterialPageRoute(builder: (_) => const ClassList());
          case '/studentLogin':
            return MaterialPageRoute(builder: (_) => const studentLogin());
          case '/studentScreen':
            return MaterialPageRoute(builder: (_) => const StudentScreen());
          case '/studentList':
            return MaterialPageRoute(builder: (_) => const StudentList());
          case '/addSubject':
            return MaterialPageRoute(builder: (_) => const addSubjectsPage());

        // The important one: studentSubject needs a student argument
          case '/studentSubject':
            final args = settings.arguments;
            if (args is StudentModel) {
              return MaterialPageRoute(
                builder: (_) => StudentSubjectsScreen(student: args),
              );
            }
            // If no args or wrong type, show error page or fallback
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No student data provided for StudentSubjectsScreen'),
                ),
              ),
            );

          default:
          // Unknown route fallback
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
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
