import 'dart:convert';

import 'package:childcare/Screens/Login/components/rounded_input_fields.dart';
import 'package:childcare/Screens/Login/components/rounded_password_field.dart';
import 'package:childcare/Screens/Login/login_screen.dart';
import 'package:childcare/Screens/Signup/components/background.dart';
import 'package:childcare/Screens/Signup/components/or_divider.dart';
import 'package:childcare/Screens/Signup/components/social_icon.dart';
import 'package:childcare/components/rounded_button.dart';
import 'package:childcare/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Homescreen/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Body extends StatelessWidget {
  final Widget child;

  Body({Key? key, required this.child}) : super(key: key);

  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController mobileNumberController = TextEditingController();
    TextEditingController UserTypeController = TextEditingController();

    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "SIGN UP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: KPrimaryColor,
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              SvgPicture.asset(
                'assets/icons/signup.svg',
                height: size.height * 0.25,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              RoundedInputField(
                hintType: "Your Email",
                onChange: (value) {
                  // Update the state with the new value when the text changes
                  emailController.text = value;
                },
                controller: emailController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter Your Email';
                  } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                keyboardType: null,
              ),
              RoundedInputField(
                hintType: "Mobile Number",
                onChange: (value) {
                  // Update the state with the new value when the text changes
                  mobileNumberController.text = value;
                },
                controller: mobileNumberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter Your Mobile Number';
                  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid mobile number';
                  }
                  return null;
                },
              ),
              RoundedPasswordField(
                onChanged: (value) {},
                controller: passwordController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter Your Password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters long.';
                  } else if (!RegExp(r'(?=.*[a-zA-Z])(?=.*\d)')
                      .hasMatch(value)) {
                    return 'Password must contain at least one letter and one digit.';
                  }
                  return null;
                },
              ),
              RoundedButton(
                text: "SIGN UP",
                press: () {
                  if (_formKey.currentState!.validate()) {
                    // Form is valid, proceed with signUpUser
                    signUpUser(
                      emailController.text,
                      passwordController.text,
                      mobileNumberController.text,
                      emailController.text,
                      UserTypeController.text,
                      context,
                    );
                  }
                },
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Already have an Account?",
                    style: TextStyle(color: KPrimaryColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle sign-up logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginScreen(
                              successMessage:
                                  'Registration successful. Please log in.',
                            );
                          },
                        ),
                      );
                    },
                    child: const Text(
                      " Sign In",
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
      ),
    );
  }
}

// Add this function to your Body class
Future<void> signUpUser(String email, String password, String mobileNumber,
    String username, String usertype, BuildContext context) async {
  final response = await http.post(
    Uri.parse('https://child.codingindia.co.in/register/'),
    body: {
      'email': email,
      'password': password,
      'mobile_number': mobileNumber,
      'username': username,
      'usertype': usertype, // Use the provided usertype parameter
    },
  );

  if (response.statusCode == 201) {
    // Registration successful
    print('Registration successful');
    print('User ID: ${response.body}');

    // Proceed to login after successful registration
    await loginUsers(username, password, context); // Call loginUser function
  } else {
    // Registration failed
    print('Registration failed');
    print('Error: ${response.body}');
    // Handle registration failure appropriately
  }
}

Future<void> loginUsers(
    String username, String password, BuildContext context) async {
  String usernames = username.substring(0, username.indexOf('@'));
  final response = await http.post(
    Uri.parse('https://child.codingindia.co.in/token/'),
    body: {
      'username': usernames,
      'password': password,
    },
  );

  if (response.statusCode == 200) {
    print('Authentication successful');
    Map<String, dynamic> responseBody = json.decode(response.body);

    String accessToken = responseBody['access'];
    String refreshToken = responseBody['refresh'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    print("Tokens Saved");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  } else {
    // Registration failed
    print('Registration failed');
    print('Error: ${username} ${password} ${response.body}');
    // Show error message to the user
    // Check if 'email' key exists in the response
    try {
      final Map<String, dynamic> errorResponse = json.decode(response.body);

      // Check if 'email' key exists in the response
      if (errorResponse.containsKey('email')) {
        final errorMessage = errorResponse['email'][0];
        print("Email error: $errorMessage");

        // Map server error messages to more user-friendly messages
        final errorMapping = {
          'user with this email already exists.': 'Email is already in use.',
          'user with this mobile number already exists.':
              'Mobile number is already in use.',
          // Add more mappings for other possible error messages
        };

        // Use the mapping to display a more informative error message
        final userFriendlyError =
            errorMapping[errorMessage] ?? 'Unknown error occurred.';

        _showErrorDialog(context, 'Registration Error', userFriendlyError);
      } else if (errorResponse.containsKey('mobile_number')) {
        final errorMessage = errorResponse['mobile_number'][0];
        print("Mobile Number error: $errorMessage");

        // Map server error messages to more user-friendly messages
        final errorMapping = {
          'user with this email already exists.': 'Email is already in use.',
          'user with this mobile number already exists.':
              'Mobile number is already in use.',
          // Add more mappings for other possible error messages
        };

        // Use the mapping to display a more informative error message
        final userFriendlyError =
            errorMapping[errorMessage] ?? 'Unknown error occurred.';

        _showErrorDialog(context, 'Registration Error', userFriendlyError);
      } else if (errorResponse.containsKey('password')) {
        final errorMessage = errorResponse['password'][0];
        print("Password error: $errorMessage");

        // Map server error messages to more user-friendly messages
        final errorMapping = {
          'Ensure this field has at least 8 characters.':
              'Password must be at least 8 characters long.',
          'Password must contain at least one letter and at least one digit.':
              'Password must contain at least one letter and one digit.',
          // Add more mappings for other possible error messages
        };

        // Use the mapping to display a more informative error message
        final userFriendlyError =
            errorMapping[errorMessage] ?? 'Unknown error occurred.';

        _showErrorDialog(context, 'Registration Error', userFriendlyError);
      } else {
        // Handle the case when the expected key is not present in the response
        _showErrorDialog(
            context, 'Registration Error', 'Unknown error occurred.');
      }
    } catch (e) {
      // Handle the case when the response body cannot be decoded
      _showErrorDialog(
          context, 'Registration Error', 'Unknown error occurred.');
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

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
