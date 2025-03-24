import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'mentor_home.dart';
import 'student_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firestore settings (keep caching enabled)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // ✅ Caching enabled for better performance
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Genie',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false, // ✅ Removes the debug banner
      home: AuthCheck(),
      routes: {
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // Ensure Firestore query runs safely on the platform thread
          return FutureBuilder<String>(
            future: Future.microtask(
              () => getUserRole(snapshot.data!.uid),
            ), // ✅ Safe thread handling
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text("Error loading user role.")),
                );
              }

              if (roleSnapshot.hasData) {
                return roleSnapshot.data == "mentor"
                    ? MentorHome(mentorId: snapshot.data!.uid)
                    : StudentHome(studentId: snapshot.data!.uid);
              } else {
                return SignupPage(); // Default to signup if no role found
              }
            },
          );
        } else {
          return SignupPage(); // ✅ Show signup page if not logged in
        }
      },
    );
  }
}

Future<String> getUserRole(String uid) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['role'] ?? "student"; // Default to student if role missing
    } else {
      return "student";
    }
  } catch (e) {
    print("🔥 Error fetching user role: $e");
    return "student"; // Prevent crash
  }
}
