import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medcare/homepage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool isLoading = true;
  File? _profileImageFile; // To store selected profile image
  String? _profileImageUrl; // To store the image URL after uploading

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch user data using Firebase user ID
  void fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid; // Get the current user's unique ID
        print("Current user UID: $uid");

        // Query Firestore using the user ID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          print("User data fetched: ${userDoc.data()}");

          setState(() {
            _fullNameController.text = userDoc['name'] ?? '';
            _phoneNumberController.text = userDoc['phoneNumber'] ?? '';
            _emailController.text = userDoc['email'] ?? '';
            _dobController.text = userDoc['dateOfBirth'] ?? '';
            _profileImageUrl = userDoc['imageUrl']; // Fetching profile image URL from Firestore
            isLoading = false;
          });
        } else {
          print("User does not exist in Firestore.");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Update user profile in Firestore
  void updateUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // Update user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': _fullNameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'dateOfBirth': _dobController.text.trim(),
          'imageUrl': _profileImageUrl, // Update profile image URL
        });

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      print("Error updating profile: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile!")),
      );
    }
  }

  // Function to pick profile image using ImagePicker
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });

      // Upload image to Firebase Storage
      String imageUrl = await _uploadProfileImage();
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
  }

  // Upload profile image to Firebase Storage
  Future<String> _uploadProfileImage() async {
    try {
      String fileName = path.basename(_profileImageFile!.path);
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/${FirebaseAuth.instance.currentUser!.uid}/$fileName');
      UploadTask uploadTask = storageRef.putFile(_profileImageFile!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Return the image URL after uploading
    } catch (e) {
      print("Error uploading profile image: $e");
      return '';
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor:  Color(0xFF5D56AF),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientHomePage(),
          ),
        ),
      ),
    ),
    body: Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg2.png"), // Your background image
          fit: BoxFit.fill, // Ensures the image covers the entire screen
        ),
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    // Profile Picture
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImageFile != null
                              ? FileImage(_profileImageFile!)
                              : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                                  ? NetworkImage(_profileImageUrl!)
                                  : AssetImage('assets/images/Ellipse 8.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage, // Open image picker when tapped
                            child: CircleAvatar(
                              backgroundColor: Colors.cyan,
                              radius: 20,
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Full Name Field
                    buildTextField("Full Name", _fullNameController),
                    SizedBox(height: 15),
                    // Phone Number Field
                    buildTextField("Phone Number", _phoneNumberController),
                    SizedBox(height: 15),
                    // Email Address Field
                    buildTextField("Email Address", _emailController),
                    SizedBox(height: 15),
                    // Date of Birth Field
                    buildTextField("Date of Birth", _dobController),
                    SizedBox(height: 30),
                    // Update Profile Button
                    ElevatedButton(
                      onPressed: updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
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


  // Helper Widget for Text Fields
  Widget buildTextField(String labelText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.tealAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        fillColor: Colors.grey[200],
        filled: true,
      ),
    );
  }
}
