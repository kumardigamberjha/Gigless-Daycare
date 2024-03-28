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
        Uri.parse('http://192.168.224.81:8000/student/api/current-attendance/'),
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
        Uri.parse('http://192.168.224.81:8000/student/toggle-attendance/'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Records'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : attendanceData.isEmpty
              ? Center(
                  child: Text('No attendance records found.'),
                )
              : ListView.builder(
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
                ),
    );
  }
}
