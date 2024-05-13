import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/screens/admin/adminprojectdone.dart';
import 'package:mudent_version2/screens/adminuserlist.dart';
import 'package:mudent_version2/screens/allprojectpage.dart';
import 'package:mudent_version2/screens/calendarpage.dart';
import 'package:mudent_version2/screens/disablepage.dart';
import 'package:mudent_version2/screens/historymyunitpage.dart';
import 'package:mudent_version2/screens/profilepage.dart';
import 'package:mudent_version2/screens/project_detail.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:mudent_version2/widget/dateformatthailand.dart';
import 'package:mudent_version2/widget/menu.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({Key? key}) : super(key: key);

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  String token = '';
  List<ProjectUnit> projectList = [];

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
    if (token.isEmpty) {
      // Handle token not available
      return;
    }

    final url = Uri.parse('http://10.0.2.2:3000/project/almost');
    try {
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
        projectList = parseJsonDataProject(jsonData);
        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
        // Handle error (e.g., show snackbar)
      }
    } catch (e) {
      debugPrint('Exception: $e');
      // Handle exception (e.g., show snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            child: Image.asset(
              'assets/images/background2.jpg',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(width: 14),
              Icon(Icons.home),
              Text("  AdminMenuPage",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Menu(
                  path: 'assets/images/allpj.png',
                  title: 'All Unit',
                  callback: () => AllProjectPage()),
              SizedBox(width: 14),
              Menu(
                path: 'assets/images/calendar.png',
                title: 'Calendar',
                callback: () => CalendarPage(),
              ),
              SizedBox(width: 14),
              Menu(
                path: 'assets/images/history.png',
                title: 'History',
                callback: () => HistoryMyProjectPage(),
              )
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Menu(
                path: 'assets/images/project_done.png',
                title: 'Unit Done',
                callback: () => AdminAllProjectDonePage(),
              ),
              SizedBox(width: 14),
              Menu(
                path: 'assets/images/profile.png',
                title: 'My Profile',
                callback: () => ProfilePage(),
              ),
              SizedBox(width: 14),
              Menu(
                path: 'assets/images/ach.jpg',
                title: 'Summary',
                callback: () => Achievement(),
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            children: [
              SizedBox(width: 14),
              Icon(Icons.newspaper_rounded),
              Text("  Lastest Unit",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple)),
            ],
          ),
          Container(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: projectList.length,
              itemBuilder: (context, index) {
                final project = projectList[index];

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors
                          .purple[50], // Change the background color to grey
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                      title: Text(
                        project.project_name,
                        style: TextStyle(
                          color: Colors.purple[900],
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
                                endDateThai:
                                    project.project_end_date.toString(),
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
        ],
      ),
    );
  }
}
