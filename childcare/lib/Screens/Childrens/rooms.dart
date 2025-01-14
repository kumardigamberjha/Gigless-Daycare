import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:childcare/Screens/Childrens/room_children.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name = '';
  List<dynamic> _rooms = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://child.codingindia.co.in/student/rooms/'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          // Extract the list of rooms from the 'data' key
          setState(() => _rooms = data['data']);
        } else {
          _showErrorDialog("Unexpected response format. Data: $data");
        }
      } else {
        _showErrorDialog("Failed to load rooms. Status Code: ${response.statusCode}");
      }
    } catch (error) {
      _showErrorDialog("An error occurred: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      try {
        final response = await http.post(
          Uri.parse('https://child.codingindia.co.in/student/rooms/create/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': _name}),
        );
        if (response.statusCode == 201) {
          _fetchRooms();
        } else {
          _showErrorDialog("Failed to create room.");
        }
      } catch (error) {
        _showErrorDialog("An error occurred: $error");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateRoom(int id) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      try {
        final response = await http.put(
          Uri.parse('https://child.codingindia.co.in/student/rooms/update/$id/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'name': _name}),
        );
        if (response.statusCode == 200) {
          _fetchRooms();
        } else {
          _showErrorDialog("Failed to update room.");
        }
      } catch (error) {
        _showErrorDialog("An error occurred: $error");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRoom(int id) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('https://child.codingindia.co.in/student/rooms/delete/$id/'),
      );
      if (response.statusCode == 204) {
        _fetchRooms();
      } else {
        _showErrorDialog("Failed to delete room.");
      }
    } catch (error) {
      _showErrorDialog("An error occurred: $error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(int id, String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Room'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              initialValue: currentName,
              decoration: InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: Icon(Icons.meeting_room),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a room name';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                _updateRoom(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rooms"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 10.0,
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
                    decoration: InputDecoration(
                      labelText: 'Room Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a room name';
                      }
                      return null;
                    },
                    onSaved: (value) => _name = value!,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createRoom,
                    child: Text('Create Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 14, 104, 194),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _rooms.length,
                      itemBuilder: (context, index) {
                        final room = _rooms[index];
                        return Card(
                          elevation: 5.0,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          child: ListTile(
                            title: Text(room['name'],
                                style: TextStyle(color: Colors.blue[900])),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon:
                                      Icon(Icons.edit, color: Colors.blue[600]),
                                  onPressed: () => _showUpdateDialog(
                                      room['id'], room['name']),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red[600]),
                                  onPressed: () => _deleteRoom(room['id']),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward,
                                      color: Colors.blue[600]),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChildrenPage(roomId: room['id']),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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
