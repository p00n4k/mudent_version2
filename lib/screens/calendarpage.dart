import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/screens/project_detail.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:mudent_version2/widget/dateformatthailand.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String token = '';

  List<ProjectUnit> projectlist = [];
  var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool check = false;

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
    final url = Uri.parse('http://10.0.2.2:3000/project/date');
    final Map<String, dynamic> requestData = {
      'start_date': '$date',
    };
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    );
    if (response.statusCode == 200) {
      debugPrint('Request successful');
      final jsonData = jsonDecode(response.body);
      projectlist = parseJsonDataProject(jsonData);
      setState(() {
        check = true;
      });
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Page', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CalendarDatePicker(
              onDateChanged: (DateTime date) {
                print('Selected date: $date');
                setState(() {
                  this.date = DateFormat('yyyy-MM-dd').format(date);
                  _fetchData();
                  check = false;
                });
              },
              firstDate: DateTime(2022),
              lastDate: DateTime(2025),
              initialDate: DateTime.now(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
              ),
              Text(
                "Date : ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900]),
              ),
              Text(date,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Expanded(
            child: check && projectlist.isNotEmpty
                ? ListView.builder(
                    itemCount: projectlist.length,
                    itemBuilder: (context, index) {
                      final project = projectlist[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple[
                                50], // Change the background color to grey
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
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
                                Text("ที่อยู่ :" +
                                    " " +
                                    project.project_address),
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
                  )
                : Text('No project'),
          ),
        ],
      ),
    );
  }
}
