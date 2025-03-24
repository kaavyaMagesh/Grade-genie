import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateClassroom extends StatefulWidget {
  final String mentorId;

  CreateClassroom({required this.mentorId});

  @override
  _CreateClassroomState createState() => _CreateClassroomState();
}

class _CreateClassroomState extends State<CreateClassroom> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _studentsController = TextEditingController();

  Future<void> enrollStudent(String studentId, String classroomId) async {
    try {
      await FirebaseFirestore.instance
          .collection('classrooms')
          .doc(classroomId)
          .update({
            'studentIds': FieldValue.arrayUnion([studentId]),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .update({
            'classes_enrolled': FieldValue.arrayUnion([classroomId]),
          });

      print("✅ Student $studentId enrolled in classroom $classroomId!");
    } catch (e) {
      print("❌ Error enrolling student $studentId: $e");
    }
  }

  Future<void> createClassroom() async {
    String className = _classNameController.text.trim();
    String subject = _subjectController.text.trim();
    List<String> studentIds =
        _studentsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    if (className.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Class name and subject are required!")),
      );
      return;
    }

    try {
      DocumentReference classroomRef =
          FirebaseFirestore.instance.collection('classrooms').doc();

      await classroomRef.set({
        'classroomId': classroomRef.id,
        'className': className,
        'mentorId': widget.mentorId,
        'studentIds': studentIds,
        'subject': subject,
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.mentorId)
          .update({
            'classes_created': FieldValue.arrayUnion([classroomRef.id]),
          });

      for (String studentId in studentIds) {
        await enrollStudent(studentId, classroomRef.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Classroom created successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error creating classroom: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Classroom"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Classroom Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(
                labelText: "Classroom Name",
                prefixIcon: const Icon(Icons.class_, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: "Subject",
                prefixIcon: const Icon(
                  Icons.menu_book,
                  color: Colors.deepPurple,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _studentsController,
              decoration: InputDecoration(
                labelText: "Student UIDs (comma-separated)",
                prefixIcon: const Icon(Icons.people, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: createClassroom,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Create Classroom"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 209, 199, 235),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
