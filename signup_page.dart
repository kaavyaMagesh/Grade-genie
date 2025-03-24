import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'mentor_home.dart';
import 'student_home.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String selectedRole = "student"; // Default role
  bool isLoading = false;
  String? errorMessage;

  Future<void> signupUser() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    if (!isValidEmail(emailController.text)) {
      setState(() {
        errorMessage = "Invalid email format.";
        isLoading = false;
      });
      return;
    }
    if (passwordController.text.length < 6) {
      setState(() {
        errorMessage = "Password must be at least 6 characters.";
        isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      String uid = userCredential.user!.uid;

      await Future.microtask(
        () => FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': emailController.text.trim(),
          'name': nameController.text.trim(),
          'role': selectedRole,
          'classes_created': [],
          'classes_enrolled': [],
        }),
      );

      if (selectedRole == 'mentor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MentorHome(mentorId: uid)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StudentHome(studentId: uid)),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = getErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        errorMessage = "An unexpected error occurred.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    ).hasMatch(email);
  }

  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "Password is too weak. Use a stronger password.";
      case 'invalid-email':
        return "Invalid email format.";
      default:
        return "Signup failed. Please try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF8E44AD),
        elevation: 4,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8DAEF), Color(0xFFD2B4DE)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Welcome to Grade Genie!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E44AD),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ), // Added spacing after the welcome text

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: const TextStyle(color: Color(0xFF8E44AD)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8E44AD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Color(0xFF8E44AD)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8E44AD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Color(0xFF8E44AD)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8E44AD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items:
                    ["mentor", "student"]
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF8E44AD),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedRole = value!),
                decoration: InputDecoration(
                  labelText: "Role",
                  labelStyle: const TextStyle(color: Color(0xFF8E44AD)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8E44AD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E44AD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: Color(0xFF8E44AD),
                    fontWeight: FontWeight.bold,
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
