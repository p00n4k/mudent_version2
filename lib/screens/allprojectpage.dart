import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/screens/project_detail.dart';
import 'package:mudent_version2/service/token_service.dart';

class AllProjectPage extends StatefulWidget {
  const AllProjectPage({Key? key}) : super(key: key);

  @override
  State<AllProjectPage> createState() => _AllProjectPageState();
}

class _AllProjectPageState extends State<AllProjectPage> {
  String token = '';
  List<ProjectUnit> projectlist = [];

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
    final url = Uri.parse('http://10.0.2.2:3000/project');
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      // Add Scaffold widget as the parent
      appBar: AppBar(
          title: Text('All Projects', style: TextStyle(color: Colors.white)),
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
        color: Colors.grey[200],
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
                      Text(
                          'เริ่มวันที่: ${DateFormat('yyyy-MM-dd').format(project.project_start_date)}'),
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
