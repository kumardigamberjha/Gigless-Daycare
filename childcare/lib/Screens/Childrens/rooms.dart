import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  List<dynamic> _rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final response = await http
        .get(Uri.parse('https://child.codingindia.co.in/student/rooms/'));
    if (response.statusCode == 200) {
      setState(() {
        _rooms = json.decode(response.body);
      });
    }
  }

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.post(
        Uri.parse('https://child.codingindia.co.in/student/rooms/create/'),
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
        Uri.parse('https://child.codingindia.co.in/student/rooms/update/$id/'),
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
      Uri.parse('https://child.codingindia.co.in/student/rooms/delete/$id/'),
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
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _name = room['name'];
                            _updateRoom(room['id']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteRoom(room['id']);
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