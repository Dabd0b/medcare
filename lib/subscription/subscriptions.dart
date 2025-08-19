import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medcare/subscription/plans.dart'; // Assuming the path to your VIPPlansPage

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool? isVIP; // This will hold the user's VIP status
  bool isLoading = true; // Track loading state while fetching user data

  @override
  void initState() {
    super.initState();
    _fetchUserSubscriptionStatus();
  }

  // Fetch the user's subscription status (isVIP) from Firestore using the UID
  Future<void> _fetchUserSubscriptionStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            // Update the isVIP value from Firestore
            isVIP = userDoc['isVIP'] ?? false; // Default to false if not set
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching data
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Subscription", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Color(0xFF5D56AF),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Subscription", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF5D56AF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg1.png"), // Your background image
            fit: BoxFit.cover, // Ensure it covers the screen
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Normal Plan Card
              _buildPlanCard(
                title: "Normal",
                description: [
                  {"text": "Only ONE Question asked to Doctor", "color": Colors.black},
                  {"text": "Less Features", "color": Colors.red},
                ],
                actionText: null,
                action: null,
              ),
              SizedBox(height: 16),
              // VIP Plan Card
              _buildPlanCard(
                title: "VIP Plan",
                description: [
                  {"text": "Unlimited Questions asked to Doctor", "color": Colors.red},
                  {"text": "More Accessible Features", "color": Colors.red},
                  {"text": "Discounts", "color": Colors.black},
                ],
                actionText: "View Plans",
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VIPPlansPage()),
                  );
                },
              ),
              SizedBox(height: 16),
              // Current Plan and Cancel Subscription (if VIP)
              _buildCurrentPlanSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper function to build a subscription card
  Widget _buildPlanCard({
    required String title,
    required List<Map<String, dynamic>> description,
    String? actionText,
    VoidCallback? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: title == "Normal" ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (title == "VIP Plan")
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image(image: AssetImage('assets/images/image 33.png')),
                ),
            ],
          ),
          SizedBox(height: 16),
          // Description
          ...description.map((desc) => Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    desc['text'],
                    style: TextStyle(
                      color: desc['color'],
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
          if (actionText != null && action != null) ...[
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: action,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionText),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Helper function to display current plan and cancel button
  Widget _buildCurrentPlanSection(BuildContext context) {
    return Column(
      children: [
        // Display current plan based on isVIP
        Text(
          "Current Plan\n ${isVIP! ? 'VIP' : 'Normal'}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        // If VIP, show cancellation button
        if (isVIP!)
          ElevatedButton(
            onPressed: () => _showCancelConfirmationDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Cancel Subscription",
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  // Show a confirmation dialog when the user wants to cancel their subscription
  Future<void> _showCancelConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cancel Subscription"),
          content: Text("Are you sure you want to cancel your VIP subscription?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
        // Get the current user's UID
          User? user = FirebaseAuth.instance.currentUser;
                   if (user != null) {
                     try {
                           // Update the isVIP field to false in Firestore
                               await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({'isVIP': false}); // Set isVIP to false

                                // Close the dialog
                                Navigator.pop(context);
                                 Navigator.push(
                                              context,
                                               MaterialPageRoute(builder: (context) => SubscriptionPage()),
                                          );

                                    // Show confirmation message
                                   ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text("Your subscription has been cancelled.")),
                                              );
                              } catch (e) {
                               // Handle errors
                                 print("Error updating subscription: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to cancel subscription.")),
                                    );
                                   }
                                 }
                                },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
