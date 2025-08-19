import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medcare/Doctor_consultation/call_screen.dart';


class DoctorChatPage extends StatefulWidget {
  final String doctorId; // UID from FirebaseAuth
  final String conversationId;
  final String userId;

  DoctorChatPage({required this.doctorId, required this.conversationId, required this.userId});

  @override
  _DoctorChatPageState createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String? patientName;
  String? patientImage;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    try {
      DocumentSnapshot conversationDoc = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .get();

      if (conversationDoc.exists) {
        final patientId = conversationDoc['userId'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(patientId)
            .get();

        if (userDoc.exists) {
          setState(() {
            patientName = userDoc['name'] ?? 'Unknown Patient';
            patientImage = userDoc['imageUrl'] ?? '';
          });
        }
      }
    } catch (e) {
      print("Error fetching patient details: $e");
    }
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      final messagesRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .collection('messages');

      await messagesRef.add({
        'text': message,
        'sender': widget.doctorId, // UID from FirebaseAuth
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(widget.conversationId)
          .update({
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void _startVoiceCall() async {
    try {
      DocumentReference callRef = await FirebaseFirestore.instance
          .collection('calls')
          .add({
        'doctorId': widget.doctorId,
        'userId': widget.userId,
        'callType': 'voice',
        'startTime': FieldValue.serverTimestamp(),
        'status': 'ongoing',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
  callerId: widget.doctorId, // Pass the doctor's auth ID
  receiverId: widget.userId,     // Pass the patient's user ID
  isVideoCall: false, // Determine call type
  callRef: callRef,
),

        ),
      );
    } catch (e) {
      print("Error starting voice call: $e");
    }
  }

  void _startVideoCall() async {
    try {
      DocumentReference callRef = await FirebaseFirestore.instance
          .collection('calls')
          .add({
        'doctorId': widget.doctorId,
        'userId': widget.userId,
        'callType': 'video',
        'startTime': FieldValue.serverTimestamp(),
        'status': 'ongoing',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
  callerId:widget.doctorId , // Pass the doctor's auth ID
  receiverId: widget.userId,     // Pass the patient's user ID
  isVideoCall: true,
   // Determine call type
   callRef: callRef,
),

        ),
      );
    } catch (e) {
      print("Error starting video call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            patientImage != null && patientImage!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(patientImage!),
                  )
                : CircleAvatar(
                    child: Icon(Icons.person),
                  ),
            SizedBox(width: 10),
            Text(patientName ?? 'Chat'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: _startVoiceCall,
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: _startVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isSentByDoctor =
                        message['sender'] == widget.doctorId;

                    return Align(
                      alignment: isSentByDoctor
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByDoctor
                              ? Colors.blue[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
