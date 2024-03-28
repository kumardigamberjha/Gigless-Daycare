import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:childcare/Screens/Homescreen/homescreen.dart';
import 'package:childcare/Screens/Login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Show splash screen for 5 seconds before checking token validity
    Future.delayed(Duration(seconds: 6), () {
      checkTokenValidity();
    });
  }

  Future<void> checkTokenValidity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? retrievedToken = prefs.getString('accessToken');
    String? refreshToken = prefs.getString('refreshToken');

    print('Retrieved Access Token: $retrievedToken');
    print('Retrieved Refresh Token: $refreshToken');

    // Check the validity of the access token
    if (retrievedToken != null) {
      final bool tokenIsValid = await validateToken(retrievedToken);
      if (tokenIsValid) {
        // Redirect to HomeScreen if token is valid
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Redirect to LoginScreen if token is invalid
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginScreen(
                successMessage: 'Registration successful. Please log in.',
              );
            },
          ),
        );
      }
    } else {
      // Redirect to LoginScreen if not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen(
              successMessage: 'Registration successful. Please log in.',
            );
          },
        ),
      );
    }
  }

  Future<bool> validateToken(String accessToken) async {
    final response = await http.post(
      Uri.parse('http://192.168.224.81:8000/validate-token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': accessToken}),
    );

    if (response.statusCode == 200) {
      print('Access token is valid');
      return true;
    } else {
      print('Access token is invalid');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // child: CircularProgressIndicator(), // Placeholder for splash screen
        child: Image.asset(
          'assets/images/gdgif.gif', // Path to your GIF file
          // width: 150, // Set width to 150
          // height: 150, // Set height to 150
          width: MediaQuery.of(context)
              .size
              .width, // Set width to full screen width
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}
