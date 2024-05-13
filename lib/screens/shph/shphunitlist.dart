import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/model/users.dart';
import 'package:mudent_version2/screens/project_detail.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:mudent_version2/widget/dateformatthailand.dart';

class SHPHUnitList extends StatefulWidget {
  const SHPHUnitList({Key? key}) : super(key: key);

  @override
  State<SHPHUnitList> createState() => _SHPHUnitListState();
}

class _SHPHUnitListState extends State<SHPHUnitList> {
  List<User> userList = [];
  String token = '';
  List<ProjectUnit> projectlist = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadToken();
    await _fetchDataUser();
    await _fetchData();
  }

  Future<void> _loadToken() async {
    final storageService = StorageService();
    token = await storageService.readToken();
  }

  Future<void> _fetchDataUser() async {
    final url = Uri.parse('http://10.0.2.2:3000/userinfo');
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

  Future<void> _fetchData() async {
    final url =
        Uri.parse('http://10.0.2.2:3000/project/${userList[0].user_shph}');
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
      projectlist = parseJsonDataProject(jsonData);
      setState(() {});
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (projectlist.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('All Units', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.segment_sharp,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          ],
        ),
        body: const Center(
          child: Text('ไม้่มีโปรเจคที่กำลังดำเนินการ'),
        ),
      );
    }

    return Scaffold(
      // Add Scaffold widget as the parent
      appBar: AppBar(
          title: Text('All Units', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.segment_sharp,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          ]),
      body: Container(
        color: Colors.purple[50],
        child: ListView.builder(
          itemCount: projectlist.length,
          itemBuilder: (context, index) {
            final project = projectlist[index];

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Change the background color to grey
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.all(5),
                child: ListTile(
                  title: Text(
                    project.project_name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ที่อยู่ :" + " " + project.project_address),
                      Row(
                        children: [
                          Text('วันที่: '),
                          DateThai(
                            startDateThai:
                                project.project_start_date.toString(),
                            endDateThai: project.project_end_date.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDetailPage(project: project),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
