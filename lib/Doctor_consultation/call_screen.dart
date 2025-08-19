import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "3370738e69384252a8a8af2c051dd3d2";
const token = "<-- Insert Token Here -->";

class CallScreen extends StatefulWidget {
  final String callerId; // Auth ID of the caller (doctor or patient)
  final String receiverId; // Auth ID of the receiver (doctor or patient)
  final bool isVideoCall;
  final DocumentReference callRef; // Reference to the Firestore call document

  CallScreen({
    required this.callerId,
    required this.receiverId,
    required this.isVideoCall,
    required this.callRef,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  late String channel;

  @override
  void initState() {
    super.initState();
    channel = "channel_${widget.callRef.id}"; // Use Firestore call document ID as the channel name
    _initPermissions();
    _initializeAgora();
    _logCallStart();
  }

  Future<void> _initPermissions() async {
    await [
      Permission.microphone,
      if (widget.isVideoCall) Permission.camera,
    ].request();
  }

  Future<void> _initializeAgora() async {
    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    if (widget.isVideoCall) {
      await _engine.enableVideo();
    } else {
      await _engine.disableVideo();
    }

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _logCallStart() async {
    try {
      await widget.callRef.update({
        'callerId': widget.callerId,
        'receiverId': widget.receiverId,
        'channel': channel,
        'callType': widget.isVideoCall ? 'video' : 'audio',
        'startTime': FieldValue.serverTimestamp(),
        'status': 'ongoing',
      });
    } catch (e) {
      debugPrint("Error logging call start: $e");
    }
  }

  Future<void> _logCallEnd() async {
    try {
      await widget.callRef.update({
        'endTime': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
    } catch (e) {
      debugPrint("Error logging call end: $e");
    }
  }

  @override
  void dispose() {
    _logCallEnd();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVideoCall ? "Video Call" : "Audio Call"),
        actions: [
          IconButton(
            icon: Icon(Icons.call_end, color: Colors.red),
            onPressed: () {
              Navigator.pop(context); // End the call
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(channelId: channel),
                    ),
                  )
                : const Text(
                    'Waiting for the other party to join...',
                    textAlign: TextAlign.center,
                  ),
          ),
          if (widget.isVideoCall)
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
