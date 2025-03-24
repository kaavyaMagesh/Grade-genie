import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_page.dart';
import 'student_classroom_details.dart';

class StudentHome extends StatefulWidget {
  final String studentId;

  const StudentHome({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  List<Map<String, dynamic>> joinedClasses = [];

  @override
  void initState() {
    super.initState();
    _fetchJoinedClasses();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
      (route) => false,
    );
  }

  Future<void> _fetchJoinedClasses() async {
    try {
      DocumentSnapshot studentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.studentId)
              .get();
      List<dynamic> classIds = studentSnapshot['classes_enrolled'] ?? [];

      if (classIds.isEmpty) {
        setState(() => joinedClasses = []);
        return;
      }

      // ✅ Fetch all classrooms in parallel (faster)
      List<DocumentSnapshot> classSnapshots = await Future.wait(
        classIds.map(
          (id) =>
              FirebaseFirestore.instance.collection('classrooms').doc(id).get(),
        ),
      );

      List<Map<String, dynamic>> classes =
          classSnapshots
              .where((snapshot) => snapshot.exists)
              .map(
                (snapshot) => {
                  'classroomId': snapshot.id,
                  'className': snapshot['className'],
                  'subject': snapshot['subject'],
                },
              )
              .toList();

      setState(() => joinedClasses = classes);
    } catch (e) {
      print("Error fetching joined classes: $e");
    }
  }

  Future<void> joinClass(BuildContext context) async {
    TextEditingController _classroomIdController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Join a Classroom",
              style: TextStyle(
                color: Color(0xFF8E44AD),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: _classroomIdController,
              decoration: const InputDecoration(
                labelText: "Enter Classroom ID",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8E44AD)),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String classroomId = _classroomIdController.text.trim();
                  if (classroomId.isNotEmpty) {
                    await enrollStudent(widget.studentId, classroomId, context);
                    _fetchJoinedClasses();
                  }
                  Navigator.pop(context);
                },
                child: const Text(
                  "Join",
                  style: TextStyle(color: Color(0xFF8E44AD)),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> enrollStudent(
    String studentId,
    String classroomId,
    BuildContext context,
  ) async {
    try {
      DocumentSnapshot classroomSnapshot =
          await FirebaseFirestore.instance
              .collection('classrooms')
              .doc(classroomId)
              .get();

      if (!classroomSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Classroom not found!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        return;
      }

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully joined the class!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error joining class: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8DAEF),
            Color(0xFFD2B4DE),
          ], // ✅ Soft purple gradient
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // ✅ Transparent to show gradient
        appBar: AppBar(
          title: const Text(
            "Student Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF8E44AD), // ✅ Purple title bar
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Welcome, Student! Your ID: ${widget.studentId}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E44AD),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Join Class Button (Styled)
              Center(
                child: ElevatedButton(
                  onPressed: () => joinClass(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E44AD),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Join a Class",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Your Classes:",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E44AD),
                ),
              ),

              Expanded(
                child:
                    joinedClasses.isEmpty
                        ? const Center(
                          child: Text(
                            "You haven't joined any classes yet.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: joinedClasses.length,
                          itemBuilder: (context, index) {
                            var classData = joinedClasses[index];
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFF8E44AD),
                                  width: 2,
                                ),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  classData['className'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8E44AD),
                                  ),
                                ),
                                subtitle: Text(
                                  "Subject: ${classData['subject']}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF8E44AD),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => StudentClassroomDetails(
                                            classroomId:
                                                classData['classroomId'],
                                            className: classData['className'],
                                            studentId: widget.studentId,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
