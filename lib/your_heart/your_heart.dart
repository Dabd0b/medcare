import 'package:flutter/material.dart';
import 'package:medcare/user_history.dart';
import 'package:medcare/your_heart/condition.dart';
import 'package:medcare/your_heart/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class YourHeartPage extends StatelessWidget {

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
        MaterialPageRoute(builder: (context) => MedicalTestPage()),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Your Heart',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Color(0xFF5D56AF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            // Handle back button press, e.g., go back to the previous page
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg1.png"), // Your background image
          fit: BoxFit.cover, // Ensures full coverage
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the page for Medical Heart Tests
                _navigateBasedOnTestStatus(context);
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/image (6).png', // Replace with your actual image path
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Medical Heart Tests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                // Navigate to the page for Previous Heart Tests
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryTestRecordsPage()),
                );
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/image (7).png', // Replace with your actual image path
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Previous Heart Tests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
}

