import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medcare/doctor_interface/doc_homepage.dart';
import 'package:medcare/homepage.dart';
import 'register_page.dart';
import 'forgotpass_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> _login() async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!userCredential.user!.emailVerified) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify your email to continue.')),
      );
      await _auth.signOut();
      return;
    }

    String userId = userCredential.user!.uid;

    // Fetch user document from Firestore
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      String role = userDoc.get('role');
      print('User role: $role');

      if (role == "doctor") {
        bool isApproved = userDoc.get('isApproved');
        print('Doctor isApproved: $isApproved');

        if (!isApproved) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Your account is pending admin approval.')),
          );
          await _auth.signOut();
          return;
        }

        // Navigate to DoctorHomepage
        if (!mounted) return;
        print("Navigating to DoctorHomepage...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorHomepage(),
          ),
        );
        return; // Stop further execution
      } else if (role == "patient") {
        // Navigate to PatientHomePage
        if (!mounted) return;
        print("Navigating to PatientHomePage...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientHomePage(),
          ),
        );
        return; // Stop further execution
      }
    }

    // If user document doesn't exist or role is unknown
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not found or invalid role.')),
    );
    await _auth.signOut();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login error: ${e.toString()}')),
    );
  }
}






@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Container(
        height: double.infinity, // Ensures the container takes the full height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"), // Your background image
            fit: BoxFit.fill, // Ensures the image covers the entire screen
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100.0),
              // Welcome message
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20.0),
              // Placeholder profile icon
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.blue.shade200,
                child: const Icon(Icons.person, size: 50.0, color: Colors.white),
              ),
              const SizedBox(height: 40.0),
              // Input fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    buildTextField("Enter email", _emailController),
                    const SizedBox(height: 16.0),
                    buildTextField("Enter password", _passwordController, obscureText: true),
                  ],
                ),
              ),
              // Forgot password link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      "Forget password?",
                      style: TextStyle(color: Colors.blue, fontSize: 14.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Login button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Sign up link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Don’t have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "sign up",
                        style: TextStyle(color: Colors.tealAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    
  );
}



  Widget buildTextField(String hintText, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.grey.shade300,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.tealAccent, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.teal, width: 2.0),
        ),
      ),
    );
  }
}
