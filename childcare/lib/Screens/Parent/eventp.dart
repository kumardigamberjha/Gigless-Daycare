import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreenForParent(),
    );
  }
}

class DateOnly {
  final int year;
  final int month;
  final int day;

  DateOnly(this.year, this.month, this.day);

  @override
  String toString() {
    return '$year-$month-$day';
  }
}

class CalendarScreenForParent extends StatefulWidget {
  @override
  _CalendarScreenForParentState createState() =>
      _CalendarScreenForParentState();
}

class _CalendarScreenForParentState extends State<CalendarScreenForParent> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    // Fetch and parse event data
    _fetchEvents();
  }

  void _fetchEvents() async {
    // Make an HTTP GET request to your backend API endpoint
    var response = await http.get(
        Uri.parse('https://child.codingindia.co.in/CalendarEvent/api/events/'));

    // Check if the request was successful (HTTP 200 OK)
    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> eventsJson = json.decode(response.body);

      // Initialize _events map
      Map<DateTime, List<Map<String, dynamic>>> events = {};

      // Loop through each event JSON object and add it to the _events map
      for (var event in eventsJson) {
        // Extract the date string from the JSON response
        String dateString = event['date'];

        // Parse the date string into a DateTime object in UTC format
        DateTime date =
            DateFormat("yyyy-MM-dd").parse(dateString, true).toLocal().toUtc();

        // Create a new DateTime object with only the date part (without time)
        DateTime dateWithoutTime =
            DateTime.utc(date.year, date.month, date.day);

        // Check if the date already exists in the map, if not, initialize an empty list
        events[dateWithoutTime] ??= [];

        // Add the event details to the list corresponding to the date
        events[dateWithoutTime]!.add(
            {'id': event['id'], 'name': event['name'], 'date': event['date']});
      }

      // Update the _events variable with the fetched events
      setState(() {
        _events = events;
      });
      print(_events);
    } else {
      // If the request was not successful, print the error message
      print('Failed to fetch events: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Calendar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2021, 01, 01),
              lastDay: DateTime.utc(2032, 12, 31),
              focusedDay: _focusedDay,
              daysOfWeekVisible: true,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return _events[day] ?? [];
              },
            ),
            SizedBox(height: 16),
            if (_selectedDay != null && _events[_selectedDay!] != null)
              Container(
                height: 200, // Set the maximum height for the event container
                color: Colors.grey[200],
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Events on ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _events[_selectedDay!]!.length,
                        itemBuilder: (context, index) {
                          final event = _events[_selectedDay!]![index];
                          return ListTile(
                            title: Text(event['name']),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
