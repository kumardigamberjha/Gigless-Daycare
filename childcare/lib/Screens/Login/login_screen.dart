import 'package:childcare/Screens/Login/components/body.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {

  final String successMessage;

  const LoginScreen({Key? key, required this.successMessage}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Body(),
      ),
    );
  }
}
