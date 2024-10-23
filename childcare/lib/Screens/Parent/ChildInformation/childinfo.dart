import 'dart:convert';
import 'package:childcare/Screens/ChildMedia/show_child_media.dart';
import 'package:childcare/Screens/Childrens/showchild.dart';
import 'package:childcare/Screens/DailyActivity/view_todays_activity.dart';
import 'package:childcare/Screens/Parent/ChildInformation/roomMedia.dart';
import 'package:childcare/Screens/Parent/FeesList/fee.dart';
import 'package:childcare/Screens/Parent/childmediaP.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParentChildPage extends StatefulWidget {
  @override
  _ParentChildPageState createState() => _ParentChildPageState();
}

class _ParentChildPageState extends State<ParentChildPage> {
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = false;
  List<Map<String, dynamic>> childRecords = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      final response = await http.get(
        Uri.parse(
            'https://child.codingindia.co.in/Parent/childtodaysattendancep/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
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

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    final response = await http.get(
      Uri.parse("https://child.codingindia.co.in/Parent/"),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);

      if (data['error'] is List<dynamic>) {
        setState(() {
          childRecords = data['error'].cast<Map<String, dynamic>>();
        });
      } else {
        print('Unexpected response format: $data');
      }
    } else {
      print('Failed to load child records. Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Child Records',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : childRecords.isEmpty
              ? Center(
                  child: Text(
                    'No record available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: childRecords.length,
                  itemBuilder: (context, index) {
                    DateTime birthDate = DateTime.parse(
                        childRecords[index]['date_of_birth'] ?? '');
                    int age = DateTime.now().year - birthDate.year;

                    var todayAttendance = attendanceData.firstWhere(
                      (attendance) =>
                          attendance['child_id'] == childRecords[index]['id'],
                      orElse: () => Map<String, dynamic>(),
                    );
                    bool isPresent = todayAttendance.isNotEmpty
                        ? todayAttendance['is_present'] ?? false
                        : false;

                    Color cardColor =
                        isPresent ? Colors.lightGreen : Color(0xFFEF9A9A);

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          onTap: () =>
                              viewChildDetail(childRecords[index]['id']),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Color(0xFF0891B2),
                                                  width: 4),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  childRecords[index]
                                                          ['image'] ??
                                                      'https://via.placeholder.com/150',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '#${childRecords[index]['unique_id'] ?? ''}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Gender: ${childRecords[index]['gender'] ?? ''}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Fees: \$${childRecords[index]['child_fees'] ?? ''}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              isPresent ? 'Present' : 'Absent',
                                              style: TextStyle(
                                                color: isPresent
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewTodaysActivityPage(
                                                        childId:
                                                            childRecords[index]
                                                                ['id']),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.remove_red_eye),
                                          label: Text(
                                            "Today's Activity",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            backgroundColor: Colors
                                                .purple, // Button background color
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChildMediaDetailPage(
                                                            childId:
                                                                childRecords[
                                                                        index]
                                                                    ['id']),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.photo),
                                              label: Text(
                                                "Child Media",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                                backgroundColor: Colors
                                                    .purple, // Button background color
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChildRoomMedia(
                                                            childId:
                                                                childRecords[
                                                                        index]
                                                                    ['id']),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.video_library),
                                              label: Text(
                                                "Room Media",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                                backgroundColor: Colors
                                                    .purple, // Button background color
                                              ),
                                            ),
                                          ],
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

  void viewChildDetail(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ShowChildDetail(childId: childId)),
    );
  }

  void viewTodaysActivity(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTodaysActivityPage(childId: childId),
      ),
    );
  }

  void viewChildMedia(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildMediaPage(childId: childId),
      ),
    );
  }
}
