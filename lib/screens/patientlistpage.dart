import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mudent_version2/model/patient.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class PatientListPage extends StatefulWidget {
  final ProjectUnit project;

  const PatientListPage({Key? key, required this.project}) : super(key: key);

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
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
    url = 'http://10.0.2.2:3000/patient/${widget.project.project_id}/project';
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
        body: const Center(
          child: Text('No Patient'),
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
    );
  }
}
