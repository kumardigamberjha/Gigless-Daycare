import 'dart:convert';
import 'package:childcare/Screens/ChildMedia/add_child_media.dart';
import 'package:childcare/Screens/ChildMedia/show_child_media.dart';
import 'package:childcare/Screens/DailyActivity/edit_daily_activity%20copy.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Attendance/monthlyAttendancePage.dart';
import 'package:childcare/Screens/Childrens/showchild.dart';
import 'package:childcare/Screens/DailyActivity/create_daily_activity.dart';
import 'package:childcare/Screens/DailyActivity/view_todays_activity.dart';

class ShowDailyActivityPage extends StatefulWidget {
  @override
  _ShowDailyActivityPageState createState() => _ShowDailyActivityPageState();
}

class _ShowDailyActivityPageState extends State<ShowDailyActivityPage> {
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

  void editTodaysActivity(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDailyActivityPage(childId: childId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Activity',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
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
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
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
                                          if (!childRecords[index][
                                              'isActivitySaved']) // Conditionally render the button
                                            ElevatedButton.icon(
                                              onPressed: () => addDailyActivity(
                                                  childRecords[index]['id']),
                                              icon: Icon(Icons.add),
                                              label: Text('Add Activity'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                          SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            onPressed: () => viewTodaysActivity(
                                                childRecords[index]['id']),
                                            icon: Icon(Icons.remove_red_eye),
                                            label: Text('View Activity'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor:
                                                  Color(0xFF0891B2),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          if (childRecords[index]
                                              ['isActivitySaved'])
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  editTodaysActivity(
                                                      childRecords[index]
                                                          ['id']),
                                              icon: Icon(Icons.remove_red_eye),
                                              label: Text('Edit Activity'),
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor: Colors.yellow,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        childRecords[index]['isActivitySaved']
                                            ? 'Activity saved for today'
                                            : 'Activity not saved for today',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: childRecords[index]
                                                  ['isActivitySaved']
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      )
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
