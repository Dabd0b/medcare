import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medcare/your_heart/test.dart';

class HealthStatusPage extends StatefulWidget {
  @override
  _HealthStatusPageState createState() => _HealthStatusPageState();
}

class _HealthStatusPageState extends State<HealthStatusPage> {
  String riskLevel = "Loading...";
  int riskScore = 0;
  DateTime lastTestDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchHealthStatus();
  }
  

  Future<void> fetchHealthStatus() async {
  try {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid; // Use the UID to get the user's document

      // Get the user's document by UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?;
        
        if (data != null && data['record'] != null) {
          Map<String, dynamic> recordData = data['record'];

          // Get the last test from the record map
          String lastTestKey = 't${recordData.length}';
          var lastTest = recordData[lastTestKey];

          // Get the risk score from the last test
          double riskScore = lastTest['riskScore'] ?? 0;

          // Assign condition based on the risk score
          String condition = lastTest['condition'];

          // Update the state with riskLevel and riskScore
          setState(() {
            riskLevel = condition; // Unhealthy/Healthy
            this.riskScore = riskScore.toInt(); // Risk Score
            var timpestamp = lastTest['date'];
            lastTestDate = DateTime.parse(timpestamp); // Assuming lastTestDate is stored as String
          });
        } else {
          setState(() {
            riskLevel = "No Data Available";
            riskScore = 0;
            lastTestDate = DateTime.now();
          });
        }
      }
    }
  } catch (e) {
    print("Error fetching health status: $e");
    setState(() {
      riskLevel = "Error fetching data";
      riskScore = 0;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF5D56AF),
        elevation: 0,
        title: Text(
          'Health Status',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              // Heart Icon
             Container(
  decoration: BoxDecoration(
    color: Color(0xFF5D56AF).withOpacity(0.1), // Set the background color with opacity
    borderRadius: BorderRadius.circular(90), // Circular shape
    border: Border.all(color: Color(0xFF5D56AF), width: 3), // Circular colored border
  ),
  padding: EdgeInsets.all(20),
  child: Image.asset(
      'assets/images/Rectangle 13.png', // Replace with the correct image path
      width: 90,
      height: 90,
      fit: BoxFit.fill, // Ensures the image covers the entire space within the circle
    ),
  
),

              SizedBox(height: 20),
              Text(
                'Condition',
                style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Risk Level and Risk Score
              Text(
                '$riskLevel',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: riskScore >= 50 ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              //SizedBox(height: 10),
              if(riskScore>=50)
              Text(
                'Risk Score \n $riskScore%',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              // Test Again Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => MedicalTestPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  padding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'TEST AGAIN',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Last Test Date
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF5D56AF),width: 2.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xFF5D56AF).withOpacity(0.1)
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Last Test Date',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${lastTestDate.day}/${lastTestDate.month}/${lastTestDate.year} - ${lastTestDate.hour}:${lastTestDate.minute}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
