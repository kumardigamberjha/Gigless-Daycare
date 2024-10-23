import 'package:childcare/Screens/Homescreen/homescreen.dart';
import 'package:childcare/Screens/Parent/ChildInformation/roomMedia.dart';
import 'package:childcare/Screens/Signup/components/CreateparentByUser.dart';
import 'package:flutter/material.dart';
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
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Attendance/makeattendance.dart';
import 'package:childcare/Screens/DailyActivity/create_daily_activity.dart';
import 'package:childcare/Screens/DailyActivity/ShowDailyActivity.dart';
import 'package:childcare/Screens/ChildMedia/add_child_media.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:childcare/Screens/Login/login_screen.dart';
import 'package:childcare/Screens/Fees/fees_child_detail.dart';
import 'package:childcare/Screens/Childrens/rooms.dart';

class CustomDrawer extends StatelessWidget {
  final CustomUser? user;

  CustomDrawer({this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF0891B2),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    'assets/images/GD_Logo.png',
                    width: 100,
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
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
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
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
            ListTile(
              title: Text('Room'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomPage(),
                  ),
                );
              },
            ),
          ExpansionTile(
            title: Text('Students'),
            backgroundColor: Color.fromARGB(255, 59, 168, 218),
            children: [
              if (user != null && (user!.userType == "Staff"))
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('Add Record'),
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
              if (user != null && (user!.userType == "Staff"))
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('View Record'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChildRecordsPage(),
                        ),
                      );
                    },
                  ),
                ),
              if (user != null && (user!.userType == "Parent"))
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('Child Info'),
                    onTap: () {
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
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
            ExpansionTile(
              title: Text('Attendance'),
              backgroundColor: Color.fromARGB(255, 59, 168, 218),
              children: [
                if (user != null &&
                    (user!.userType != "Parent" || user!.userType == "Staff"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Mark'),
                      onTap: () {
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
                    title: Text('View'),
                    onTap: () {
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
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
            ExpansionTile(
              title: Text('Staff'),
              backgroundColor: Color.fromARGB(255, 59, 168, 218),
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('Add Staff'),
                    onTap: () {
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
                    title: Text('Staff Record'),
                    onTap: () {
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
                    title: Text('Add Parent'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParentRegistrationPage(),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('Parents Record'),
                    onTap: () {
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
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
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
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
            ListTile(
              title: Text('Child Pictures'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowChildActivityMediaPage(),
                  ),
                );
              },
            ),
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
            ListTile(
              title: Text('Calendar Events'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScreen(),
                  ),
                );
              },
            ),
          if (user != null &&
              (user!.userType == "Parent" && user!.userType != "Staff"))
            ListTile(
              title: Text('Calendar Events'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScreenForParent(),
                  ),
                );
              },
            ),
          ExpansionTile(
            title: Text('Appointment'),
            backgroundColor: Color.fromARGB(255, 59, 168, 218),
            children: [
              if (user != null &&
                  (user!.userType == "Parent" && user!.userType != "Staff"))
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('Request'),
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
              if (user != null &&
                  (user!.userType == "Parent" && user!.userType != "Staff"))
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('View Status'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentStatusPage(),
                        ),
                      );
                    },
                  ),
                ),
              if (user != null &&
                  (user!.userType != "Parent" && user!.userType == "Staff"))
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('View Status'),
                    onTap: () {
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
          if (user != null &&
              (user!.userType != "Parent" && user!.userType == "Staff"))
            ExpansionTile(
              title: Text('Accounts'),
              backgroundColor: Color.fromARGB(255, 59, 168, 218),
              children: [
                if (user != null &&
                    (user!.userType != "Parent" || user!.userType == "Staff"))
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: ListTile(
                      title: Text('Tuition Fees'),
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
                    title: Text('Current Month'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TotalPaymentsCurrentMonthPage(),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: Text('Other Month'),
                    onTap: () {
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
                    title: Text('Current Year'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CurrentYearAccountDetailPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          if (user != null &&
              (user!.userType == "Parent" && user!.userType != "Staff"))
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
                  if (Navigator.of(context).canPop()) {
                    return AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            logout(context);
                          },
                          child: Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
