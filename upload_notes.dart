import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadNotesPage extends StatefulWidget {
  final String classroomId;

  const UploadNotesPage({Key? key, required this.classroomId})
    : super(key: key);

  @override
  _UploadNotesPageState createState() => _UploadNotesPageState();
}

class _UploadNotesPageState extends State<UploadNotesPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  List<String> noteLinks = [];
  bool _isUploading = false;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  void _addNoteLink() {
    if (_linkController.text.isNotEmpty) {
      setState(() {
        noteLinks.add(_linkController.text);
        _linkController.clear();
      });
    }
  }

  Future<void> _uploadNote() async {
    if (_titleController.text.isEmpty || noteLinks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter title and at least one link!"),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String noteId = FirebaseFirestore.instance.collection('notes').doc().id;

      await FirebaseFirestore.instance.collection('notes').doc(noteId).set({
        'note_id': noteId,
        'classroomId': widget.classroomId,
        'uploaded_by': currentUserId,
        'title': _titleController.text,
        'content': noteLinks,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _linkController.clear();
      setState(() => noteLinks.clear());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to upload note: $e")));
    }

    setState(() => _isUploading = false);
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete note: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Notes"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD7BDE2), Color(0xFF8E44AD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Note Title",
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: "Add Note Link",
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addNoteLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Add Link",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (noteLinks.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Added Links:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    for (String link in noteLinks)
                      ListTile(
                        title: Text(
                          link,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() => noteLinks.remove(link));
                          },
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 10),
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _uploadNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Upload Note",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              const SizedBox(height: 20),
              const Text(
                "Previously Created Notes:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection('notes')
                          .where('classroomId', isEqualTo: widget.classroomId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    var notes = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        var note = notes[index];
                        return ListTile(
                          title: Text(
                            note['title'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(note.id),
                          ),
                        );
                      },
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
