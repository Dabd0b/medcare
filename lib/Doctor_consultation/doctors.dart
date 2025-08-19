import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medcare/homepage.dart'; 
import 'doctor_chat.dart'; // Update the import to point to the UserChatScreen

class AvailableDoctorsPage extends StatefulWidget {
  final String userId; // Pass the user ID to this page

  AvailableDoctorsPage({required this.userId});

  @override
  _AvailableDoctorsPageState createState() => _AvailableDoctorsPageState();
}

class _AvailableDoctorsPageState extends State<AvailableDoctorsPage> {
  final CollectionReference doctorsCollection =
      FirebaseFirestore.instance.collection("doctors");

  String searchQuery = "";

  /// Override the back button to always navigate to the homepage
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PatientHomePage()), // Replace with your actual homepage widget
    );
    return false; // Prevent default back button behavior
  }

  Future<String> getAuthIdByEmail(String email) async {
  try {
    // Query the `users` collection for a matching email
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userQuery.docs.isNotEmpty) {
      // Return the user's auth ID
      return userQuery.docs.first.id;
    }

    // Query the `doctors` collection for a matching email
    QuerySnapshot doctorQuery = await FirebaseFirestore.instance
        .collection('doctors')
        .where('email', isEqualTo: email)
        .get();

    if (doctorQuery.docs.isNotEmpty) {
      // Return the doctor's auth ID
      return doctorQuery.docs.first.id;
    }
  } catch (e) {
    print("Error fetching auth ID by email: $e");
  }

  return "rqKzywOBGgeOPwCVJylyp6zhyvU2"; // Return null if no match is found
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF5D56AF),
          title: Text("Available Doctors",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PatientHomePage()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Search Doctors",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase(); // Update the search query
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: doctorsCollection
                    .where("consultation", isEqualTo: true) // Filter by availability
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No available doctors found"));
                  }

                  final doctors = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data["name"] ?? "").toLowerCase();
                    final specialty = (data["specialty"] ?? "").toLowerCase();
                    return name.contains(searchQuery) ||
                        specialty.contains(searchQuery);
                  }).toList();

                  if (doctors.isEmpty) {
                    return Center(child: Text("No doctors match your search."));
                  }

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index].data() as Map<String, dynamic>;
                      final String doctorId = doctors[index].id;
                      final String docEmail = doctor["email"];

                      // Get the doctor auth ID function
                      Future<String> getAuthId(String docEmail) async {
                        return await getAuthIdByEmail(docEmail);
                      }

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        color: Color(0xFF5D56AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.tealAccent, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            leading: Container(
                              width: 80, // Adjust width for larger image
                              height: 80, // Adjust height to match the image size
                              child: ClipOval(  // Makes the image circular
                                child: Image.network(
                                  doctor["image"] ?? "",
                                  fit: BoxFit.fill,  // Ensure the image covers the container
                                ),
                              ),
                            ),
                            title: Text(
                              doctor["name"] ?? "Unknown",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 if (doctor["services"] != null && doctor["services"].isNotEmpty) 
                                 ...doctor["services"].map<Widget>((service) {
                                 return Text(
                                   service ?? "No service available",
                                   style: TextStyle(color: Colors.white),
                                    );
                               }).toList(),
                                Row(
                                  children: [
                                    Text("${doctor["rating"] ?? 0} Stars", style: TextStyle(color: Colors.white)),
                                    SizedBox(width: 8),
                                    Icon(Icons.star, color: Colors.orange, size: 16),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward, color: Colors.white),
                            onTap: () {
                              // Navigate to the chat screen with the selected doctor
                              getAuthId(docEmail).then((doctorAuthId) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserChatScreen(
                                      userId: widget.userId, // Pass the user ID
                                      doctorProfileId: doctorId,
                                      doctorAuthId: doctorAuthId, // Pass the selected doctor ID
                                    ),
                                  ),
                                );
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
