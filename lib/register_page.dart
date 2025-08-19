import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medcare/login_page.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _userRole = 'patient';
  File? _profileImageFile;
  File? _doctorIDFile;

  Future<void> _register() async {
    if (_userRole == 'doctor' && _doctorIDFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload your Doctor ID')),
      );
      return;
    }

    try {
      // Register user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await userCredential.user!.sendEmailVerification();
   

      // Create user in Firestore
      Map<String, dynamic> userData = {
        'email': _emailController.text,
        'name': _nameController.text,
        'role': _userRole,
        'isApproved': _userRole == 'doctor' ? false : true,
        'imageUrl': '',
      };

      if (_userRole == 'patient') {
        // Additional attributes for patients
        userData['healthStatus'] = "unknown"; // Set health status to unknown
        userData['isVIP'] = false; // Set isVIP to false
        userData['record'] = {}; // Empty record map for patients
        userData['phoneNumber']= ''; 
        userData['dateOfBirth']= '';
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
      
      if (_userRole == 'doctor' && _doctorIDFile != null) {
        await _uploadDoctorID(userCredential.user!.uid);
      }


      if (_profileImageFile != null) {
        // Upload profile image if present
         await _uploadProfileImage(userCredential.user!.uid);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration successful! Please verify your email.'),
      ));

      // Navigate to login after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _uploadProfileImage(String userId) async {
    try {
      String fileName = path.basename(_profileImageFile!.path);
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId/$fileName');
      UploadTask uploadTask = storageRef.putFile(_profileImageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('users').doc(userId).update({
        'imageUrl': downloadUrl,
      }); // Return the image URL after uploading
    } catch (e) {
      print("Error uploading profile image: $e");
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDoctorID() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _doctorIDFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadDoctorID(String userId) async {
    try {
      String fileName = path.basename(_doctorIDFile!.path);
      Reference storageRef = _storage.ref().child('doctor_ids/$userId/$fileName');
      UploadTask uploadTask = storageRef.putFile(_doctorIDFile!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore.collection('users').doc(userId).update({
        'DoctorID': downloadUrl,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading Doctor ID')),
      );
      print(e.toString());
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg2.png"), // Your background image path
          fit: BoxFit.fill, // Ensures the image covers the entire screen
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Text(
                'Create an Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 20),
              // Profile Image Avatar
              GestureDetector(
                onTap: _pickProfileImage, // Open image picker when tapped
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.blue.shade200,
                  backgroundImage: _profileImageFile != null
                      ? FileImage(_profileImageFile!)
                      : AssetImage('assets/images/Ellipse 8.png') as ImageProvider,
                ),
              ),
              SizedBox(height: 20),
              buildTextField('Name', _nameController),
              SizedBox(height: 10),
              buildTextField('Email', _emailController),
              SizedBox(height: 10),
              buildTextField('Password', _passwordController, obscureText: true),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.tealAccent, width: 2),
                ),
                child: DropdownButton<String>(
                  value: _userRole,
                  isExpanded: true,
                  underline: Container(), // Removes the default underline
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  dropdownColor: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                  onChanged: (String? newValue) {
                    setState(() {
                      _userRole = newValue!;
                    });
                  },
                  items: ['patient', 'doctor'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value[0].toUpperCase() + value.substring(1), // Capitalizes first letter
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_userRole == 'doctor')
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _pickDoctorID,
                      child: Text('Upload Doctor ID', style: TextStyle(color: Colors.black),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent),
                    ),
                    _doctorIDFile != null
                        ? Text('Doctor ID selected', style: TextStyle(color: Colors.green))
                        : Text('No file selected', style: TextStyle(color: Colors.red)),
                  ],
                ),
              SizedBox(height: 20),
                  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: const Center(
                    child: Text(
                      "Register",
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
              // login link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "sign in",
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
