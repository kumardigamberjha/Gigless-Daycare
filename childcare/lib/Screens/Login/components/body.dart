import 'dart:convert';

import 'package:childcare/Screens/Homescreen/homescreen.dart';
import 'package:childcare/Screens/Login/components/auth_service.dart';
import 'package:childcare/Screens/Signup/signup_screen.dart';
import 'package:childcare/Screens/Welcome/components/SignUpOptions.dart';
import 'package:flutter/material.dart';
import 'package:childcare/Screens/Login/components/background.dart';
import 'package:childcare/Screens/Login/components/rounded_input_fields.dart';
import 'package:childcare/Screens/Login/components/rounded_password_field.dart';
import 'package:childcare/Screens/Login/components/text_field_container.dart';
import 'package:childcare/components/rounded_button.dart';
import 'package:childcare/constant.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'https://child.codingindia.co.in/'; // Replace with your API base URL

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to login');
    }
  }

  static Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/refresh/'),
      body: {
        'refresh': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
    prefs.remove('refreshToken');
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _formKey = GlobalKey<FormState>(); // Key for the form
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Background(
      child: Form(
        key: _formKey, // Assign the key to the form
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: KPrimaryColor,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            SvgPicture.asset(
              "assets/icons/login.svg",
              height: size.height * 0.35,
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            RoundedInputField(
              hintType: 'Enter Your Username',
              onChange: (String value) {},
              controller: emailController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter Your Username';
                }
                return null;
              },
              keyboardType: null,
            ),
            RoundedPasswordField(
              controller: passwordController,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onChanged: (String value) {},
            ),
            RoundedButton(
              text: "LOGIN",
              press: () {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, print the values
                  print('Email: ${emailController.text}');
                  print('Password: ${passwordController.text}');
                  loginUser(emailController.text, passwordController.text);
                }
              },
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Don't have an Account?",
                  style: TextStyle(color: KPrimaryColor),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle sign-up logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SignUpOptions();
                        },
                      ),
                    );
                  },
                  child: Text(
                    " Sign Up",
                    style: TextStyle(
                      color: KPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('https://child.codingindia.co.in/token/'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      print('Authentication successful');
      Map<String, dynamic> responseBody = json.decode(response.body);

      // Correct the way to access the access and refresh tokens
      String accessToken = responseBody['access'];
      String refreshToken = responseBody['refresh'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', accessToken);
      prefs.setString('refreshToken', refreshToken);
      print("Tokens Saved");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      print('Authentication failed');
      print('Error: ${response.body}');
      _showErrorSnackBar('Login failed. Please check your credentials.');
    }
  }

  void _showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
