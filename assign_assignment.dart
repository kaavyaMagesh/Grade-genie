import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignAssignment extends StatefulWidget {
  final String classroomId;

  AssignAssignment({required this.classroomId});

  @override
  _AssignAssignmentState createState() => _AssignAssignmentState();
}

class _AssignAssignmentState extends State<AssignAssignment> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  Future<void> createAssignment() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    String dueDate =
        _dueDateController.text.trim(); // Convert to Timestamp later

    if (title.isEmpty || description.isEmpty || dueDate.isEmpty) {
      print("All fields are required.");
      return;
    }

    try {
      DocumentReference assignmentRef =
          FirebaseFirestore.instance.collection('assignments').doc();

      await assignmentRef.set({
        'assignment_id': assignmentRef.id,
        'classroomId': widget.classroomId,
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(
          DateTime.parse(dueDate),
        ), // Format: YYYY-MM-DD
        'submissions': [],
      });

      print("Assignment created successfully!");
      Navigator.pop(context);
    } catch (e) {
      print("Error creating assignment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assign Assignment")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Assignment Title"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _dueDateController,
              decoration: InputDecoration(labelText: "Due Date (YYYY-MM-DD)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createAssignment,
              child: Text("Create Assignment"),
            ),
          ],
        ),
      ),
    );
  }
}
