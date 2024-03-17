import 'package:childcare/Screens/Login/login_screen.dart';
import 'package:childcare/Screens/Signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:childcare/components/rounded_button.dart';
import 'package:childcare/constant.dart';
import 'package:childcare/Screens/Welcome/components/background.dart';
import 'package:flutter_svg/svg.dart';
import 'package:childcare/Screens/Welcome/components/SignUpOptions.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Welcome To Giggles Daycare",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: KPrimaryColor,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                SvgPicture.asset(
                  "assets/icons/chat.svg",
                  height: size.height * 0.45,
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                RoundedButton(
                  text: "LOGIN",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return LoginScreen();
                      }),
                    );
                  },
                ),
                SizedBox(
                  height: 10, // Adjust as needed
                ),
                RoundedButton(
                  text: "SIGN UP",
                  color: kPrimaryLightColor,
                  textColor: Colors.black,
                  press: () {
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
