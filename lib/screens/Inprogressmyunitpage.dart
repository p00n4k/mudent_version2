import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/model/users.dart';
import 'package:mudent_version2/screens/admin/adminmyunitdetail.dart';
import 'package:mudent_version2/screens/default/defaultmyunitdetailpage.dart';
import 'package:mudent_version2/screens/shph/shphmyunitpagedetail.dart';
import 'package:mudent_version2/screens/project_detail.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:mudent_version2/widget/dateformatthailand.dart';

class InprogressProjectPage extends StatefulWidget {
  const InprogressProjectPage({Key? key}) : super(key: key);

  @override
  State<InprogressProjectPage> createState() => _InprogressProjectPageState();
}

class _InprogressProjectPageState extends State<InprogressProjectPage> {
  String token = '';
  List<User> userList = [];
  List<ProjectUnit> projectlist = [];
  bool check = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadToken();
    await _checkUser();
    await _fetchDataUser();
  }

  Future<void> _loadToken() async {
    final storageService = StorageService();
    token = await storageService.readToken();
  }

  Future<void> _checkUser() async {
    final url = Uri.parse('http://10.0.2.2:3000/project/join/notcomplete');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      debugPrint('Request successful');
      if (response.body == '') {
        setState(() {
          check = true;
          projectlist = [];
        });
      } else {
        final jsonData = jsonDecode(response.body);
        projectlist = parseJsonDataProject(jsonData);
        setState(() {
          check = true;
        });
      }
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchDataUser() async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'In progress Unit',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.history),
          ),
        ],
      ),
      body: _buildProjectList(),
    );
  }

  Widget _buildProjectList() {
    if (projectlist.isEmpty && check == true) {
      return Container(
          color: Colors.purple[50],
          child: Center(child: Text("ไม่มีโปรเจคที่เข้าร่วม")));
    } else if (projectlist.isNotEmpty && check == true) {
      return Container(
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
                    if (userList[0].user_role_id == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminAllProjectPageDetail(project: project),
                        ),
                      ).then((value) => setState(() {
                            _initializeState();
                          }));
                    } else if (userList[0].user_shph == project.project_shph) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SHPHAllProjectPageDetail(project: project),
                        ),
                      ).then((value) => setState(() {
                            _initializeState();
                          }));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DefaultMyProjectDetailPage(project: project),
                        ),
                      ).then((value) => setState(() {
                            _initializeState();
                          }));
                    }
                  },
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
