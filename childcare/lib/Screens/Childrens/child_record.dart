import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Attendance/monthlyAttendancePage.dart';
import 'package:childcare/Screens/Childrens/showchild.dart';
import 'package:childcare/Screens/DailyActivity/create_daily_activity.dart';
import 'package:childcare/Screens/ChildMedia/add_child_media.dart';

class ChildRecordsPage extends StatefulWidget {
  @override
  _ChildRecordsPageState createState() => _ChildRecordsPageState();
}

class _ChildRecordsPageState extends State<ChildRecordsPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> childRecords = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = true; // To track the loading state

  @override
  void initState() {
    super.initState();
    fetchData();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse("https://child.codingindia.co.in/student/child-list/"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        childRecords = data.cast<Map<String, dynamic>>();
        isLoading = false; // Set loading to false after data is fetched
        _animationController.forward();
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false if fetching fails
      });
      print('Failed to load child records. Error: ${response.statusCode}');
    }
  }

  Future<void> deleteChildRecord(int childId) async {
    final response = await http.get(
      Uri.parse(
          'https://child.codingindia.co.in/student/delete-child-data/$childId/'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Child record deleted successfully.')),
      );
      setState(() {
        // Remove the child record from the list after successful deletion
        childRecords.removeWhere((child) => child['id'] == childId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete child record.')),
      );
    }
  }

  void viewChildDetail(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ShowChildDetail(childId: childId)),
    );
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
          'Child Records',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : childRecords.isEmpty
              ? Center(
                  child: Text(
                    'No records available', // Show "No Record" message
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: childRecords.length,
                  itemBuilder: (context, index) {
                    DateTime birthDate = DateTime.parse(
                        childRecords[index]['date_of_birth'] ?? '');
                    int age = DateTime.now().year - birthDate.year;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: GestureDetector(
                        onTap: () => viewChildDetail(childRecords[index]['id']),
                        child: ScaleTransition(
                          scale: _animation,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      childRecords[index]['image'] ??
                                          'https://via.placeholder.com/150',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
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
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'ID: ${childRecords[index]['unique_id'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Age: $age',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Gender: ${childRecords[index]['gender'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Fees: \$${childRecords[index]['child_fees'] ?? ''}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.lightBlue),
                                    onPressed: () => viewChildDetail(
                                        childRecords[index]['id']),
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
