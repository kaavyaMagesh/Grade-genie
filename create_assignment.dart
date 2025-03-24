import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAssignment extends StatefulWidget {
  final String classroomId;

  CreateAssignment({required this.classroomId});

  @override
  _CreateAssignmentState createState() => _CreateAssignmentState();
}

class _CreateAssignmentState extends State<CreateAssignment> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;

  Future<void> _pickDueDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.deepPurple,
            colorScheme: ColorScheme.light(primary: Colors.deepPurple),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _createAssignment() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required!")));
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
        'dueDate': _dueDate,
        'submissions': [],
      });

      await FirebaseFirestore.instance
          .collection('classrooms')
          .doc(widget.classroomId)
          .update({
            'assignments': FieldValue.arrayUnion([assignmentRef.id]),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment created successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("Error creating assignment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error creating assignment")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Assignment"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDEC8F0), Color(0xFF7E57C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputCard(
                label: "Assignment Title",
                controller: _titleController,
              ),
              const SizedBox(height: 10),
              _buildInputCard(
                label: "Description",
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              _buildDatePicker(context),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _createAssignment,
                  child: const Text(
                    "Create Assignment",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Colors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.deepPurple),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          _dueDate == null
              ? "Pick a due date"
              : "Due Date: ${_dueDate!.toLocal()}".split(' ')[0],
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        onTap: () => _pickDueDate(context),
      ),
    );
  }
}
