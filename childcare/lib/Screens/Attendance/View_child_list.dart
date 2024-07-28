import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Attendance/monthlyAttendancePage.dart';
import 'package:childcare/Screens/DailyActivity/create_daily_activity.dart';
import 'package:childcare/Screens/ChildMedia/add_child_media.dart';

class AttendanceChildRecordsPage extends StatefulWidget {
  @override
  _AttendanceChildRecordsPageState createState() =>
      _AttendanceChildRecordsPageState();
}

class _AttendanceChildRecordsPageState
    extends State<AttendanceChildRecordsPage> {
  List<Map<String, dynamic>> childRecords = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse("https://child.codingindia.co.in/student/child-list/"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        childRecords = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load child records. Error: ${response.statusCode}');
    }
  }

  void AddDailyActivity(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyActivityPage(childId: childId),
      ),
    );
  }

  void AddChildMedia(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildMediaPage(childId: childId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Track Attendance',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
      ),
      body: childRecords.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: childRecords.length,
              itemBuilder: (context, index) {
                DateTime birthDate =
                    DateTime.parse(childRecords[index]['date_of_birth'] ?? '');
                int age = DateTime.now().year - birthDate.year;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () => {},
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color(0xFF0891B2), width: 2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            childRecords[index]['image'] ??
                                                'https://via.placeholder.com/150',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '#${childRecords[index]['unique_id'] ?? ''}',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${childRecords[index]['first_name'] ?? ''}\n${childRecords[index]['last_name'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Age: $age',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Gender: ${childRecords[index]['gender'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TrackAttendancePage(
                                            childRecords[index]['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    color: Color(0xFF0891B2),
                                  ),
                                  Text(
                                    'Track\nAttendance',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF0891B2),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
