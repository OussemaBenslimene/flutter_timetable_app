import 'package:flutter/material.dart';
import 'package:timetable/reusableCrud.dart';

class ClassesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CrudPage(
      title: "Classes",
      apiEndpoint: "classes",
      attributes: ["id", "name"],
    );
  }
}
