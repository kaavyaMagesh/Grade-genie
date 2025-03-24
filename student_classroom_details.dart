import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_assignments.dart';
import 'student_submissions.dart';
import 'forum.dart';
import 'student_notes.dart';

class StudentClassroomDetails extends StatefulWidget {
  final String classroomId;
  final String className;

  const StudentClassroomDetails({
    Key? key,
    required this.classroomId,
    required this.className,
    required String studentId,
  }) : super(key: key);

  @override
  _StudentClassroomDetailsState createState() =>
      _StudentClassroomDetailsState();
}

class _StudentClassroomDetailsState extends State<StudentClassroomDetails> {
  String studentName = "";
  String studentId = "";

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot studentSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (studentSnapshot.exists) {
          setState(() {
            studentId = user.uid;
            studentName = studentSnapshot['name'] ?? "Unknown Student";
          });
        }
      }
    } catch (e) {
      print("Error fetching student details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8DAEF), Color(0xFFD2B4DE)], // Lavender Gradient
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Classroom ID: ${widget.classroomId}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E44AD), // Purple Text
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Student Name: ${studentName.isEmpty ? 'Loading...' : studentName}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E44AD), // Purple Text
                ),
              ),
              const SizedBox(height: 20),

              _buildButton("View Assignments", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StudentAssignments(
                          classroomId: widget.classroomId,
                          studentId: studentId,
                        ),
                  ),
                );
              }),

              _buildButton("View Submissions", () {
                if (studentId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => StudentSubmissions(
                            studentId: studentId,
                            classroomId: widget.classroomId,
                          ),
                    ),
                  );
                } else {
                  _showSnackbar("Loading student details...");
                }
              }),

              _buildButton("View Notes", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            StudentNotesPage(classroomId: widget.classroomId),
                  ),
                );
              }),

              _buildButton("Forum", () {
                if (studentId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ForumPage(
                            forumId: widget.classroomId,
                            classroomId: widget.classroomId,
                            userId: studentId,
                          ),
                    ),
                  );
                } else {
                  _showSnackbar("Loading student details...");
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 **Reusable Button UI**
  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White Button
          foregroundColor: const Color(0xFF8E44AD), // Purple Text
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF8E44AD)), // Purple Border
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  /// 🔹 **Show Snackbar**
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
