import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:childcare/Screens/Parent/Appointment/update_appoinment.dart';

class AppointmentStatusStaffPage extends StatefulWidget {
  @override
  _AppointmentStatusStaffPageState createState() =>
      _AppointmentStatusStaffPageState();
}

class _AppointmentStatusStaffPageState
    extends State<AppointmentStatusStaffPage> {
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  void _refreshAppointments() {
    setState(() {
      _isLoading = true; // Set loading indicator to true while fetching data
    });
    fetchAppointments(); // Fetch appointments again
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

  Widget _buildAppointmentItem(int index, Map<String, dynamic> appointment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UpdateAppointmentPage(appointmentId: appointment['id']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12),
                Text(
                  "${index + 1}. ${appointment['appointment_type']}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 12),
                Divider(), // Added a divider line
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
                Divider(), // Added a divider line
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
                Divider(), // Added a divider line
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
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateAppointment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    // Add your update appointment logic here
    // For demonstration, I'm simulating an update by just waiting for 2 seconds
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> updateAppointmentAndNavigate() async {
    await updateAppointment();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AppointmentStatusStaffPage()),
    );
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
              : ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentItem(index, appointments[index]);
                  },
                ),
    );
  }
}
