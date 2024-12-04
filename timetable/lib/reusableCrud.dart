import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timetable/services/AuthenticationService.dart';

class CrudPage extends StatefulWidget {
  final String title;
  final String apiEndpoint;
  final List<String> attributes;

  const CrudPage({
    Key? key,
    required this.title,
    required this.apiEndpoint,
    required this.attributes,
  }) : super(key: key);

  @override
  _CrudPageState createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  late Future<List<dynamic>> items;

  @override
  void initState() {
    super.initState();
    items = fetchItems();
  }

  Future<List<dynamic>> fetchItems() async {
    final token = await AuthenticationService().getToken();
    final response = await http.get(
      Uri.parse('http://localhost:5000/${widget.apiEndpoint}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load ${widget.title}');
    }
  }

  Future<void> deleteItem(String id) async {
    final token = await AuthenticationService().getToken();
    
    await http.delete(
      Uri.parse('http://localhost:5000/${widget.apiEndpoint}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    setState(() {
      items = fetchItems();
    });
  }

  void showEditDialog(BuildContext context, dynamic item, Function(Map<String, dynamic>) onSave) {
    final controllers = <String, TextEditingController>{};
    String selectedDay = item?["day"] ?? "Monday"; // Default to "Monday" if not selected

    for (var attr in widget.attributes) {
      if (attr != "day") {
        controllers[attr] = TextEditingController(text: item?[attr]?.toString() ?? '');
      }
    }

    // Weekdays list for dropdown
    const List<String> weekdays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? "Add ${widget.title}" : "Edit ${widget.title}"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Add other text fields for class_id, subject_id, etc.
              for (var attr in widget.attributes)
                if (attr != "day") 
                  TextField(
                    controller: controllers[attr],
                    decoration: InputDecoration(labelText: attr),
                  ),
              
              // Only show the day dropdown if the apiEndpoint is "sessions"
              if (widget.apiEndpoint == "sessions") 
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: InputDecoration(labelText: 'Day'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDay = newValue!;
                    });
                  },
                  items: weekdays.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final data = <String, dynamic>{};
              for (var attr in widget.attributes) {
                if (attr == "day") {
                  data[attr] = selectedDay;
                } else {
                  data[attr] = controllers[attr]?.text;
                }
              }
              onSave(data);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    final token = await AuthenticationService().getToken();
    await http.post(
      Uri.parse('http://localhost:5000/${widget.apiEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    setState(() {
      items = fetchItems();
    });
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    final token = await AuthenticationService().getToken();
    await http.put(
      Uri.parse('http://localhost:5000/${widget.apiEndpoint}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    setState(() {
      items = fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<dynamic>>(
        future: items,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return Column(
            children: [
              ElevatedButton(
                onPressed: () => showEditDialog(context, null, (data) => addItem(data)),
                child: Text("Add ${widget.title}"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(widget.attributes.map((attr) => "${attr}: ${item[attr]}").join(", ")),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showEditDialog(context, item, (data) {
                                updateItem(item['id'], data);
                              }),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteItem(item['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
