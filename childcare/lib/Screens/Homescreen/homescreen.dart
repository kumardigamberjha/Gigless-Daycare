import 'dart:convert';

import 'package:childcare/Screens/ChildMedia/childlisr.dart';
import 'package:childcare/Screens/Parent/Appointment/appointmentStatus.dart';
import 'package:childcare/Screens/Events/eventcal.dart';
import 'package:childcare/Screens/Parent/Appointment/create_appointment.dart';
import 'package:childcare/Screens/Attendance/monthlyAttendancePage.dart';
import 'package:childcare/Screens/Attendance/View_child_list.dart';
import 'package:childcare/Screens/Childrens/Createchild.dart';
import 'package:childcare/Screens/Childrens/child_record.dart';
import 'package:childcare/Screens/Childrens/showchild.dart';
import 'package:childcare/Screens/DailyActivity/images/addmultiimage.dart';
import 'package:childcare/Screens/Fees/CurrentYearAccountsDetail.dart';
import 'package:childcare/Screens/Fees/monthly_payment.dart';
import 'package:childcare/Screens/Fees/select_month_payemnt.dart';
import 'package:childcare/Screens/Login/LogoutScreen.dart';
import 'package:childcare/Screens/Parent/Appointment/show_appointment.dart';
import 'package:childcare/Screens/Parent/ChildInformation/childinfo.dart';
import 'package:childcare/Screens/Parent/FeesList/feelist.dart';
import 'package:childcare/Screens/Parent/eventp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Attendance/makeattendance.dart';
import 'package:childcare/Screens/DailyActivity/create_daily_activity.dart';
import 'package:childcare/Screens/DailyActivity/ShowDailyActivity.dart';
import 'package:childcare/Screens/ChildMedia/add_child_media.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:childcare/Screens/Login/login_screen.dart';
import 'package:childcare/Screens/Fees/fees_child_detail.dart';
// import 'package:childcare/Screens/Homescreen/DashboardCard.dart';

import 'package:flutter_svg/svg.dart';

class CustomUser {
  final String username;
  final String email;
  final String mobileNumber;
  final String userType;

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
        Uri.parse('http://127.0.0.1:8000/logout/'),
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
        Uri.parse('http://127.0.0.1:8000/student/api/user/'),
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
    final response =
        await http.get(Uri.parse('127.0.0.1:8000/Accounts/dashboard/'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load dashboard data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giggles Daycare'),
      ),

      // ***************** Content *************************
      backgroundColor:
          Colors.black, // Set the background color of the page to black
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // First section: Revenue Overview
          _buildSection(
            context,
            'Revenue Overview',
            Icons.attach_money,
            Colors.green,
            [
              _buildCard(
                context,
                'Yearly Revenue',
                '\$120,000',
                Colors.green,
              ),
              SizedBox(height: 16),
              _buildCard(
                context,
                'Monthly Revenue',
                '\$10,000',
                Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 24), // Add some space between sections
          // Second section: Student Statistics
          _buildSection(
            context,
            'Student Statistics',
            Icons.school,
            Colors.orange,
            [
              _buildCard(
                context,
                'Number of Child Enrolled',
                '500',
                Colors.orange,
              ),
              SizedBox(height: 16),
              _buildCard(
                context,
                'Present Students',
                '350',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
      // ****************** Content Ends ********************

      drawer: Drawer(
        // Add a drawer for the navigation menu
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Giggles Daycare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ExpansionTile(
              title: Text('students'),
              backgroundColor: Colors.blue,
              children: [
                if (_user != null && (_user!.userType == "Staff"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Add Record',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildCreateView(),
                          ),
                        );
                      },
                    ),
                  ),
                if (_user != null && (_user!.userType == "Staff"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'View Record',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildRecordsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                if (_user != null && (_user!.userType == "Parent"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Child Info',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentChildPage(),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            if (_user != null &&
                (_user!.userType != "Parent" && _user!.userType == "Staff"))
              ExpansionTile(
                title: Text('Attendance'),
                backgroundColor: Colors.blue,
                children: [
                  if (_user != null &&
                      (_user!.userType != "Parent" ||
                          _user!.userType == "Staff"))
                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: ListTile(
                        title: Text(
                          'Mark',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          // Navigate to the settings screen or implement the desired action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendancePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceChildRecordsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            if (_user != null &&
                (_user!.userType != "Parent" && _user!.userType == "Staff"))
              ListTile(
                title: Text('Daily Activity'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowDailyActivityPage(),
                    ),
                  );
                },
              ),


              if (_user != null &&
                (_user!.userType != "Parent" && _user!.userType == "Staff"))
              ListTile(
                title: Text('Child Media'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowChildActivityMediaPage(),
                    ),
                  );
                },
              ),

            // ***************** For Staff ************************
            if (_user != null &&
                (_user!.userType != "Parent" && _user!.userType == "Staff"))
              ListTile(
                title: Text('Events'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarScreen(),
                    ),
                  );
                },
              ),

            // ***************** For Parent ************************
            if (_user != null &&
                (_user!.userType == "Parent" && _user!.userType != "Staff"))
              ListTile(
                title: Text('Events'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalendarScreenForParent(),
                    ),
                  );
                },
              ),

            // ********************************* Appointment ************************

            ExpansionTile(
              title: Text('Appointment'),
              backgroundColor: Colors.blue,
              children: [
                if (_user != null &&
                    (_user!.userType == "Parent" && _user!.userType != "Staff"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Request',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateParentAppointmentView(),
                          ),
                        );
                      },
                    ),
                  ),
                if (_user != null &&
                    (_user!.userType == "Parent" && _user!.userType != "Staff"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'View Status',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentStatusPage(),
                          ),
                        );
                      },
                    ),
                  ),
                if (_user != null &&
                    (_user!.userType != "Parent" && _user!.userType == "Staff"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'View Status',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentStatusStaffPage(),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            if (_user != null &&
                (_user!.userType != "Parent" && _user!.userType == "Staff"))
              ExpansionTile(
                title: Text('Accounts'),
                backgroundColor: Colors.blue,
                children: [
                  if (_user != null &&
                      (_user!.userType != "Parent" ||
                          _user!.userType == "Staff"))
                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: ListTile(
                        title: Text(
                          'Tuition Fees',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChildListFeesPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Current Month',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TotalPaymentsCurrentMonthPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Other Month',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectedMonthlyPaymentsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Current Year',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CurrentYearAccountDetailPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            if (_user != null &&
                (_user!.userType == "Parent" && _user!.userType != "Staff"))
              ListTile(
                title: Text('Accounts'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PPaymentsPage(),
                    ),
                  );
                },
              ),
            Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: ListTile(
                title: ElevatedButton(
                  onPressed: () => logout(context),
                  child: Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon,
      Color color, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.grey, // Set the icon color to grey
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set the text color to white
                ),
              ),
            ],
          ),
        ),
        ...cards,
      ],
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String value, Color color) {
    return GestureDetector(
      onTap: () {
        // Add onTap functionality if needed
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.grey[900], // Set the card background color to dark grey
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Set the text color to white
                ),
              ),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
