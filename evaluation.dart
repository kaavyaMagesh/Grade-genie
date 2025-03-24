import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EvaluationPage extends StatefulWidget {
  final String submissionId;
  final String assignmentId;
  final String studentId;
  final String fileUrl;

  const EvaluationPage({
    Key? key,
    required this.submissionId,
    required this.assignmentId,
    required this.studentId,
    required this.fileUrl,
  }) : super(key: key);

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();

  Future<void> _saveEvaluation() async {
    try {
      double? grade = double.tryParse(_gradeController.text);
      if (grade == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("⚠️ Enter a valid grade")));
        return;
      }

      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(widget.submissionId)
          .update({
            'grade': grade,
            'feedback': _feedbackController.text,
            'graded': true, // ✅ Ensures student sees the update
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Evaluation saved successfully")),
      );
      Navigator.pop(context, true); // ✅ Return to submissions list
    } catch (e) {
      print("ERROR: Failed to save evaluation → $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Evaluate Submission",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD1B3FF), // Light purple app bar
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD7BDE2),
              Color(0xFF8E44AD),
            ], // Grade Genie Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "📌 Student ID: ${widget.studentId}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // File URL
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "📎 File: ${widget.fileUrl}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Feedback Input
              TextField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  labelText: "Enter Feedback",
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.deepPurple),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Grade Input
              TextField(
                controller: _gradeController,
                decoration: InputDecoration(
                  labelText: "Enter Grade",
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),

              // Return Evaluation Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveEvaluation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "📩 Return Evaluation",
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
    );
  }
}
