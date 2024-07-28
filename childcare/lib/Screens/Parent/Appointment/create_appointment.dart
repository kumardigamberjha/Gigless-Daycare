import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateParentAppointmentView extends StatefulWidget {
  @override
  _CreateParentAppointmentViewState createState() =>
      _CreateParentAppointmentViewState();
}

class _CreateParentAppointmentViewState
    extends State<CreateParentAppointmentView> {
  final TextEditingController _appointmentTypeController =
      TextEditingController();
  final TextEditingController _scheduledTimeController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _status = 'Pending';

  Future<void> _submitForm() async {
    final appointmentType = _appointmentTypeController.text;
    final scheduledTime = _scheduledTimeController.text;
    final notes = _notesController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await http.post(
      Uri.parse('https://child.codingindia.co.in/Parent/createappointments/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'appointment_type': appointmentType,
        'scheduled_time': scheduledTime,
        'notes': notes,
        'status': _status,
      },
    );

    if (response.statusCode == 201) {
      print('Appointment created successfully');
    } else {
      print('Failed to create appointment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Request Appointment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _appointmentTypeController,
              decoration: InputDecoration(
                labelText: 'Appointment Title',
                border: OutlineInputBorder(), // Add border to text field
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _scheduledTimeController,
              decoration: InputDecoration(
                labelText: 'Scheduled Time',
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                // Show date picker
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  // Show time picker
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    final DateTime combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    setState(() {
                      _scheduledTimeController.text =
                          combinedDateTime.toString();
                    });
                  }
                }
              },
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _submitForm();
              },
              child: Text('Create Appointment'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF0891B2), // Text color
                elevation: 3, // Elevation
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _appointmentTypeController.dispose();
    _scheduledTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: CreateParentAppointmentView(),
  ));
}
