import 'package:flutter/material.dart';
import 'package:timetable/services/AuthenticationService.dart';

class HomePage extends StatelessWidget {
  final AuthenticationService authService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          _buildButton(context, "Teachers", '/teachers'),
          _buildButton(context, "Sessions", '/sessions'),
          _buildButton(context, "Rooms", '/rooms'),
          _buildButton(context, "Classes", '/classes'),
          _buildButton(context, "Subjects", '/subjects'),
          _buildButton(context, "Timetable", '/timetable'),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, String route) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Center(child: Text(label, style: TextStyle(fontSize: 16))),
      ),
    );
  }
}
