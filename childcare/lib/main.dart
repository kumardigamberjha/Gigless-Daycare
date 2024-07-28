import 'package:flutter/material.dart';
import 'package:childcare/Screens/Welcome/Welcome_screen.dart';
import 'package:childcare/constant.dart';
import 'package:childcare/Screens/splashscreen.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Child Care",
      // home: SplashScreen(),
      theme: ThemeData(
        // primarySwatch: Color(0xFF0891B2),
        primaryColor: KPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),
    );
  }
}
