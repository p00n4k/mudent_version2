import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mudent_version2/model/users.dart';
import 'package:mudent_version2/screens/admin/adminmenupage.dart';
import 'package:mudent_version2/screens/admin/adminmyunit.dart';
import 'package:mudent_version2/screens/allprojectpage.dart';
import 'package:mudent_version2/screens/menupage.dart';
import 'package:mudent_version2/screens/historymyunitpage.dart';
import 'package:mudent_version2/screens/Inprogressmyunitpage.dart';
import 'package:mudent_version2/screens/profilepage.dart';
import 'package:mudent_version2/service/token_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String token = '';
  List<User> userList = [];

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

  @override
  Widget build(BuildContext context) {
    if (userList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            width: 60,
            height: 60,
            child: Image(
              image: AssetImage('assets/images/logo2.png'),
            ),
          ),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            userList[0].user_role_id == 3 ? AdminMenuPage() : MenuPage(),
            ProfilePage(),
            userList[0].user_role_id == 3
                ? AdminAllProjectPage()
                : InprogressProjectPage(),
            AllProjectPage(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(text: 'Menu'),
            Tab(text: 'Profile'),
            userList[0].user_role_id == 3
                ? Tab(text: 'Admin Unit')
                : Tab(text: 'My Unit'),
            Tab(text: 'All Unit'),
          ],
        ),
      ),
    );
  }
}
