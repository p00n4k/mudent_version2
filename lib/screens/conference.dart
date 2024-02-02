import 'dart:convert';

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    if (userList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Conference'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text('Conference Page'),
            // Text('Project ID: ${widget.project.project_id}'),
            Text('Project Name: ${widget.project.project_name}'),
            Text('User Name: ${userList[0].user_fullname}'),
            Text('Email: ${userList[0].user_email}'),
          ],
        ),
      ),
    );
  }
}
