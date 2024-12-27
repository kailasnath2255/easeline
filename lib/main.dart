import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_page.dart';
import 'admin_page.dart';
import 'hod_page.dart';
import 'faculty_page.dart';
import 'student_page.dart';
import 'volunteer_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");
    runApp(MyApp());
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/admin': (context) => AdminPage(),
        '/hod': (context) => HODPage(),
        '/faculty': (context) => FacultyPage(),
        '/student': (context) => StudentPage(),
        '/volunteer': (context) => VolunteerPage(),
      },
    );
  }
}
