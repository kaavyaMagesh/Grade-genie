import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAssignmentDetails extends StatefulWidget {
  final String assignmentId;
  final String title;
  final String dueDate;
  final String description;
  final String studentId;

  const StudentAssignmentDetails({
    Key? key,
    required this.assignmentId,
    required this.title,
    required this.dueDate,
    required this.description,
    required this.studentId,
  }) : super(key: key);

  @override
  _StudentAssignmentDetailsState createState() =>
      _StudentAssignmentDetailsState();
}

class _StudentAssignmentDetailsState extends State<StudentAssignmentDetails> {
  TextEditingController answerController = TextEditingController();
  TextEditingController fileUrlController = TextEditingController();
  bool isSubmitting = false;

  // 🔹 Submit assignment
  Future<void> submitAssignment() async {
    if (fileUrlController.text.isEmpty && answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter an answer or provide a file URL."),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    var existingSubmission =
        await FirebaseFirestore.instance
            .collection('submissions')
            .where('assignment_id', isEqualTo: widget.assignmentId)
            .where('student_id', isEqualTo: widget.studentId)
            .get();

    if (existingSubmission.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have already submitted this assignment!"),
        ),
      );
      setState(() => isSubmitting = false);
      return;
    }

    DocumentReference submissionRef = await FirebaseFirestore.instance
        .collection('submissions')
        .add({
          'assignment_id': widget.assignmentId,
          'student_id': widget.studentId,
          'file_url': fileUrlController.text,
          'answer': answerController.text,
          'feedback': "",
          'grade': "",
        });

    await submissionRef.update({'submission_id': submissionRef.id});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Assignment submitted successfully!")),
    );

    setState(() => isSubmitting = false);
    Navigator.pop(context); // ✅ Return to previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Assignment Details",
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            color: Colors.white, // ✅ White background for contrast
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8E44AD), // ✅ Purple Text
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Due Date: ${widget.dueDate}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(height: 30, thickness: 1),

                  // Answer input field
                  TextField(
                    controller: answerController,
                    decoration: InputDecoration(
                      labelText: "Enter your answer",
                      labelStyle: const TextStyle(
                        color: Color(0xFF8E44AD),
                      ), // ✅ Purple label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8E44AD),
                        ), // ✅ Purple border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8E44AD),
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // File URL input field
                  TextField(
                    controller: fileUrlController,
                    decoration: InputDecoration(
                      labelText: "Enter file URL",
                      labelStyle: const TextStyle(
                        color: Color(0xFF8E44AD),
                      ), // ✅ Purple label
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8E44AD),
                        ), // ✅ Purple border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8E44AD),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  Center(
                    child:
                        isSubmitting
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                              onPressed: submitAssignment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF8E44AD,
                                ), // ✅ Purple Button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 20,
                                ),
                              ),
                              child: const Text(
                                "Submit Assignment",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
