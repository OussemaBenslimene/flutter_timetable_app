import 'package:flutter/material.dart';
import 'package:timetable/pages/classesPage.dart';
import 'package:timetable/pages/homePage.dart';
import 'package:timetable/pages/loginPage.dart';
import 'package:timetable/pages/registrationPage.dart';
import 'package:timetable/pages/roomsPage.dart';
import 'package:timetable/pages/sessionsPage.dart';
import 'package:timetable/pages/subjectsPage.dart';
import 'package:timetable/pages/teachersPage.dart';
import 'package:timetable/pages/timetablePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/teachers': (context) => TeachersPage(),
        '/sessions': (context) => SessionsPage(),
        '/rooms': (context) => RoomsPage(),
        '/classes': (context) => ClassesPage(),
        '/subjects': (context) => SubjectsPage(),
        '/timetable': (context) => TimetablePage(),
      },
    );
  }
}
