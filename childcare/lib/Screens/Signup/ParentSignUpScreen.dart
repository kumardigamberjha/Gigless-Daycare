import "package:childcare/Screens/Signup/components/body.dart";
import "package:childcare/Screens/Signup/components/ParentSignUp.dart";

import "package:flutter/material.dart";

class ParentSignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParentSignUp(
        child: SingleChildScrollView(child: Column()),
      ),
    );
  }
}


class StaffSignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        child: SingleChildScrollView(child: Column()),
      ),
    );
  }
}
