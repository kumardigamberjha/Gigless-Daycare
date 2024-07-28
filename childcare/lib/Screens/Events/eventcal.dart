import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen(),
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

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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

// void _fetchEvents() {
//     // Here you can fetch events from your database or any other source
//     // For demonstration purposes, I'm just adding some dummy events
//     _events = {
//       DateTime.utc(2024, 3, 10): ['Event 1'],
//       DateTime.utc(2024, 3, 15): ['Event 2', 'Event 3'],
//       DateTime.utc(2024, 3, 20): ['Event 4'],
//     };
//   }

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
          "Event Calendar",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 4,
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
                if (_events[selectedDay] == null) {
                  _openForm(selectedDay);
                }
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _editEvent(_selectedDay!, index);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteEvent(_selectedDay!, index);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _openForm(_selectedDay!);
                          },
                          child: Text('Create Event'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  void _openForm(DateTime selectedDay) async {
    String eventName = '';

    // Open the form to create a new event
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Form to create event on ${DateFormat('MMMM dd, yyyy').format(selectedDay)}'),
              TextField(
                onChanged: (value) {
                  eventName = value;
                },
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Create event data
                final eventData = {
                  'name': eventName,
                  'date': DateFormat('yyyy-MM-dd').format(selectedDay),
                };

                // Send HTTP POST request to backend to create event
                final response = await http.post(
                  Uri.parse(
                      'https://child.codingindia.co.in/CalendarEvent/api/create-event/'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(eventData),
                );

                if (response.statusCode == 201) {
                  // Event created successfully
                  print('Event created successfully');
                  // Refresh events after adding new event
                  setState(() {
                    _fetchEvents();
                  });
                } else {
                  // Error occurred
                  print('Failed to create event. Error: ${response.body}');
                }
              },
              child: Text('Create'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editEvent(DateTime selectedDay, int index) async {
    final Map<String, dynamic> event = _events[selectedDay]![index];
    String editedEventName = event['name'];
    int eventId = event['id'];

    // Open the dialog to edit the event
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _controller =
            TextEditingController(text: editedEventName);

        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit event "${event['name']}"'),
              TextField(
                controller: _controller,
                onChanged: (value) {
                  editedEventName = value;
                },
                decoration: InputDecoration(labelText: 'New Event Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Send HTTP POST request to backend to edit event
                try {
                  final response = await http.post(
                    Uri.parse(
                        'https://child.codingindia.co.in/CalendarEvent/edit-event/'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'id': eventId, // Pass the event ID
                      'name': editedEventName, // Pass the edited event name
                    }),
                  );

                  if (response.statusCode == 200) {
                    // Event edited successfully
                    print('Event edited successfully');
                    // Refresh events after editing
                    setState(() {
                      _fetchEvents();
                    });
                  } else {
                    // Error occurred
                    print('Failed to edit event. Error: ${response.body}');
                  }
                } catch (error) {
                  print('Failed to connect to the server: $error');
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(DateTime selectedDay, int index) async {
    final Map<String, dynamic> event = _events[selectedDay]![index];
    int eventId = event['id'];

    // Open the dialog to confirm event deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();

                // Send HTTP DELETE request to backend to delete event
                try {
                  final response = await http.delete(
                    Uri.parse(
                        'https://child.codingindia.co.in/CalendarEvent/DeleteEvent/$eventId/'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                  );

                  if (response.statusCode == 200) {
                    // Event deleted successfully
                    print('Event deleted successfully');
                    // Refresh events after deletion
                    setState(() {
                      _fetchEvents();
                    });
                  } else {
                    // Error occurred
                    print('Failed to delete event. Error: ${response.body}');
                  }
                } catch (error) {
                  print('Failed to connect to the server: $error');
                }
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
