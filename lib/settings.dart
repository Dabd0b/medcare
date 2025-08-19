import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medcare/login_page.dart';
import 'package:medcare/subscription/subscriptions.dart';
import 'package:medcare/user_history.dart';



class SettingsPage extends StatelessWidget {
  // Helper to show popups
  void _showPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Delete User Account Logic
  Future<void> _deleteUserAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get current user
      if (user == null) return;

      // Confirm Deletion Popup
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete Account"),
            content: Text("Are you sure you want to delete your account? This action cannot be undone."),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text("Delete", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .delete();

        // Delete user from Firebase Authentication
        await user.delete();

        // Sign out the user
        await FirebaseAuth.instance.signOut();

        // Show success message
        _showPopup(context, "Account Deleted", "Your account has been successfully deleted.");

        // Redirect to Login Page (or any other page)
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      }
    } catch (e) {
      print("Error deleting account: $e");
      _showPopup(context, "Error", "An error occurred while deleting your account. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        backgroundColor: Color(0xFF5D56AF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListTile(
            context,
            "Notification Setting",
            () => _showPopup(context, "Notification Settings", "Here you can configure notifications."),
          ),
          _buildListTile(
            context,
            "Privacy Policy",
            () => _showPopup(context, "Privacy Policy", "Here is your Privacy Policy."),
          ),
          _buildListTile(
            context,
            "Subscriptions",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionPage()),
              ); 
            },
          ),
          _buildListTile(
            context,
            "Delete Account",
            () => _deleteUserAccount(context),
          ),
          _buildListTile(
            context,
            "Help",
            () => _showPopup(context, "Help", "Here you can find help or support."),
          ),
          _buildListTile(
            context,
            "History Test Records",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryTestRecordsPage()),
             );
            },
          ),
          Spacer(),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                _showPopup(context, "Logged Out", "You have been logged out successfully.");
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
              },
              child: Text(
                "LogOut",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
      onTap: onTap,
    );
  }
}