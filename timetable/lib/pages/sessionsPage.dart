import 'package:flutter/material.dart';
import 'package:timetable/reusableCrud.dart';

class SessionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CrudPage(
      title: "Sessions",
      apiEndpoint: "sessions",
      attributes: [
        "id", "class_id", "subject_id", "teacher_id", "room_id", 
        "beginTime", "endTime", "day"
      ],
    );
  }
}
