import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_assignment.dart';
import 'view_submissions.dart';
import 'forum.dart';
import 'upload_notes.dart';

class ClassroomDetails extends StatelessWidget {
  final String classroomId;
  final String className;

  ClassroomDetails({required this.classroomId, required this.className});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          className,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        width: double.infinity, // ✅ Ensure it stretches fully
        height: double.infinity, // ✅ Fill the screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8DAEF),
              Color(0xFFD2B4DE),
            ], // ✅ Grade Genie Gradient
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white, // ✅ White background for contrast
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.class_,
                        color: Color(0xFF8E44AD), // ✅ Purple icon
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Classroom ID: $classroomId",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E44AD), // ✅ Purple text
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Action Buttons
              _buildActionButton(
                context,
                icon: Icons.assignment,
                label: "Create Assignment",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              CreateAssignment(classroomId: classroomId),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.visibility,
                label: "View Submissions",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ViewSubmissions(classroomId: classroomId),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.forum,
                label: "Forum",
                onTap: () {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ForumPage(
                              forumId: classroomId,
                              classroomId: classroomId,
                              userId: user.uid,
                            ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You need to log in first!"),
                      ),
                    );
                  }
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.upload_file,
                label: "Upload Notes",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              UploadNotesPage(classroomId: classroomId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 **Reusable Button UI**
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Color(0xFF8E44AD)), // ✅ Purple icon
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF8E44AD), // ✅ Purple text
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // ✅ White button background
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF8E44AD)), // ✅ Purple border
          ),
        ),
      ),
    );
  }
}
