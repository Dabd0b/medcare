import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medcare/Doctor_consultation/doctors.dart';


class PaymentSuccessPage extends StatelessWidget {

  PaymentSuccessPage();

  Future<bool> _checkVIPStatus() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return false;
      }
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return userDoc['isVIP'] ?? false;
    } catch (e) {
      print("Error checking VIP status: $e");
      return false;
    }
  }

  void _navigateToChat(BuildContext context) async {
    bool isVIP = await _checkVIPStatus();
    if (isVIP) {
       Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AvailableDoctorsPage(userId: FirebaseAuth.instance.currentUser!.uid)),
                  );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: VIP status not activated. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom Image from Assets
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/image 36 (1).png'), // Replace with your image path
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Payment Successful",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _navigateToChat(context),
                child: Text(
                  "Continue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
