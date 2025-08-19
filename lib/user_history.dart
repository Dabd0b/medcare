import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medcare/homepage.dart';

class HistoryTestRecordsPage extends StatefulWidget {
  @override
  _HistoryTestRecordsPageState createState() => _HistoryTestRecordsPageState();
}

class _HistoryTestRecordsPageState extends State<HistoryTestRecordsPage> {
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTestRecords();
  }

Future<void> fetchTestRecords() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid; // Get the user's UID from Firebase Auth

      // Query Firestore to get the user's document by UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // Use UID to fetch the user document
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?; // Safely cast to a map

        if (data != null && data['record'] != null) {
          Map<String, dynamic> recordData = data['record'] as Map<String, dynamic>;

          // Filter the tests with 'status' set to 'complete'
          List<Map<String, dynamic>> filteredRecords = recordData.entries
              .where((entry) {
                // Filter only tests where status is 'complete'
                return entry.value['status'] == 'complete';
              })
              .map((entry) {
                var timestamp = entry.value['date'];

                // Check if the timestamp is a String or Timestamp, and handle accordingly
                DateTime date;
                if (timestamp is String) {
                  date = DateTime.parse(timestamp); // Parse string to DateTime
                } else if (timestamp is Timestamp) {
                  date = (timestamp as Timestamp).toDate(); // Convert Firestore Timestamp to DateTime
                } else {
                  date = DateTime.now(); // Fallback if neither
                }

                var score = entry.value['riskScore'];
                var condition = entry.value['condition'];

                return {
                  "date": date, // Store the DateTime object
                  "score": score,
                  "condition": condition,
                };
              }).toList();

          setState(() {
            records = filteredRecords; // Set the filtered records to the state
            isLoading = false; // Set isLoading to false after data is fetched
          });
        } else {
          setState(() {
            isLoading = false;
            records = []; // If no records, set records to an empty list
          });
        }
      } else {
        print("User document not found.");
        setState(() {
          isLoading = false;
          records = []; // In case of error, also set records to an empty list
        });
      }
    }
  } catch (e) {
    print("Error fetching test records: $e");
    setState(() {
      isLoading = false;
      records = []; // If an error occurs, reset the records
    });
  }
}



Future<void> deleteTestRecord() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid; // Use UID to get the user's document

      // Query Firestore to get the user's document by UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid) // Directly use the UID here
          .get();

      if (userDoc.exists) {
        // Clear the entire 'record' map without deleting the map itself
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({
          'record': {}, // Update the 'record' map to be an empty map
        });

        if (userDoc.exists) {
        // Clear the entire 'record' map without deleting the map itself
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({
          'healthStatus': "unknown", // Update the 'record' map to be an empty map
        });
        }

        setState(() {
          // Clear the records list locally
          records = [];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("All test records deleted successfully!")),
        );
      } else {
        print("User document not found.");
      }
    }
  } catch (e) {
    print("Error deleting test records: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error deleting test records!")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF5D56AF),
        title: Text('History Test Records', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white),
          onPressed: () => Navigator.push(
              context,
               MaterialPageRoute(builder: (context) => PatientHomePage()),
             ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final date = record['date'] as DateTime;
                        final score = record['score'];
                        final condition = record['condition']; 

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF5D56AF).withOpacity(0.1),
                              border: Border.all(color: Color(0xFF5D56AF),width:2.5 ),
                              borderRadius: BorderRadius.circular(12),

                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Condition: $condition",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                               
                                SizedBox(height: 8),
                                if(score>=50)
                                Text(
                                  "Risk Score: $score%",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                 SizedBox(height: 8),
                                 Text(
                                  "Date: ${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: deleteTestRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Delete History",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
