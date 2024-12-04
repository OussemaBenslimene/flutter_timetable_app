import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timetable/services/AuthenticationService.dart';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late Future<List<dynamic>> sessions;
  late Future<List<dynamic>> classes;
  late Future<List<dynamic>> teachers;
  late Future<List<dynamic>> subjects;
  late Future<List<dynamic>> rooms;

  @override
  void initState() {
    super.initState();
    sessions = fetchSessions();
    classes = fetchClasses();
    teachers = fetchTeachers();
    subjects = fetchSubjects();
    rooms = fetchRooms();
  }

  Future<List<dynamic>> fetchSessions() async {
    final token = await AuthenticationService().getToken();
    final response = await http.get(
      Uri.parse('http://localhost:5000/sessions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  Future<List<dynamic>> fetchClasses() async {
    final token = await AuthenticationService().getToken();
    final response = await http.get(
      Uri.parse('http://localhost:5000/classes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load classes');
    }
  }

  Future<List<dynamic>> fetchTeachers() async {
    final token = await AuthenticationService().getToken();
    final response = await http.get(
      Uri.parse('http://localhost:5000/teachers'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load teachers');
    }
  }

  Future<List<dynamic>> fetchSubjects() async {
    final token = await AuthenticationService().getToken();
    final response = await http.get(
      Uri.parse('http://localhost:5000/subjects'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<List<dynamic>> fetchRooms() async {
    final token = await AuthenticationService().getToken();
    final response = await http.get(
      Uri.parse('http://localhost:5000/rooms'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timetable")),
      body: FutureBuilder<List<dynamic>>(
        future: sessions,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!;
          Map<String, List<Map<String, dynamic>>> daySessions = {
            "Monday": [],
            "Tuesday": [],
            "Wednesday": [],
            "Thursday": [],
            "Friday": [],
            "Saturday": [],
            "Sunday": []
          };

          for (var session in sessions) {
            daySessions[session["day"]]!.add(session);
          }

          List<String> timeSlots = [
            "08:00 - 09:00",
            "09:00 - 10:00",
            "10:00 - 11:00",
            "11:00 - 12:00",
            "12:00 - 01:00",
            "01:00 - 02:00",
            "02:00 - 03:00",
            "03:00 - 04:00",
            "04:00 - 05:00"
          ];

          return FutureBuilder<List<dynamic>>(
            future: Future.wait([classes, teachers, subjects, rooms]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final classes = snapshot.data![0];
              final teachers = snapshot.data![1];
              final subjects = snapshot.data![2];
              final rooms = snapshot.data![3];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FixedColumnWidth(100),
                      },
                      children: [
                        // Table header (Days of the week)
                        TableRow(
                          children: [
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Time / Day",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            ...["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                                .map((day) => TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          day,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ))
                                .toList()
                          ],
                        ),
                        // Time slots and the sessions for each time slot
                        for (var timeSlot in timeSlots)
                          TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(timeSlot),
                                ),
                              ),
                              ...["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                                  .map((day) {
                                var sessionForDay = daySessions[day]?.firstWhere(
                                    (session) =>
                                        session["beginTime"] == timeSlot.split(" - ")[0] &&
                                        session["endTime"] == timeSlot.split(" - ")[1],
                                    orElse: () => {});

                                // Fetching class, teacher, subject, and room details
                                String className = getClassName(sessionForDay?["class_id"], classes);
                                String teacherName = getTeacherName(sessionForDay?["teacher_id"], teachers);
                                String subjectName = getSubjectName(sessionForDay?["subject_id"], subjects);
                                String roomName = getRoomName(sessionForDay?["room_id"], rooms);

                                return TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: sessionForDay?.isNotEmpty ?? false
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Class: $className"),
                                              Text("Teacher: $teacherName"),
                                              Text("Subject: $subjectName"),
                                              Text("Room: $roomName"),
                                            ],
                                          )
                                        : const Text(""),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper functions to fetch names based on IDs
  String getClassName(dynamic classId, List<dynamic> classes) {
  final classObj = classes.firstWhere(
    (classItem) => classItem["id"] == classId, // No type conversion needed
    orElse: () => {},
  );
  return classObj.isNotEmpty ? classObj["name"] : "N/A";
}

String getTeacherName(dynamic teacherId, List<dynamic> teachers) {
  final teacherObj = teachers.firstWhere(
    (teacher) => teacher["id"] == teacherId, // No type conversion needed
    orElse: () => {},
  );
  return teacherObj.isNotEmpty ? teacherObj["name"] : "N/A";
}

String getSubjectName(dynamic subjectId, List<dynamic> subjects) {
  final subjectObj = subjects.firstWhere(
    (subject) => subject["id"] == subjectId, // No type conversion needed
    orElse: () => {},
  );
  return subjectObj.isNotEmpty ? subjectObj["name"] : "N/A";
}

String getRoomName(dynamic roomId, List<dynamic> rooms) {
  final roomObj = rooms.firstWhere(
    (room) => room["id"] == roomId, // No type conversion needed
    orElse: () => {},
  );
  return roomObj.isNotEmpty ? roomObj["name"] : "N/A";
}
}
