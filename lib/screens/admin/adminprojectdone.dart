import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/screens/admin/adminmyunitdetail.dart';
import 'package:mudent_version2/screens/shph/shphmyunitpagedetail.dart';

import 'package:mudent_version2/service/token_service.dart';
import 'package:mudent_version2/widget/dateformatthailand.dart';

class AdminAllProjectDonePage extends StatefulWidget {
  const AdminAllProjectDonePage({Key? key}) : super(key: key);

  @override
  State<AdminAllProjectDonePage> createState() =>
      _AdminAllProjectDonePageState();
}

class _AdminAllProjectDonePageState extends State<AdminAllProjectDonePage> {
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
    final url = Uri.parse('http://10.0.2.2:3000/project/complete');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Projects'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (projectlist.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
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
                  Text("Address: " + project.project_address),
                  Row(
                    children: [
                      Text('Date: '),
                      DateThai(
                        startDateThai: project.project_start_date.toString(),
                        endDateThai: project.project_end_date.toString(),
                      ),
                    ],
                  )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminAllProjectPageDetail(project: project),
                  ),
                ).then((value) => setState(() {
                      _initializeState();
                    }));
              },
            ),
          ),
        );
      },
    );
  }
}
