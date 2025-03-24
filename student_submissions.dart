import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'grades.dart'; // ✅ Import the new GradePage

class StudentSubmissions extends StatefulWidget {
  final String studentId;
  final String classroomId;

  const StudentSubmissions({
    Key? key,
    required this.studentId,
    required this.classroomId,
  }) : super(key: key);

  @override
  _StudentSubmissionsState createState() => _StudentSubmissionsState();
}

class _StudentSubmissionsState extends State<StudentSubmissions> {
  late Future<List<Map<String, dynamic>>> _submissionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSubmissions(); // ✅ Load data on startup
  }

  /// 🔹 Fetch submissions along with assignment descriptions
  Future<List<Map<String, dynamic>>> _fetchSubmissions() async {
    try {
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

      var submissionSnapshot =
          await FirebaseFirestore.instance
              .collection('submissions')
              .where('student_id', isEqualTo: widget.studentId)
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

  /// 🔄 **Reload Data**
  void _loadSubmissions() {
    setState(() {
      _submissionsFuture = _fetchSubmissions();
    });
  }

  /// 🔄 **Ensure Data Updates When Returning to This Page**
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSubmissions(); // ✅ Reloads data when returning to this page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Submissions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple, // ✅ Consistent with Grade Genie
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _submissionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No submissions yet.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E44AD), // ✅ Purple text
                  ),
                ),
              );
            }

            var submissions = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                _loadSubmissions(); // ✅ Pull-to-refresh support
              },
              child: ListView.builder(
                itemCount: submissions.length,
                padding: const EdgeInsets.all(12.0),
                itemBuilder: (context, index) {
                  var submission = submissions[index];
                  bool isGraded = submission['graded'] == true;

                  return Card(
                    color: Colors.white, // ✅ White background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            isGraded
                                ? Colors.green
                                : Colors.red, // ✅ Border indicates status
                        width: 2,
                      ),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        "Assignment: ${submission['description']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E44AD), // ✅ Purple text
                        ),
                      ),
                      subtitle: Text(
                        isGraded
                            ? "Tap to view feedback & grade"
                            : "Not graded yet",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isGraded ? Colors.green : Colors.red,
                        ),
                      ),
                      onTap: () {
                        if (isGraded) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GradePage(
                                    assignmentDescription:
                                        submission['description'],
                                    feedback:
                                        submission['feedback'] ?? 'No feedback',
                                    grade:
                                        submission['grade']?.toString() ??
                                        'Not graded',
                                  ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
