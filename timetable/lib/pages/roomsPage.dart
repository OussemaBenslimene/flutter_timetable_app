import 'package:flutter/material.dart';
import 'package:timetable/reusableCrud.dart';

class RoomsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CrudPage(
      title: "Rooms",
      apiEndpoint: "rooms",
      attributes: ["id", "name", "capacity"],
    );
  }
}
