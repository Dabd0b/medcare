import 'package:flutter/material.dart';
import 'package:medcare/Doctor_consultation/doctors.dart';
import 'package:medcare/Partnership/sub_page.dart';
import 'package:medcare/homepage.dart';
import 'package:medcare/your_heart/AI_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConditionPage extends StatelessWidget {
  final double riskScore;
  final String condition;
  const ConditionPage({super.key, required this.riskScore, required this.condition});


void _showAnalysisPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Required Analysis'),
          content: Text(
            '-Resting Blood pressure\n-Serum Cholesterol\n-Fasting Blood sugar\n-Resting electrocardiographic\n-Resting & Stress ECG\n-Fluoroscopy Angiogram or CTA\n-Thalium Stress Test',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = riskScore >= 50
        ? 'assets/images/Rectangle 16 (1).png' // Replace with the path to your "Unhealthy" image
        : 'assets/images/Rectangle 16.png';  // Replace with the path to your "Healthy" image

    return Scaffold(
      body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg2.png"), // Your background image
          fit: BoxFit.fill, // Ensures full coverage
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'Your Probably Suffer \n "$condition"',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: riskScore >= 50 ? Colors.red : Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // Padding around the text
      child: Column(
        children: [
          Text(
            riskScore >= 50
                ? 'We suspect that you might have a heart condition. We advise you to contact or visit one of our trusted labs and imaging centers. Request the analysis below and then take the "MEDCARE-AI-Test" to determine your final condition.'
                : 'Congratulations! You\'re healthy based on the results. If you\'re still unsure, feel free to consult one of our doctors to confirm your health status and ensure there are no underlying heart conditions.',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            softWrap: true, // Automatically wrap lines if needed
            maxLines: null, // Allow multiple lines if needed
          ),
          if (riskScore >= 50) ...[
            SizedBox(height: 20),
            TextButton(
              onPressed: () => _showAnalysisPopup(context),
              child: Text(
                'required Analysis',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ],
      ),
),
            const SizedBox(height: 100),
            
           Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (riskScore >= 50) ...[
      // Labs Button
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubPage(category: 'xray',)), // Replace with your actual Labs page
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, color: Color(0xFF5D56AF)), // Purple icon
            SizedBox(height: 8),
            Text(
              'Labs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
      SizedBox(width: 16),
      // Homepage Button
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PatientHomePage()), // Replace with your actual Homepage
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, color: Color(0xFF5D56AF)), // Purple icon
            SizedBox(height: 8),
            Text(
              'Home',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
      SizedBox(width: 16),
      // MEDCARE-Test Button
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PredictionForm()), // Replace with your actual MEDCARE-Test page
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, color: Color(0xFF5D56AF)), // Purple icon
            SizedBox(height: 8),
            Text(
              'Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    ] else ...[
      // Doctor Consultation Button
      ElevatedButton(
        onPressed: () {
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            String userId = currentUser.uid; // Get the current user's UID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvailableDoctorsPage(userId: userId), // Pass the userId here
              ),
            );
          } else {
            // Handle the case where the user is not logged in
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User not logged in")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_rounded, color: Color(0xFF5D56AF)), // Purple icon
            SizedBox(height: 8),
            Text(
              'Consult',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
      SizedBox(width: 16),
      // Homepage Button
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PatientHomePage()), // Replace with your actual Homepage
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, color: Color(0xFF5D56AF)), // Purple icon
            SizedBox(height: 8),
            Text(
              ' Home ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    ],
  ],
),


          ],
        ),
      ),
      ),
    );
  }
}
