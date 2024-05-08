import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/model/users.dart';
import 'package:mudent_version2/screens/admin/userhsitory.dart';
import 'package:mudent_version2/service/token_service.dart';

import 'dart:convert';

class Achievement extends StatefulWidget {
  @override
  _AchievementState createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  String token = '';
  List<User> userList = [];
  late String url;
  var check = 0;

  @override
  void initState() {
    super.initState();
    check = 0;
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadToken();
    url = 'http://10.0.2.2:3000/user/all';
    await _fetchData();
  }

  Future<void> _loadToken() async {
    final storageService = StorageService();
    token = await storageService.readToken();
  }

  Future<void> _fetchData() async {
    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      debugPrint('Request successful');
      final jsonData = jsonDecode(response.body);
      userList = parseJsonData(jsonData);
      check = 1;
      setState(() {});
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userList.isEmpty && check == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'User List',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (userList.isEmpty && check == 1) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User List', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Text('No User'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Member List', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListTile(
                title: Text(userList[index].user_fullname),
                subtitle: Text(userList[index].user_email),
                leading: Icon(Icons.person),
                trailing: Text("ออกหน่วย: " +
                    userList[index].project_count.toString() +
                    " ครั้ง"),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserHistoryPage(user_id: userList[index].user_id)),
                  )
                },
                tileColor: Colors.white,
                shape: Border(bottom: BorderSide(color: Colors.grey)),
              ),
            );
          }),
    );
  }
}
