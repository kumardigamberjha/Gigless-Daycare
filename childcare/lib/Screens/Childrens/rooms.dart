import 'package:childcare/Screens/RoomMedia/uploadRoomMedia.dart';
import 'package:childcare/Screens/RoomMedia/viewRoomMedia.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  List<dynamic> _rooms = [];
  int _noOfRooms = 0;
  bool isSuperuser = false;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    bool? superuserStatus = prefs.getBool('is_superuser');

    // Update isSuperuser state
    setState(() {
      isSuperuser = superuserStatus ?? false; // Default to false if null
    });

    final response = await http
        .get(Uri.parse('https://daycare.codingindia.co.in/student/rooms/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _rooms = data['data']; // List of rooms
        _noOfRooms = data['no_of_rooms']; // Number of rooms
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.post(
        Uri.parse('https://daycare.codingindia.co.in/student/rooms/create/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': _name}),
      );
      if (response.statusCode == 201) {
        _fetchRooms();
      }
    }
  }

  Future<void> _updateRoom(int id) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.put(
        Uri.parse(
            'https://daycare.codingindia.co.in/student/rooms/update/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': _name}),
      );
      if (response.statusCode == 200) {
        _fetchRooms();
      }
    }
  }

  Future<void> _deleteRoom(int id) async {
    final response = await http.delete(
      Uri.parse('https://daycare.codingindia.co.in/student/rooms/delete/$id/'),
    );
    if (response.statusCode == 204) {
      _fetchRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rooms",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Room Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a room name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createRoom,
                    child: Text('Create Room'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return ListTile(
                    title: Text(room['name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (isSuperuser)
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _name = room['name'];
                              _updateRoom(room['id']);
                            },
                          ),
                        if (isSuperuser)
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteRoom(room['id']);
                            },
                          ),
                        // New icon button to view media files
                        IconButton(
                          icon: Icon(Icons.visibility),
                          onPressed: () {
                            // Navigate to ViewMediaPage and pass roomId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewMediaPage(
                                  roomId: room['id'],
                                ),
                              ),
                            );
                          },
                        ),
                        // Add Media button
                        IconButton(
                          icon: Icon(Icons.add_a_photo),
                          onPressed: () {
                            // Navigate to UploadMediaPage and pass roomId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadMediaPage(
                                  roomId: room['id'],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
