import 'package:flutter/material.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/screens/locationpage.dart';
import 'package:mudent_version2/screens/memberlistpage.dart';
import 'package:mudent_version2/screens/patientlistpage.dart';
import 'package:mudent_version2/service/token_service.dart';

import 'package:intl/intl.dart'; // For Date Format
import 'package:http/http.dart' as http;
import 'package:mudent_version2/widget/dateformatthailand.dart';

class MyProjectDetailPage extends StatefulWidget {
  final ProjectUnit project;
  const MyProjectDetailPage({required this.project});

  @override
  State<MyProjectDetailPage> createState() => _MyProjectDetailPageState();
}

class _MyProjectDetailPageState extends State<MyProjectDetailPage> {
  String token = '';

  Future<void> _leaveProject() async {
    final url = Uri.parse(
        'http://10.0.2.2:3000/project/${widget.project.project_id}/join');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      debugPrint('Request successful');
      Navigator.pop(context);
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  Future<void> _loadToken() async {
    final storageService = StorageService();
    token = await storageService.readToken();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Detail', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("หน่วย:",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.nature_people_rounded),
                          title: Text(widget.project.project_name),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("ที่อยู่:",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(widget.project.project_address),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("วันที่ออกหน่วย:",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: DateThai(
                            startDateThai:
                                widget.project.project_start_date.toString(),
                            endDateThai:
                                widget.project.project_end_date.toString(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Location:",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LocationPage(project: widget.project),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              20), // Adjust the radius as needed
                          child: Image.asset(
                            'assets/images/Capture.PNG',
                            width: double.infinity,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientListPage(
                                project: widget.project,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 170,
                            height: 120,
                            color: Colors.orange[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.list),
                                  Text("View Patient"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MemberListPage(project: widget.project),
                            ),
                          );
                          print("Member");
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 170,
                            height: 120,
                            color: Colors.purple[100],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group),
                                  Text("Member"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 170,
                            height: 120,
                            color: Colors.blueGrey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_camera_front_rounded),
                                  Text(
                                    "Video Call",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          _leaveProject();
                          print("Leave Group");
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 170,
                            height: 120,
                            color: Colors.redAccent[100],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_outlined),
                                  Text("Leave Group"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
