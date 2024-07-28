import 'package:childcare/Screens/Parent/Appointment/update_appoinment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentStatusPage extends StatefulWidget {
  @override
  _AppointmentStatusPageState createState() => _AppointmentStatusPageState();
}

class _AppointmentStatusPageState extends State<AppointmentStatusPage> {
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try {
      final response = await http.get(
        Uri.parse('https://child.codingindia.co.in/Parent/appointmentstatus/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          appointments = List<Map<String, dynamic>>.from(responseData);
          _isLoading = false;
        });
        // Store appointments locally
        prefs.setString('appointments', json.encode(responseData));
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      // Handle network errors
      String? storedAppointments = prefs.getString('appointments');
      if (storedAppointments != null) {
        setState(() {
          appointments =
              List<Map<String, dynamic>>.from(json.decode(storedAppointments));
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Show error message or retry button
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Failed to load appointments. Please check your internet connection.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment Status',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? Center(
                  child: Text(
                    'No Appointments Found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: appointments.asMap().entries.map((entry) {
                      final int index = entry.key + 1;
                      final appointment = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appointment $index',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                SizedBox(height: 12),
                                Text(
                                  appointment['appointment_type'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                SizedBox(height: 12),
                                Text(
                                  'Scheduled Time:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  appointment['scheduled_time'],
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                SizedBox(height: 12),
                                Text(
                                  'Notes:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  appointment['notes'],
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 12),
                                Divider(),
                                SizedBox(height: 12),
                                Text(
                                  'Status:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  color: _getStatusColor(appointment['status']),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    appointment['status'],
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
