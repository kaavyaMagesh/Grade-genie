import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ForumPage extends StatefulWidget {
  final String forumId;
  final String classroomId;
  final String userId;

  const ForumPage({
    Key? key,
    required this.forumId,
    required this.classroomId,
    required this.userId,
  }) : super(key: key);

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  String userRole = "Student"; // Default role

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    fetchMessages();
  }

  Future<void> fetchUserRole() async {
    try {
      var userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get();
      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'] ?? 'Student';
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  Future<void> fetchMessages() async {
    var querySnapshot =
        await FirebaseFirestore.instance
            .collection('forums')
            .doc(widget.forumId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      messages =
          querySnapshot.docs.map((doc) {
            Timestamp? timestamp = doc['timestamp'] as Timestamp?;
            String formattedTime =
                timestamp != null
                    ? DateFormat('MMM d, h:mm a').format(timestamp.toDate())
                    : 'Unknown time';

            return {
              'uid': doc['uid'] as String,
              'role': doc['role'] as String,
              'message': doc['message'] as String,
              'time': formattedTime,
            };
          }).toList();
    });
  }

  Future<void> postMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('forums')
        .doc(widget.forumId)
        .collection('messages')
        .add({
          'uid': widget.userId,
          'role': userRole,
          'message': messageText,
          'timestamp': FieldValue.serverTimestamp(),
        });

    _messageController.clear();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forum: ${widget.classroomId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD1B3FF),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Classroom ID: ${widget.classroomId}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${messages[index]['uid']} (${messages[index]['role']})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            messages[index]['time']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              messages[index]['message']!,
                              style: const TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: const TextStyle(color: Colors.deepPurple),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: postMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
