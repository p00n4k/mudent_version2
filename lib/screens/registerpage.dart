import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:mudent_version2/screens/homepage.dart';
import 'package:mudent_version2/screens/loginpage.dart'; // Import your homepage if needed

class RegisterPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Add a global key for the Form

  String? _validatePassword(String value) {
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _registerUser() async {
    final String apiUrl = 'http://10.0.2.2:3000/register';

    final Map<String, dynamic> requestData = {
      'user_email': emailController.text,
      'user_name': fullNameController.text,
      'user_password': passwordController.text,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        // Successful registration

        print('User registered successfully');

        // Navigate to the home page or another page if needed
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false, // This prevents the user from going back
        );
      } else if (response.statusCode == 409) {
        // Email already exists
        print('Email already exists');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('**Email already in use**'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Registration failed
        print('Failed to register user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error registering user: $e');
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Associate the global key with the Form
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Create an account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator:
                      RequiredValidator(errorText: "**REQUIRE FullName**"),
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person,
                        color: Color.fromARGB(255, 185, 185, 185)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: MultiValidator([
                    EmailValidator(errorText: "**REQUIRE EMAIL**"),
                    RequiredValidator(errorText: "**REQUIRE EMAIL**"),
                  ]),
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
                  validator:
                      RequiredValidator(errorText: "**REQUIRE Password**"),
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
                TextFormField(
                  validator: (value) => _validatePassword(value!),
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                      _registerUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    primary: Colors.purple, // Example color
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
