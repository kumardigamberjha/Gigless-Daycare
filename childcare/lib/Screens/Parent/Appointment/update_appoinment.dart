import 'package:childcare/Screens/Parent/Appointment/appointmentStatus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define status options as constants
enum AppointmentStatus { pending, confirmed, cancelled }

class UpdateAppointmentPage extends StatefulWidget {
  final int appointmentId;

  UpdateAppointmentPage({required this.appointmentId});

  @override
  _UpdateAppointmentPageState createState() => _UpdateAppointmentPageState();
}

class _UpdateAppointmentPageState extends State<UpdateAppointmentPage> {
  AppointmentStatus _status =
      AppointmentStatus.pending; // Set initial value for _status
  DateTime _scheduledTime = DateTime.now();
  bool _isLoading = false;

  Future<void> updateAppointment() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    try {
      final response = await http.put(
        Uri.parse(
            'https://child.codingindia.co.in/Parent/updateappointment/${widget.appointmentId}/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        body: {
          'status':
              _status.toString().split('.').last, // Convert enum to string
          'scheduled_time':
              DateFormat('yyyy-MM-dd HH:mm:ss').format(_scheduledTime),
        },
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment updated successfully'),
          backgroundColor: Colors.green,
        ));
        // Navigate to AppointmentStatusStaffPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppointmentStatusStaffPage()),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update appointment'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Handle network error
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network error. Please try again later.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Appointment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.0),
                  DropdownButtonFormField(
                    value: _status
                        .toString()
                        .split('.')
                        .last, // Convert enum to string
                    onChanged: (value) {
                      setState(() {
                        _status = AppointmentStatus.values.firstWhere(
                            (e) => e.toString().split('.').last == value);
                      });
                    },
                    items: AppointmentStatus.values.map((status) {
                      return DropdownMenuItem(
                          child: Text(
                              status.toString().split('.').last.capitalize()),
                          value: status.toString().split('.').last);
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  DateTimePicker(
                    initialValue: _scheduledTime,
                    onChanged: (value) {
                      setState(() {
                        _scheduledTime = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Scheduled Time',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      updateAppointment();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: Text(
                      'Update Appointment',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  final DateTime initialValue;
  final ValueChanged<DateTime> onChanged;
  final InputDecoration decoration;

  DateTimePicker(
      {required this.initialValue,
      required this.onChanged,
      required this.decoration});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
          text: DateFormat('yyyy-MM-dd HH:mm').format(initialValue)),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialValue,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (selectedTime != null) {
            onChanged(DateTime(picked.year, picked.month, picked.day,
                selectedTime.hour, selectedTime.minute));
          }
        }
      },
      decoration: decoration,
    );
  }
}

// Extension method to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
