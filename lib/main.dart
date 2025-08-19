import 'package:flutter/material.dart';
import 'package:medcare/doctor_interface/doc_homepage.dart';
import 'package:medcare/login_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading_screen.dart';
import 'homepage.dart'; // Import your HomePage
import 'package:medcare/Partnership/sub_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MedCareApp());
}

class MedCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedCare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
      routes: {
      "/hospitals": (context) => SubPage(category: "hospitals"),
      "/doctors": (context) => SubPage(category: "doctors"),
      "/clinics": (context) => SubPage(category: "clinics"),
      "/xray": (context) => SubPage(category: "xray"),
      "/pharmacies": (context) => SubPage(category: "pharmacies"),
    }, // Start with AuthWrapper
      debugShowCheckedModeBanner: false,
    );
  }
}


class AuthWrapper extends StatelessWidget {
  Future<String?> _getUserRole(String userId) async {
    try {
      // Check the `users` collection
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc.get('role'); // Return the role (e.g., "patient")
      }

      // Check the `doctors` collection
      DocumentSnapshot doctorDoc =
          await FirebaseFirestore.instance.collection('doctors').doc(userId).get();

      if (doctorDoc.exists) {
        return doctorDoc.get('role'); // Return the role (e.g., "doctor")
      }

      return null; // User not found in either collection
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen(); // Show a loading screen while checking auth state
        } else if (snapshot.hasData) {
          final User? user = snapshot.data;

          if (user != null) {
            // Fetch the user's role
            return FutureBuilder<String?>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return LoadingScreen(); // Show a loading screen while fetching role
                } else if (roleSnapshot.hasData) {
                  final String? role = roleSnapshot.data;

                  if (role == "doctor") {
                    return DoctorHomepage(); // Doctor homepage
                  } else if (role == "patient") {
                    return PatientHomePage(); // Patient homepage
                  } else {
                    // Unknown role, log out
                    FirebaseAuth.instance.signOut();
                    return LoginPage(); // Redirect to login
                  }
                } else {
                  // Role not found, log out
                  FirebaseAuth.instance.signOut();
                  return LoginPage();
                }
              },
            );
          } else {
            return LoginPage(); // If no user is logged in
          }
        } else {
          return LoginPage(); // If no user is logged in
        }
      },
    );
  }
}
