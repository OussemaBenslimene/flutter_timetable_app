import 'package:flutter/material.dart';
import 'package:timetable/reusableCrud.dart';

class SubjectsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CrudPage(
      title: "Subjects",
      apiEndpoint: "subjects",
      attributes: ["id", "name", "code"],
    );
  }
}
