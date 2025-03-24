import 'package:flutter/material.dart';

class GradePage extends StatelessWidget {
  final String assignmentDescription;
  final String feedback;
  final String grade;

  const GradePage({
    Key? key,
    required this.assignmentDescription,
    required this.feedback,
    required this.grade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grade & Feedback",
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              color: Colors.white, // ✅ White for contrast
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Assignment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E44AD), // ✅ Purple text
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assignmentDescription,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 30, thickness: 1),

                    Text(
                      "Feedback",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E44AD), // ✅ Purple text
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(feedback, style: const TextStyle(fontSize: 16)),
                    const Divider(height: 30, thickness: 1),

                    Text(
                      "Grade",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E44AD), // ✅ Purple text
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8E44AD), // ✅ Purple button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                        ),
                        child: const Text(
                          "Back to Submissions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // ✅ White text
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
      ),
    );
  }
}
