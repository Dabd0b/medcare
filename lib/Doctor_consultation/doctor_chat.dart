import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medcare/Doctor_consultation/call_screen.dart';
import 'package:medcare/subscription/subscriptions.dart';
import 'package:intl/intl.dart';

class UserChatScreen extends StatefulWidget {
  final String userId;
  final String doctorProfileId;
  final String doctorAuthId;

  UserChatScreen({
    required this.userId,
    required this.doctorProfileId,
    required this.doctorAuthId,
  });

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isVIP = false;
  Map<String, dynamic>? doctorData;
  String? conversationId;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
    _checkVIPStatus();
    _initializeConversation();
  }

  Future<void> _fetchDoctorData() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorProfileId)
          .get();

      setState(() {
        doctorData = doctorDoc.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }

  Future<void> _checkVIPStatus() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      setState(() {
        isVIP = userDoc['isVIP'] ?? false;
      });
    } catch (e) {
      print("Error checking VIP status: $e");
    }
  }

  Future<void> _initializeConversation() async {
    try {
      QuerySnapshot conversationQuery = await FirebaseFirestore.instance
          .collection('conversations')
          .where('userId', isEqualTo: widget.userId)
          .where('doctorId', isEqualTo: widget.doctorAuthId)
          .get();

      if (conversationQuery.docs.isNotEmpty) {
        setState(() {
          conversationId = conversationQuery.docs.first.id;
        });
      } else {
        DocumentReference newConversation = await FirebaseFirestore.instance
            .collection('conversations')
            .add({
          'userId': widget.userId,
          'doctorId': widget.doctorAuthId,
          'lastMessage': '',
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          conversationId = newConversation.id;
        });
      }
    } catch (e) {
      print("Error initializing conversation: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();

    if (message.isEmpty || conversationId == null) return;

    if (!isVIP) {
      _showVIPDialog();
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'text': message,
        'sender': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message. Please try again.')),
      );
    }
  }

  void _showVIPDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Subscribe to VIP",
            style: TextStyle(
              color: Color(0xFF5D56AF),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Unlock unlimited chat, video, and audio calls with your doctor.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF5D56AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Subscribe"),
            ),
          ],
        );
      },
    );
  }

  void _startVoiceCall() async {
    if (!isVIP) {
      _showVIPDialog();
      return;
    }

    try {
      DocumentReference callRef = await FirebaseFirestore.instance
          .collection('calls')
          .add({
        'doctorId': widget.doctorAuthId,
        'userId': widget.userId,
        'callType': 'voice',
        'startTime': FieldValue.serverTimestamp(),
        'status': 'ongoing',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            callerId: widget.userId,
            receiverId: widget.doctorAuthId,
            isVideoCall: false,
            callRef: callRef,
          ),
        ),
      );
    } catch (e) {
      print("Error starting voice call: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start voice call. Please try again.')),
      );
    }
  }

  void _startVideoCall() async {
    if (!isVIP) {
      _showVIPDialog();
      return;
    }

    try {
      DocumentReference callRef = await FirebaseFirestore.instance
          .collection('calls')
          .add({
        'doctorId': widget.doctorAuthId,
        'userId': widget.userId,
        'callType': 'video',
        'startTime': FieldValue.serverTimestamp(),
        'status': 'ongoing',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallScreen(
            callerId: widget.userId,
            receiverId: widget.doctorAuthId,
            isVideoCall: true,
            callRef: callRef,
          ),
        ),
      );
    } catch (e) {
      print("Error starting video call: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start video call. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF5D56AF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'doctor_${widget.doctorProfileId}',
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: doctorData?['image'] != null
                        ? NetworkImage(doctorData!['image'])
                        : AssetImage('assets/images/Ellipse 8.png') as ImageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Text(
              doctorData?['name'] ?? "Doctor",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          if (isVIP) ...[
            IconButton(
              icon: Icon(Icons.call, color: Colors.white),
              onPressed: _startVoiceCall,
            ),
            IconButton(
              icon: Icon(Icons.videocam, color: Colors.white),
              onPressed: _startVideoCall,
            ),
          ],
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5D56AF).withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: conversationId == null
                  ? Center(child: CircularProgressIndicator())
                  : StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('conversations')
                          .doc(conversationId)
                          .collection('messages')
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var messages = snapshot.data!.docs;
                        
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var message = messages[index];
                            bool isSentByUser = message['sender'] == widget.userId;
                            DateTime? timestamp = message['timestamp']?.toDate();
                            String time = timestamp != null 
                                ? DateFormat('HH:mm').format(timestamp)
                                : '';

                            return Align(
                              alignment: isSentByUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                margin: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSentByUser
                                      ? Color(0xFF5D56AF)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20).copyWith(
                                    bottomRight: isSentByUser ? Radius.circular(0) : null,
                                    bottomLeft: !isSentByUser ? Radius.circular(0) : null,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isSentByUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['text'],
                                      style: TextStyle(
                                        color: isSentByUser
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: isSentByUser
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF5D56AF),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}