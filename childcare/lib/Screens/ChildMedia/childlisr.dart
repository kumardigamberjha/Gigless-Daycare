import 'dart:convert';
import 'package:childcare/Screens/ChildMedia/add_child_media.dart';
import 'package:childcare/Screens/ChildMedia/show_child_media.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Attendance/monthlyAttendancePage.dart';
import 'package:childcare/Screens/Childrens/showchild.dart';
import 'package:childcare/Screens/DailyActivity/create_daily_activity.dart';
import 'package:childcare/Screens/DailyActivity/view_todays_activity.dart';

class ShowChildActivityMediaPage extends StatefulWidget {
  @override
  _ShowChildActivityMediaPageState createState() =>
      _ShowChildActivityMediaPageState();
}

class _ShowChildActivityMediaPageState
    extends State<ShowChildActivityMediaPage> {
  List<Map<String, dynamic>> childRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
          Uri.parse("https://child.codingindia.co.in/student/child-list/"));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        for (var child in data) {
          final statusResponse = await http.get(Uri.parse(
              "https://child.codingindia.co.in/student/api/daily-activity/${child['id']}"));

          if (statusResponse.statusCode == 200) {
            final Map<String, dynamic> statusData =
                json.decode(statusResponse.body);
            // child['isActivitySaved'] = statusData['is_activity_saved'];
            child['isActivitySaved'] = statusData['is_activity_saved'] ?? false;
          } else {
            // Assume activity is not saved if there's an error
            child['isActivitySaved'] = false;
          }
        }

        setState(() {
          childRecords = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        print('Failed to load child records. Error: ${response.statusCode}');
        // Handle error, show a snackbar, or retry option
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error, show a snackbar, or retry option
    }
  }

  void viewChildDetail(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowChildDetail(childId: childId),
      ),
    );
  }

  void addDailyActivity(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyActivityPage(childId: childId),
      ),
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

  void addTodayschildMedia(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildMediaPage(childId: childId),
      ),
    );
  }

  void viewTodayschildMedia(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildMediaDetailPage(childId: childId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activity Media",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : childRecords.isEmpty
              ? Center(
                  child: Text('No child records available'),
                )
              : ListView.builder(
                  itemCount: childRecords.length,
                  itemBuilder: (context, index) {
                    DateTime birthDate = DateTime.parse(
                        childRecords[index]['date_of_birth'] ?? '');
                    int age = DateTime.now().year - birthDate.year;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        // onTap: () => viewChildDetail(childRecords[index]['id']),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.brown,
                                      width: 4,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        childRecords[index]['image'] ??
                                            'https://via.placeholder.com/150',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${childRecords[index]['first_name'] ?? ''} ${childRecords[index]['last_name'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Column(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                addTodayschildMedia(
                                                    childRecords[index]['id']),
                                            icon: Icon(Icons.remove_red_eye),
                                            label: Text('Add Activity'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Color(
                                                  0xFF0891B2), // Text color
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  10), // Adjusted spacing between buttons
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                viewTodayschildMedia(
                                                    childRecords[index]['id']),
                                            icon: Icon(Icons.history),
                                            label: Text('View Activity'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  Colors.green, // Text color
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Adjusted spacing between button row and text
                                    ],
                                  ),
                                ),
                              ],
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
