import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medcare/settings.dart';
import 'doctor_profile.dart';
import 'doc_chat.dart';

class DoctorHomepage extends StatefulWidget {
  @override
  _DoctorHomepageState createState() => _DoctorHomepageState();
}

class _DoctorHomepageState extends State<DoctorHomepage> {
  String? doctorProfileId;
  String? doctorIdForMessages;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorIds();
  }

  Future<void> _fetchDoctorIds() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      String uid = currentUser.uid;
      String email = currentUser.email!;
      doctorIdForMessages = uid;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          doctorProfileId = querySnapshot.docs.first.id;
          isLoading = false;
        });
      } else {
        await _createDoctorProfile(uid, email);
      }
    } catch (e) {
      print("Error fetching doctor IDs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _createDoctorProfile(String uid, String email) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('doctors').doc(uid);
      await docRef.set({
        'name': '',
        'description': '',
        'contact': '',
        'email': email,
        'location': '',
        'rating': '',
        'consultation': false,
        'image': '',
        'services': [],
        'timings': {},
      }, SetOptions(merge: true));

      setState(() {
        doctorProfileId = uid;
        isLoading = false;
      });
    } catch (e) {
      print("Error creating doctor profile: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _getUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
    return null;
  }

  Future<String?> _fetchLastMessage(String conversationId) async {
    try {
      QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messagesSnapshot.docs.isNotEmpty) {
        return messagesSnapshot.docs.first['text'] as String?;
      }
    } catch (e) {
      print("Error fetching last message: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || doctorIdForMessages == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (doctorProfileId == null) {
      // Show a message and a button to create a doctor profile
      return Scaffold(
        appBar: AppBar(
          title: Text("Homepage"),
          automaticallyImplyLeading: false,
        ),
        body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg1.png"), // Your background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ), // Ensure it covers the screen
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create your doctor profile to get started",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorProfilePage(
                        doctorId: doctorProfileId!,
                      ),
                    ),
                  );
                },
                child: Text("Create Profile"),
              ),
            ],
          ),
        ),
        ),
      );
    }

    // Normal functionality: Fetch conversations and display chats
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF5D56AF),
        title: Text("Homepage", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white,),
            onPressed: () {
              // Navigate to doctor profile using doctorProfileId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorProfilePage(
                    doctorId: doctorProfileId!,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg1.png"), // Your background image
            fit: BoxFit.cover, // Ensure it covers the screen
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('doctorId', isEqualTo: doctorIdForMessages)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No conversations available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final conversation = snapshot.data!.docs[index];
              final conversationId = conversation.id;
              final userId = conversation['userId'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserDetails(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text("Loading..."),
                      subtitle: Text("Fetching user details"),
                    );
                  }
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text("Unknown User"),
                      subtitle: Text("User details not found"),
                    );
                  }

                  final userData = userSnapshot.data!;
                  final userName = userData['name'] ?? 'Unknown User'; // Placeholder image

                  return FutureBuilder<String?>(
                    future: _fetchLastMessage(conversationId),
                    builder: (context, lastMessageSnapshot) {
                      if (lastMessageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(
                          title: Text(userName),
                          subtitle: Text("Loading last message..."),
                        );
                      }

                      final lastMessage = lastMessageSnapshot.data ?? 'No messages yet';

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
  backgroundImage: userData['imageUrl'] != null && userData['imageUrl'].isNotEmpty
      ? NetworkImage(userData['imageUrl'])
      : AssetImage('assets/images/Ellipse 8.png') as ImageProvider,
  radius: 30, // Optional: Adjust the size of the CircleAvatar
),

                          title: Text(userName),
                          subtitle: Text(lastMessage),
                          trailing: Icon(Icons.chat),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorChatPage(
                                  doctorId: doctorIdForMessages!,
                                  conversationId: conversationId,
                                  userId: conversation["userId"],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      ),
    );
  }
} 