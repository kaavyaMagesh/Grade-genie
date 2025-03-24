import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentNotesPage extends StatelessWidget {
  final String classroomId;

  const StudentNotesPage({Key? key, required this.classroomId})
    : super(key: key);

  Stream<QuerySnapshot> fetchMentorNotes() {
    return FirebaseFirestore.instance
        .collection('notes')
        .where('classroomId', isEqualTo: classroomId)
        .orderBy('timestamp', descending: true) // ✅ Latest notes first
        .snapshots();
  }

  Future<String> getMentorName(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData['role'] == 'mentor') {
          return userData['name'] ?? "Unknown Mentor";
        }
      }
      return "Invalid Mentor";
    } catch (e) {
      return "Unknown Mentor";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ White text for contrast
          ),
        ),
        backgroundColor: const Color(0xFF8E44AD), // ✅ Deep Purple AppBar
        centerTitle: true,
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
          stream: fetchMentorNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No notes available",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E44AD), // ✅ Purple text
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(12.0),
              children:
                  snapshot.data!.docs.map((doc) {
                    var note = doc.data() as Map<String, dynamic>;
                    String uploadedBy = note['uploaded_by'] ?? "Unknown";
                    String title = note['title'] ?? "Untitled Note";
                    String noteLink = note['content'] ?? "";

                    return FutureBuilder<String>(
                      future: getMentorName(uploadedBy),
                      builder: (context, mentorSnapshot) {
                        String mentorName =
                            mentorSnapshot.connectionState ==
                                    ConnectionState.done
                                ? mentorSnapshot.data ?? "Unknown Mentor"
                                : "Loading...";

                        // ✅ Only display if uploaded by a mentor
                        if (mentorName == "Invalid Mentor")
                          return const SizedBox();

                        return Card(
                          color:
                              Colors.white, // ✅ White background for clean look
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFF8E44AD), // ✅ Purple border
                              width: 2,
                            ),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8E44AD), // ✅ Purple text
                              ),
                            ),
                            subtitle: Text(
                              "Posted by: $mentorName",
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54, // ✅ Subtle contrast
                              ),
                            ),
                            trailing: const Icon(
                              Icons.open_in_new,
                              color: Color(0xFF8E44AD), // ✅ Purple icon
                            ),
                            onTap: () async {
                              if (await canLaunchUrl(Uri.parse(noteLink))) {
                                await launchUrl(
                                  Uri.parse(noteLink),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Could not open note link"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  }).toList(),
            );
          },
        ),
      ),
    );
  }
}
