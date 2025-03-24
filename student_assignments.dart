import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_assignments_details.dart'; // ✅ Import the new details page

class StudentAssignments extends StatelessWidget {
  final String classroomId;
  final String studentId;

  const StudentAssignments({
    Key? key,
    required this.classroomId,
    required this.studentId,
  }) : super(key: key);

  Stream<QuerySnapshot> fetchAssignments() {
    return FirebaseFirestore.instance
        .collection('assignments')
        .where('classroomId', isEqualTo: classroomId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Assignments",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple, // ✅ Purple AppBar
        elevation: 4,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: StreamBuilder<QuerySnapshot>(
          stream: fetchAssignments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No assignments found.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E44AD),
                  ), // ✅ Purple text
                ),
              );
            }

            var assignments = snapshot.data!.docs;

            return ListView.builder(
              itemCount: assignments.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                var assignment = assignments[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(
                      assignment['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E44AD), // ✅ Purple Title
                      ),
                    ),
                    subtitle: Text(
                      "Due Date: ${assignment['dueDate'].toDate()}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red, // ✅ Red for urgency
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF8E44AD),
                    ), // ✅ Purple Icon
                    onTap: () {
                      // ✅ Navigate to StudentAssignmentDetails
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StudentAssignmentDetails(
                                assignmentId:
                                    assignment.id, // ✅ Pass assignment ID
                                title: assignment['title'],
                                dueDate:
                                    assignment['dueDate'].toDate().toString(),
                                description: assignment['description'],
                                studentId: studentId, // ✅ Pass student ID
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
