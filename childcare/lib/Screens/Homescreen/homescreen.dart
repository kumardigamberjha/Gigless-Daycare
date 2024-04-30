import 'dart:convert';

import 'package:childcare/Screens/ChildMedia/childlisr.dart';
import 'package:childcare/Screens/LearningResources/create_learning_resources.dart';
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
import 'package:childcare/Screens/Signup/CreateSatff.dart';
import 'package:childcare/Screens/Signup/ParentSignUpScreen.dart';
import 'package:childcare/Screens/Signup/showParentpage.dart';
import 'package:childcare/Screens/Signup/showstaffpage.dart';
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
        Uri.parse('https://daycare.codingindia.co.in/logout/'),
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
  Map<String, dynamic>? jsonResponse;

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
        Uri.parse('https://daycare.codingindia.co.in/student/api/user/'),
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
        await http.get(Uri.parse('https://daycare.codingindia.co.in/Accounts/dashboard/'));

    print("Json Response: ${jsonResponse}");
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      jsonResponse = json.decode(response.body);
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
        title: Text('Giggles Daycare', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6A1B9A),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
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

                  // _buildCard('Monthly Revenue', '\$8,333', Color(0xFF388E3C),
                  //     Colors.white),
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
          _buildSection(
            'Student Statistics',
            Icons.school,
            Color(0xFFFF9800),
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // _buildCard(
                  // 'Total Students', '${jsonResponse!['students']}', Color(0xFF388E3C), Colors.white),
                  _buildCard(
                      'Total Students',
                      "${dashboardData?['students'] ?? '0'}",
                      Color(0xFF388E3C),
                      Colors.white),

                  _buildCard(
                      'Present Today', '${dashboardData?['present'] ?? '0'}', Color(0xFF388E3C), Colors.white),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCard(
                      'Absent Today', '${dashboardData?['absent'] ?? '0'}', Color(0xFFD32F2F), Colors.white),
                ],
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
                color: Colors.purple,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Image.asset(
                      'assets/images/GD_Logo.png', // Replace 'assets/logo.png' with the actual path to your logo image
                      width: 100, // Adjust the width of the logo as needed
                    ),
                  ),
                  Positioned(
                    bottom: 12.0,
                    left: 12.0,
                    child: Text(
                      'Giggles Daycare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_user != null &&
                (_user!.userType != "Parent" && _user!.userType == "Staff"))
              ListTile(
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                },
              ),
            ExpansionTile(
              title: Text('students'),
              backgroundColor: Colors.purple,
              children: [
                // StaffSignUpScreen

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
                // Text(_user!.userType),
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
                backgroundColor: Colors.purple,
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
              ExpansionTile(
                title: Text('Staff'),
                backgroundColor: Colors.purple,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Add Staff',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffRegistrationPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Staff Record',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserListPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text(
                        'Parents Record',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the settings screen or implement the desired action
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentListPage(),
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
              backgroundColor: Colors.purple,
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
                backgroundColor: Colors.purple,
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

            ListTile(
              title: Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Check if the context is still active
                    if (Navigator.of(context).canPop()) {
                      return AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to logout?'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              logout(context); // Call the logout function
                            },
                            child: Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text('No'),
                          ),
                        ],
                      );
                    } else {
                      // Context is no longer active, possibly already disposed
                      // Handle this case gracefully, such as showing a snackbar
                      // or navigating to a different screen
                      return Container();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
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
