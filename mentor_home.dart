import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_classroom.dart';
import 'signup_page.dart';
import 'classroom_details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class MentorHome extends StatefulWidget {
  final String mentorId;

  const MentorHome({Key? key, required this.mentorId}) : super(key: key);

  @override
  _MentorHomeState createState() => _MentorHomeState();
}

class _MentorHomeState extends State<MentorHome> {
  String mentorName = "Loading...";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    fetchMentorDetails();
  }

  Future<void> fetchMentorDetails() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.mentorId)
              .get();

      if (userDoc.exists) {
        setState(() {
          mentorName = userDoc['name'] ?? "Unknown Mentor";
          profileImageUrl = userDoc['profilePic'] ?? "";
        });
      } else {
        setState(() {
          mentorName = "Unknown Mentor";
        });
      }
    } catch (e) {
      setState(() {
        mentorName = "Error Loading";
      });
    }
  }

  Future<void> uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File file = File(pickedFile.path);
    String fileName = "${widget.mentorId}.jpg";

    try {
      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('profile_pictures/$fileName')
          .putFile(file);

      String downloadUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.mentorId)
          .update({'profilePic': downloadUrl});

      setState(() {
        profileImageUrl = downloadUrl;
      });
    } catch (e) {
      print("Error uploading profile picture: $e");
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignupPage()),
      (route) => false,
    );
  }

  void _deleteClassroom(String classroomId) async {
    try {
      await FirebaseFirestore.instance
          .collection('classrooms')
          .doc(classroomId)
          .delete();
    } catch (e) {
      print("Error deleting classroom: $e");
    }
  }

  Stream<QuerySnapshot> fetchClassrooms(String mentorId) {
    return FirebaseFirestore.instance
        .collection('classrooms')
        .where('mentorId', isEqualTo: mentorId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD1B3FF),
        title: Row(
          children: [
            GestureDetector(
              onTap: uploadProfilePicture,
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                child:
                    profileImageUrl.isEmpty
                        ? Icon(Icons.person, size: 30)
                        : null,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              mentorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6CCFF), Color(0xFF8E44AD)], // Lavender gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: fetchClassrooms(widget.mentorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading classrooms"));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No classrooms found"));
            }

            var classrooms = snapshot.data!.docs;

            return ListView.builder(
              itemCount: classrooms.length,
              itemBuilder: (context, index) {
                var classroom = classrooms[index];
                return Card(
                  color: Colors.white.withOpacity(0.9),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      classroom['className'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Subject: ${classroom['subject'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteClassroom(classroom.id),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ClassroomDetails(
                                classroomId: classroom.id,
                                className: classroom['className'],
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8E44AD), // Purple theme button
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateClassroom(mentorId: widget.mentorId),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
