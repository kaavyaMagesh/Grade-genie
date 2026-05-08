# Grade-genie
GradeGenie
GradeGenie is a smart classroom and assignment management platform built using Flutter and Firebase. It helps mentors manage classrooms, assignments, submissions, evaluations, and student performance in one place while giving students a streamlined academic workspace.

Features
Mentor Features


Create and manage classrooms


Upload notes and study materials


Create assignments


View student submissions


Evaluate submissions and assign grades


Track classroom performance


Student Features


Join classrooms


View assignments and deadlines


Submit assignment work


Access uploaded notes/resources


Check grades and feedback


Participate in discussion forums



Tech Stack


Frontend: Flutter (Dart)


Backend: Firebase


Firebase Authentication


Cloud Firestore


Firebase Storage





Authentication
GradeGenie uses Firebase Authentication for secure login and signup functionality for both mentors and students.

Core Modules
Classroom Management
Mentors can create classrooms and manage enrolled students efficiently.
Assignment Workflow
Assignments can be created, assigned, submitted, and evaluated within the platform.
Evaluation System
Mentors can review student submissions and assign grades directly through the app.
Resource Sharing
Mentors can upload notes and study resources for students to access anytime.
Forum
A discussion space for classroom communication and collaboration.

Installation & Setup
Clone the Repository
git clone https://github.com/kaavyaMagesh/Grade-genie.gitcd Grade-genie
Install Dependencies
flutter pub get
Configure Firebase


Create a Firebase project


Enable:


Authentication


Cloud Firestore


Firebase Storage




Add your google-services.json / GoogleService-Info.plist


Update Firebase configuration if needed



Run the App
flutter run
