import 'dart:convert';
import 'package:childcare/Screens/Childrens/rooms.dart';
import 'package:childcare/Screens/Events/eventcal.dart';
import 'package:childcare/Screens/Homescreen/CustomNav.dart';
import 'package:childcare/Screens/Login/login_screen.dart';
import 'package:childcare/Screens/Parent/Appointment/create_appointment.dart';
import 'package:childcare/Screens/Parent/ChildInformation/childinfo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomUser {
  final String username;
  final String email;
  final String mobileNumber;
  final String userType;
  int _noOfRooms = 0;

  CustomUser({
    required this.username,
    required this.email,
    required this.mobileNumber,
    required this.userType,
  });

  factory CustomUser.fromJson(Map<String, dynamic> json) {
    return CustomUser(
      username: json['username'],
      email: json['email'],
      mobileNumber: json['mobile_number'],
      userType: json['usertype'],
    );
  }
}

Future<void> logout(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      var response = await http.post(
        Uri.parse('https://child.codingindia.co.in/logout/'),
        body: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        // Clear access token from local storage
        prefs.remove('accessToken');
        // Navigate to home screen
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
      } else {
        // Handle logout failure
        print('Failed to logout: ${response.body}');
      }
    }
  } catch (e) {
    // Handle logout exception
    print('Error during logout: $e');
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CustomUser? _user;
  Map<String, dynamic>? dashboardData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchDashboardData().then((data) {
      setState(() {
        dashboardData = data;
      });
    });
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('https://child.codingindia.co.in/student/api/user/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        setState(() {
          _user = CustomUser.fromJson(jsonBody);
        });
      } else {
        print('Failed to fetch user data');
      }
    } else {
      print('Access token not found');
    }
  }

  Future<Map<String, dynamic>> fetchDashboardData() async {
    final response = await http
        .get(Uri.parse('https://child.codingindia.co.in/Accounts/dashboard/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giggles Daycare', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0891B2), // Custom app bar color
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          if (_user != null &&
              (_user!.userType != "Parent" && _user!.userType == "Staff"))
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildDashboardCard(
                  'Rooms',
                  ' ',
                  Icons.meeting_room,
                  Colors.teal,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomPage(),
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  'Messages',
                  ' ',
                  Icons.message,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateParentAppointmentView(),
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  'Reminders',
                  ' ',
                  Icons.alarm,
                  Colors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          SizedBox(height: 24),
          if (_user != null &&
              (_user!.userType != "Parent" && _user!.userType == "Staff"))
            _buildSection(
              'Revenue Overview',
              Icons.attach_money,
              Color(0xFF388E3C),
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCard(
                        'Yearly Revenue',
                        "\$${dashboardData?['year_amount'] ?? '0'}",
                        Color(0xFF388E3C),
                        Colors.white),
                    _buildCard(
                        'Monthly Revenue',
                        "\$${dashboardData?['total_payments'] ?? '0'}",
                        Color(0xFF388E3C),
                        Colors.white),
                  ],
                ),
              ],
            ),
          SizedBox(height: 24),
          if (_user != null)
            (_user!.userType != "Parent" && _user!.userType == "Staff")
                ? _buildSection(
                    'Revenue Overview',
                    Icons.attach_money,
                    Color(0xFF388E3C),
                    [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard(
                              'Yearly Revenue',
                              "\$${dashboardData?['year_amount'] ?? '0'}",
                              Color(0xFF388E3C),
                              Colors.white),
                          _buildCard(
                              'Monthly Revenue',
                              "\$${dashboardData?['total_payments'] ?? '0'}",
                              Color(0xFF388E3C),
                              Colors.white),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildDashboardCard(
                            'Child Data',
                            ' ',
                            Icons.meeting_room,
                            const Color.fromARGB(255, 18, 163, 149),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParentChildPage(),
                                ),
                              );
                            },
                          ),
                          _buildDashboardCard(
                            'Appointment',
                            ' ',
                            Icons.message,
                            Colors.blue,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateParentAppointmentView(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
        ],
      ),
      drawer: CustomDrawer(user: _user),
    );
  }

  Widget _buildDashboardCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.white),
                SizedBox(height: 8),
                Text(title,
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(height: 8),
                Text(subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          )),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
        ),
        ...cards,
      ],
    );
  }

  Widget _buildCard(
      String title, String value, Color textColor, Color backgroundColor) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
