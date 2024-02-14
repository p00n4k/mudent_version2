import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mudent_version2/model/patient.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/screens/conference.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SHPHSecretGroup extends StatefulWidget {
  final ProjectUnit project;

  const SHPHSecretGroup({Key? key, required this.project}) : super(key: key);

  @override
  State<SHPHSecretGroup> createState() => _SHPHSecretGroupState();
}

class _SHPHSecretGroupState extends State<SHPHSecretGroup> {
  String token = '';
  List<Patient> patientlist = [];
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
    url =
        'http://10.0.2.2:3000/patient/${widget.project.project_id}/project/check';
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
      patientlist = parseJsonDataPatient(jsonData);
      check = 1;
      setState(() {});
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (patientlist.isEmpty && check == 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Patient List',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (patientlist.isEmpty && check == 1) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Patient List', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Container(
            child: const Text(
              "ไม่มีข้อมูลผู้ป่วย",
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ProjectUnit shphsecret = ProjectUnit(
              project_id: widget.project.project_id,
              project_name:
                  widget.project.project_name + widget.project.project_shph,
              project_time: widget.project.project_time,
              project_year: widget.project.project_year,
              project_address: widget.project.project_address,
              project_province: widget.project.project_province,
              project_district: widget.project.project_district,
              project_subdistrict: widget.project.project_subdistrict,
              project_start_date: widget.project.project_start_date,
              project_end_date: widget.project.project_end_date,
              project_shph: widget.project.project_shph,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConferencePage(project: shphsecret),
              ),
            );
          },
          child: Icon(Icons.video_call),
          backgroundColor: Colors.blueGrey[200],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Patient List', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: patientlist.length,
        itemBuilder: (context, index) {
          final birthday = DateFormat('yyyy-MM-dd')
              .format(patientlist[index].patient_birthday);
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(
                '${patientlist[index].patient_name} ${patientlist[index].patient_surname}'),
            subtitle: Text("ID: " + patientlist[index].patient_nationalid),
            trailing: Text("BD: " + birthday),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ProjectUnit shphsecret = ProjectUnit(
            project_id: widget.project.project_id,
            project_name:
                widget.project.project_name + widget.project.project_shph,
            project_time: widget.project.project_time,
            project_year: widget.project.project_year,
            project_address: widget.project.project_address,
            project_province: widget.project.project_province,
            project_district: widget.project.project_district,
            project_subdistrict: widget.project.project_subdistrict,
            project_start_date: widget.project.project_start_date,
            project_end_date: widget.project.project_end_date,
            project_shph: widget.project.project_shph,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConferencePage(project: shphsecret),
            ),
          );
        },
        child: Icon(Icons.video_call),
        backgroundColor: Colors.blueGrey[200],
      ),
    );
  }
}
