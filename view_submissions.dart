import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'evaluation.dart';

class ViewSubmissions extends StatefulWidget {
  final String classroomId;

  const ViewSubmissions({Key? key, required this.classroomId})
    : super(key: key);

  @override
  _ViewSubmissionsState createState() => _ViewSubmissionsState();
}

class _ViewSubmissionsState extends State<ViewSubmissions> {
  late Future<List<Map<String, dynamic>>> _submissionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  /// 🔹 Fetch submissions along with assignment descriptions
  Future<List<Map<String, dynamic>>> _fetchSubmissions() async {
    try {
      // ✅ Step 1: Get all assignments for this classroom
      var assignmentSnapshot =
          await FirebaseFirestore.instance
              .collection('assignments')
              .where('classroomId', isEqualTo: widget.classroomId)
              .get();

      Map<String, String> assignmentDescriptions = {};
      List<String> assignmentIds = [];

      for (var doc in assignmentSnapshot.docs) {
        assignmentIds.add(doc.id);
        assignmentDescriptions[doc.id] = doc['description'] ?? "No description";
      }

      if (assignmentIds.isEmpty) return [];

      // ✅ Step 2: Fetch submissions for these assignments
      var submissionSnapshot =
          await FirebaseFirestore.instance
              .collection('submissions')
              .where('assignment_id', whereIn: assignmentIds)
              .get();

      List<Map<String, dynamic>> submissions =
          submissionSnapshot.docs.map((doc) {
            var data = doc.data();
            data['description'] =
                assignmentDescriptions[data['assignment_id']] ??
                "No description";
            return data;
          }).toList();

      return submissions;
    } catch (e) {
      print("ERROR: Failed to fetch submissions → $e");
      return [];
    }
  }

  /// 🔄 Refreshes the submission list
  void _loadSubmissions() {
    setState(() {
      _submissionsFuture = _fetchSubmissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Submissions",
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _submissionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No submissions found.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }

            var submissions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                var submission = submissions[index];
                bool isGraded =
                    submission['graded'] == true; // ✅ Check graded status
                Color tileColor =
                    isGraded ? Colors.green[200]! : Colors.red[200]!;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: tileColor.withOpacity(
                    0.8,
                  ), // ✅ Transparent colored cards
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    onTap: () async {
                      // 🔄 Navigate to EvaluationPage & wait for result
                      bool? updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EvaluationPage(
                                submissionId: submission['submission_id'],
                                assignmentId: submission['assignment_id'],
                                studentId: submission['student_id'],
                                fileUrl: submission['file_url'] ?? "",
                              ),
                        ),
                      );

                      if (updated == true) {
                        _loadSubmissions(); // 🔄 Refresh UI when graded
                      }
                    },
                    title: Text(
                      "Student ID: ${submission['student_id'] ?? 'Unknown'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Assignment ID: ${submission['assignment_id']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Description: ${submission['description']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (submission['file_url'] != null &&
                              submission['file_url'].isNotEmpty)
                            Text(
                              "File: ${submission['file_url']}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            "Feedback: ${submission['feedback'] ?? 'No feedback'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isGraded ? "✅ Graded" : "⚠️ Not graded yet",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color:
                                  isGraded
                                      ? Colors.green[900]
                                      : Colors.red[900],
                            ),
                          ),
                        ],
                      ),
                    ),
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
