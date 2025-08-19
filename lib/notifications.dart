import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor:  Color(0xFF5D56AF),
      ),
      body: Center(
        child: Text(
          "No Notifications Yet",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}