import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mudent_version2/screens/homepage.dart';
import 'package:mudent_version2/screens/registerpage.dart';
import 'package:mudent_version2/service/token_service.dart';
import 'package:mudent_version2/widget/show_image.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();

  Future<void> _loginUser() async {
    final String apiUrl = 'http://10.0.2.2:3000/login';
    final Map<String, dynamic> requestData = {
      'user_email': emailController.text,
      'user_password': passwordController.text,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // Successful login
        print('User logged in successfully');

        // Extract the JWT token from the response body
        final String token = jsonDecode(response.body)['token'];
        _storageService.writeToken(token);

        // Save the token to local storage or global state for future use
        // Example: SharedPreferences, Provider, etc.

        // Navigate to the home page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(),
          ),
          (route) => false, // This prevents the user from going back
        );
      } else if (response.statusCode == 400) {
        // User not found or invalid password
        print('Invalid credentials');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid email or password',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red, // Example color
          ),
        );
      } else {
        // Login failed
        print('Failed to log in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error logging in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MUDENT',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        // Add an icon for a modern look
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/mudentlogo.png',
                height: 90,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Login to your account',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                    fontSize: 17),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '**Please enter your email**';
                              }
                              return null;
                            },
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email,
                                  color: Color.fromARGB(255, 185, 185, 185)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '**Please enter your password**';
                              }
                              return null;
                            },
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock,
                                  color: Color.fromARGB(255, 185, 185, 185)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _loginUser();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              primary: Colors.purple, // Example color
                              minimumSize: Size(double.infinity,
                                  50), // Set the minimum width and height
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              primary: Colors.white, // Example color
                              minimumSize: Size(double.infinity,
                                  50), // Set the minimum width and height
                            ),
                            child: Text(
                              'New User? Sign Up',
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
