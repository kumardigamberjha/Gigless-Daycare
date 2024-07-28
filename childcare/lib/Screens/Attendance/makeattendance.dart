import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://child.codingindia.co.in/student/api/current-attendance/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          attendanceData =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load attendance data');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleAttendance(int? childId, bool? isPresent) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (childId == null || isPresent == null) {
        return;
      }

      final response = await http.post(
        Uri.parse('https://child.codingindia.co.in/student/toggle-attendance/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'child_id': childId.toString(),
          'is_present': !isPresent,
        }),
      );

      if (response.statusCode == 200) {
        fetchAttendanceData();
      } else {
        throw Exception('Failed to toggle attendance');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Attendance',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF0891B2),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.pink,
            tabs: [
              Tab(text: 'STUDENTS'),
              Tab(text: 'STAFF'),
            ],
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : attendanceData.isEmpty
                ? Center(
                    child: Text('No attendance records found.'),
                  )
                : TabBarView(
                    children: [
                      buildAttendanceList(), // For Students
                      Center(
                          child: Text(
                              'Staff attendance will be here')), // Placeholder for Staff
                    ],
                  ),
        // bottomNavigationBar: Container(
        //   color: Color(0xFF0891B2),
        //   child: SafeArea(
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: TextButton(
        //         style: TextButton.styleFrom(
        //           backgroundColor: Colors.white,
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(8)),
        //         ),
        //         onPressed: () {
        //           // Open Check-In Kiosk
        //         },
        //         child: Text(
        //           'OPEN CHECK-IN KIOSK',
        //           style: TextStyle(
        //               color: Color(0xFF0891B2), fontWeight: FontWeight.bold),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  Widget buildAttendanceList() {
    return ListView.builder(
      itemCount: attendanceData.length,
      itemBuilder: (context, index) {
        final record = attendanceData[index];
        final childName = record['child_name'] ?? 'N/A';
        final isPresent = record['is_present'];
        final childId = record['child_id'];

        return GestureDetector(
          onTap: () {
            // Navigate to child detail page or perform other actions
          },
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    record['child_image'] ?? 'https://via.placeholder.com/150'),
              ),
              title: Text(
                childName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                isPresent ? 'Present' : 'Absent',
                style: TextStyle(
                  color: isPresent ? Colors.green : Colors.red,
                ),
              ),
              trailing: IconButton(
                onPressed: () {
                  toggleAttendance(childId, isPresent);
                },
                icon: Icon(
                  isPresent ? Icons.check_circle : Icons.cancel,
                  color: isPresent ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
