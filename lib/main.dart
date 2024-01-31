import 'package:flutter/material.dart';
import 'package:mudent_version2/screens/loginpage.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await initializeDateFormatting('th');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            color: Color.fromARGB(255, 132, 58, 144) //<-- SEE HERE
            ),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
