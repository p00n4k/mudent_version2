import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/model/users.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:http/http.dart' as http;

class ConferencePage extends StatefulWidget {
  final ProjectUnit project;

  const ConferencePage({Key? key, required this.project}) : super(key: key);
  @override
  State<ConferencePage> createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage> {
  String token = '';
  List<User> userList = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadToken();
    await _fetchData();
  }

  Future<void> _loadToken() async {
    final storageService = StorageService();
    token = await storageService.readToken();
  }

  Future<void> _fetchData() async {
    final url = Uri.parse('http://10.0.2.2:3000/user');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      debugPrint('Request successful');
      final jsonData = jsonDecode(response.body);
      userList = parseJsonData(jsonData);
      setState(() {});
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  bool isMicMute = true;
  bool isCameraOff = true;
  bool isAudioOff = true;
  bool screenShareOn = false;
  List<String> participants = [];
  final _jitsiMeetPlugin = JitsiMeet();

//join conference
  join() async {
    var options = JitsiMeetConferenceOptions(
      serverURL: 'https://telecon.ict.mahidol.ac.th',
      room: widget.project.project_name + widget.project.project_id.toString(),
      configOverrides: {
        "startWithAudioMuted": isMicMute,
        "startWithVideoMuted": isCameraOff,
        "subject": "Call"
      },
      featureFlags: {
        "unsaferoomwarning.enabled": false,
        "ios.screensharing.enabled": true,
        "prejoinpage.enabled": false,
        "welcomepage.enabled": false
      },
      userInfo: JitsiMeetUserInfo(
          displayName: userList[0].user_fullname,
          email: userList[0].user_email,
          avatar: "https://i.ibb.co/nDhcrW4/ictmahidol.jpg"),
    );

    await _jitsiMeetPlugin.join(options);
  }

  @override
  Widget build(BuildContext context) {
    if (userList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.project.project_name +
              ' Unit ID: ' +
              widget.project.project_id.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 50,
            ),
            Text(
              userList[0].user_fullname,
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.w700),
            ),
            Container(
              height: 50,
            ),
            Container(
              child: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 132, 58, 144),
                radius: 150,
              ),
            ),
            Container(
              height: 70,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            SwitchListTile(
                title: const Text('Muted Audio'),
                value: isAudioOff,
                onChanged: (bool value) {
                  setState(() {
                    isAudioOff = value;
                  });
                }),
            SwitchListTile(
                title: const Text('Turn off Camera'),
                value: isCameraOff,
                onChanged: (bool value2) {
                  setState(() {
                    isCameraOff = value2;
                  });
                }),
            SwitchListTile(
                title: const Text('Muted Microphone'),
                value: isMicMute,
                onChanged: (bool value3) {
                  setState(() {
                    isMicMute = value3;
                  });
                }),
            TextButton(onPressed: join, child: const Text("Join"))
          ],
        ),
      ),
    );
  }
}
