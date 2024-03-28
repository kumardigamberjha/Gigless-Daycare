import 'package:childcare/Screens/Login/login_screen.dart';
import 'package:childcare/Screens/Signup/components/body.dart';
import 'package:childcare/Screens/Signup/signup_screen.dart';
import 'package:childcare/Screens/Signup/ParentSignUpScreen.dart';

import 'package:childcare/Screens/Signup/components/ParentSignUp.dart';

import 'package:flutter/material.dart';
import 'package:childcare/components/rounded_button.dart';
import 'package:childcare/constant.dart';
import 'package:childcare/Screens/Welcome/components/background.dart';
import 'package:flutter_svg/svg.dart';

class SignUpOptions extends StatelessWidget {
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
                  "You are ...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: KPrimaryColor,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                Image.asset(
                  "assets/images/so.jpg",
                  height: size.height * 0.45,
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                // RoundedButton(
                //   text: "Staff",
                //   press: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) {
                //           return StaffSignUpScreen();
                //         },
                //       ),
                //     );
                //   },
                // ),
                SizedBox(
                  height: 10, // Adjust as needed
                ),
                RoundedButton(
                  text: "Parent",
                  color: kPrimaryLightColor,
                  textColor: Colors.black,
                  press: () {
                    // Handle sign-up logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ParentSignUpScreen();
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
