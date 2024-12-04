import 'package:flutter/material.dart';
import 'package:timetable/reusableCrud.dart';

class TeachersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CrudPage(
      title: "Teachers",
      apiEndpoint: "teachers",
      attributes: ["id", "name"],
    );
  }
}
