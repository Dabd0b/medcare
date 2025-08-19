import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medcare/Doctor_consultation/doctors.dart';
import 'package:medcare/Future_work.dart';
import 'package:medcare/Partnership/partners.dart';
import 'package:medcare/health_status.dart';
import 'package:medcare/notifications.dart';
import 'package:medcare/settings.dart';
import 'package:medcare/user_profile.dart';
import 'package:medcare/your_heart/condition.dart';
import 'package:medcare/your_heart/test.dart';

import 'your_heart/your_heart.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String userName = "Guest";
  String userImageUrl = "";
  String healthStatus = "Unknown";
  String userId = ""; // Add this variable to store the user ID

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email ?? ""; // Get the current user's email
        print("Current user email: $email");

        // Query Firestore using the email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userDoc = querySnapshot.docs[0]; // Get the first document
          print("User data fetched: ${userDoc.data()}");

          setState(() {
            // Extract the fields from the document
            userId = userDoc.id; // Store the Firestore user ID
            userName = userDoc['name'] ?? "Guest"; // Name
            userImageUrl = userDoc['imageUrl'] ?? ""; // Image URL
            healthStatus = userDoc['healthStatus'] ?? "Unknown"; // Health Status
          });
        } else {
          print("No user document found for email: $email");
          FirebaseAuth.instance.signOut();
        }
      } else {
        print("No user logged in");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      FirebaseAuth.instance.signOut();
    }
  }

  void _navigateBasedOnTestStatus(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // Ensure user is logged in

  try {
    // Fetch the user's data
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      // Handle if the user document is not found
      return;
    }

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    // Fetch the record map directly, as record is a map, not a list
    Map<String, dynamic> records = userData['record'] ?? {};

    if (records.isEmpty) {
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MedicalTestPage()),
      );
      return;
    }

    // Get the last test record (we assume that the record map stores the tests by keys like 't1', 't2', ...)
    String lastKey = records.keys.last;  // Get the last key (e.g., t1, t2)
    Map<String, dynamic> lastRecord = records[lastKey] as Map<String, dynamic>;

    // Get the status and riskScore from the last record
    String status = lastRecord['status'] ?? 'incomplete'; // Default to 'incomplete' if not found
    double riskScore = lastRecord['riskScore'] ?? 0.0; // Set default to 0 if not found
    String condition = lastRecord['condition'] ?? 'unHealthy';
    // Navigate based on the test completion status
    if (status == 'complete') {
      // If the test is complete, navigate to the MedicalTestPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HealthStatusPage()),
      );
    } else {
      // If the test is incomplete, navigate to the ConditionPage and pass the riskScore
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConditionPage(riskScore: riskScore, condition: condition,),
        ),
      );
    }
  } catch (e) {
    print("Error: $e");
    // Handle any errors, for example, by showing an error message
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          child: userImageUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(userImageUrl),
                )
              : CircleAvatar(
                  backgroundImage: AssetImage('assets/images/Ellipse 8.png'),
                ),
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        },
        child: Text(
          'Hello, $userName',
          style: TextStyle(color: Colors.black),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Color(0xFF5D56AF)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: Color(0xFF5D56AF)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationsPage()),
            );
          },
        ),
      ],
    ),
    body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg1.png"), // Your background image
          fit: BoxFit.cover, // Ensures full coverage
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Are You Feeling Today?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5D56AF)),
            ),
            SizedBox(height: 10),
           GestureDetector(
  onTap: () {
    _navigateBasedOnTestStatus(context);
  },
  child: Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: healthStatus == "unknown"
        ? Colors.green.withOpacity(0.1)
        : healthStatus == "Healthy"
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1), // Set the container color based on healthStatus
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Health Status',
        style: TextStyle(color: Color(0xFF5D56AF)),
      ),
      Text(
        healthStatus == "unknown"
            ? "Tap to Finish Test"
            : healthStatus,
        style: TextStyle(
          color: healthStatus == "Healthy"
              ? Colors.green
              : healthStatus == "unknown"
                  ? Colors.green
                  : Colors.red, // Set the text color based on healthStatus
        ),
      ),
      Icon(
        Icons.arrow_forward,
        color: healthStatus == "Healthy" || healthStatus == "unknown"
            ? Colors.green
            : Colors.red, // Set the arrow color based on healthStatus
      ),
    ],
  ),
),
),

            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildGridTile(
                    context,
                    'assets/images/image.png',
                    'Your Heart',
                    () => YourHeartPage(),
                  ),
                  _buildGridTile(
                    context,
                    'assets/images/image (2).png',
                    'Partnership',
                    () => PartnersPage(),
                  ),
                  _buildGridTile(
                    context,
                    'assets/images/image (3).png',
                    'Doctor Consultation',
                    () => AvailableDoctorsPage(userId: userId),
                  ),
                  _buildGridTile(
                    context,
                    'assets/images/image (4).png',
                    'Diseases To Be Added',
                    () => MultiPageForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildGridTile(
      BuildContext context, String imagePath, String title, Widget Function() page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 140),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
