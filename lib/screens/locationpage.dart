import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mudent_version2/model/project.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class LocationPage extends StatefulWidget {
  final ProjectUnit project;
  const LocationPage({Key? key, required this.project}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String token = '';
  String projectLat = '';
  String projectLon = '';

  late String url;
  WebViewController? controller;
  // Nullable WebViewController

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadToken();
    await _getLatLon();

    // Construct the URL with the obtained latitude and longitude

    url = 'https://www.google.com/maps?q=$projectLat,$projectLon';

    // Create WebViewController with the updated URL
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));

    controller!.loadRequest(Uri.parse(url));
  }

  Future<void> _loadToken() async {
    final storageService = StorageService();
    token = await storageService.readToken();
  }

  // Get Lat Lon
  Future<void> _getLatLon() async {
    final uri = Uri.parse(
        'http://10.0.2.2:3000/project/${widget.project.project_id}/latlon');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      debugPrint('Request successful');
      final List<dynamic> jsonDataList = jsonDecode(response.body);

      if (jsonDataList.isNotEmpty) {
        final jsonData = jsonDataList[0]; // Access the first element
        // Check if project_lat and project_lon are present and non-null
        if (jsonData.containsKey('project_lat') &&
            jsonData['project_lat'] != null &&
            jsonData.containsKey('project_lon') &&
            jsonData['project_lon'] != null) {
          // Parse values only if they are non-null
          projectLat = jsonData['project_lat'].toString();
          projectLon = jsonData['project_lon'].toString();
          setState(() {});
        } else {
          debugPrint('Invalid or missing data in JSON response.');
        }
      } else {
        debugPrint('Empty JSON response.');
      }
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.project_name),
      ),
      body: controller != null
          ? WebViewWidget(controller: controller!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
