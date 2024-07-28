import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TrackAttendancePage extends StatefulWidget {
  final int childId;

  TrackAttendancePage(this.childId);

  @override
  _TrackAttendancePageState createState() => _TrackAttendancePageState();
}

class _TrackAttendancePageState extends State<TrackAttendancePage> {
  late Future<Map<String, dynamic>> _attendanceStatsFuture;

  @override
  void initState() {
    super.initState();
    _attendanceStatsFuture = fetchAttendanceStats();
  }

  Future<Map<String, dynamic>> fetchAttendanceStats() async {
    final response = await http.get(Uri.parse(
        'https://child.codingindia.co.in/student/attendance/stats/${widget.childId}/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      // Sorting the dates
      data['present_dates']
          ?.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
      data['absent_dates']
          ?.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
      data['holiday_dates']
          ?.sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

      return data;
    } else {
      throw Exception('Failed to load attendance stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Stats',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _attendanceStatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Map<String, dynamic> attendanceStats = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      title1: 'Present',
                      value1: attendanceStats['num_days_present'].toString(),
                      title2: 'Leaves',
                      value2: attendanceStats['num_leaves'].toString(),
                    ),
                    SizedBox(height: 20),
                    _buildStatRow(
                      title1: 'Holidays',
                      value1: attendanceStats['num_holidays'].toString(),
                      title2: 'Days in Month',
                      value2: attendanceStats['num_days_in_month'].toString(),
                    ),
                    SizedBox(height: 20),
                    _buildDateListExpansionTile(
                        'Present Dates',
                        attendanceStats['present_dates'],
                        Icons.check_circle_outline,
                        Colors.green),
                    SizedBox(height: 10),
                    _buildDateListExpansionTile(
                        'Leaves Dates',
                        attendanceStats['absent_dates'],
                        Icons.cancel,
                        Colors.red),
                    SizedBox(height: 10),
                    _buildDateListExpansionTile(
                        'Holidays Dates',
                        attendanceStats['holiday_dates'],
                        Icons.calendar_today,
                        Colors.lightBlue),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatRow({
    required String title1,
    required String value1,
    required String title2,
    required String value2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(title1, value1, Colors.green),
        _buildStatCard(title2, value2, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildDateListExpansionTile(
      String title, List<dynamic>? dates, IconData iconData, Color iconColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(iconData, color: iconColor),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: iconColor),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: dates != null && dates.isNotEmpty
                  ? dates
                      .map<Widget>(
                          (date) => _buildDateItem(date, iconData, iconColor))
                      .toList()
                  : [Text('No dates')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String date, IconData iconData, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(iconData, color: iconColor),
        title: Text(
          DateFormat.yMMMd().format(DateTime.parse(date)),
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
      ),
    );
  }
}
