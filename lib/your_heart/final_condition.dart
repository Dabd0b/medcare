import 'package:flutter/material.dart';
import 'package:medcare/Doctor_consultation/doctors.dart';
import 'package:medcare/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinalConditionPage extends StatefulWidget {
  @override
  _FinalConditionPageState createState() => _FinalConditionPageState();
}

class _FinalConditionPageState extends State<FinalConditionPage> {
   String condition="";
   double riskScore=0;
   String conditionMessage="";
   String userId="";
  // Fetch data from Firestore and set it in state
  Future<void> _fetchConditionAndRiskScore() async {
  try {
    // Fetch current user using Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      userId = user.uid; // Get the current user's UID
      
      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        var record = userDoc['record'];
        
        // Get the last test key (use dynamic access here)
        String lastTestKey = 't${record.length}';

        // Fetch condition and riskScore from the last test record
        condition = record[lastTestKey]['condition'];
        riskScore = record[lastTestKey]['riskScore'];

        // Set the condition message based on the risk score
        conditionMessage = "We recommend consulting with one of our experienced doctors to thoroughly assess your condition and ensure the best care moving forward.";

        setState(() {
          // Trigger a rebuild after setting the data
        });
      }
    } else {
      print("No user is logged in");
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
}


  @override
  void initState() {
    super.initState();
    _fetchConditionAndRiskScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"), // Background image
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the condition and risk score
              condition.isNotEmpty
                  ? Column(
                      children: [
                        Image.asset(
                          riskScore >= 50
                              ? 'assets/images/Rectangle 16 (1).png' // Unhealthy image
                              : 'assets/images/Rectangle 16.png', // Healthy image
                          height: 150,
                          width: 150,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Your Condition \n "$condition"',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: riskScore >= 50 ? Colors.red : Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Risk Score \n ${riskScore.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // Padding around the text
                        child:
                        Text(
                          conditionMessage,
                          style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          softWrap: true, // Automatically wrap lines if needed
                          maxLines: null, // Allow multiple lines if needed
                        ),
                      ),
                    ],
                  )
                  : CircularProgressIndicator(),

              SizedBox(height: 40),
              // Button to go to Available Doctors Page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AvailableDoctorsPage(userId: userId,)), // Replace with your doctors page
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Available Doctors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 20),
              // Button to go to Homepage
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PatientHomePage()), // Replace with homepage
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Go to Homepage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
