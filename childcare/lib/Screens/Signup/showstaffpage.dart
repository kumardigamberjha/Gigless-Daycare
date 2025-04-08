import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<MapEntry<String, List<dynamic>>> users = [];
  bool isSuperuser = false;

  Future<void> fetchUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    bool? superuserStatus = prefs.getBool('is_superuser');
    setState(() {
      isSuperuser = superuserStatus ?? false; // Default to false if null
    });

    final response = await http.get(
      Uri.parse('https://daycare.codingindia.co.in/userslist/'),
      headers: {
        'Authorization': 'Bearer $accessToken'
      }, // Include token if required
    );

    if (response.statusCode == 200) {
      List<dynamic> fetchedData = json.decode(response.body);

      // Group users by room name
      Map<String, List<dynamic>> groupedUsers = {};
      for (var roomData in fetchedData) {
        String roomName =
            roomData['room_name'] ?? "General"; // Handle null room_name
        List<dynamic> roomUsers = roomData['users'];
        groupedUsers[roomName] = roomUsers;
      }

      setState(() {
        users =
            groupedUsers.entries.toList(); // Convert to list of key-value pairs
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Staff List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          MapEntry<String, List<dynamic>> roomGroup = users[index];
          String roomName = roomGroup.key;
          List<dynamic> roomUsers = roomGroup.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  roomName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: roomUsers.length,
                itemBuilder: (context, userIndex) {
                  var user = roomUsers[userIndex];
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(user: user),
                        ),
                      );
                      if (result == true) {
                        fetchUsers(); // Refresh the list after deletion or edit
                      }
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.all(8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSuperuser)
                              Text(
                                user['username']?.toString() ??
                                    "N/A", // Handle null username
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            SizedBox(height: 8),
                            Text(
                              'ID: ${user['unique_id']?.toString() ?? "N/A"}', // Handle null unique_id
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class UserDetailsPage extends StatefulWidget {
  final dynamic user;

  UserDetailsPage({required this.user});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late TextEditingController _usertypeController;
  String? _selectedRoomId;
  List<dynamic> _rooms = [];
  bool _isLoadingRooms = true;

  @override
  void initState() {
    super.initState();
    _usertypeController = TextEditingController(text: widget.user['usertype']);
    _selectedRoomId =
        widget.user['room']?.toString(); // Set initial room selection
    fetchRooms(); // Fetch the list of rooms
  }

  Future<void> fetchRooms() async {
    final response = await http
        .get(Uri.parse('https://daycare.codingindia.co.in/student/rooms/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _rooms = data['data']; // Extract the list of rooms
        _isLoadingRooms = false; // Mark loading as complete
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<void> updateUser(BuildContext context) async {
    final response = await http.put(
      Uri.parse(
          'https://daycare.codingindia.co.in/edit-user/${widget.user['id']}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usertype': _usertypeController.text,
        'room': _selectedRoomId != null ? int.tryParse(_selectedRoomId!) : null,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User updated successfully!'),
      ));
      Navigator.pop(context, true); // Return true to refresh the list
    } else {
      throw Exception('Failed to update user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Staff's Detail",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Username',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.user['username']?.toString() ?? "N/A"),
            ),
            Divider(),
            ListTile(
              title: Text(
                'User Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextField(
                controller: _usertypeController,
                decoration: InputDecoration(hintText: 'Enter user type'),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Room',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: _isLoadingRooms
                  ? CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: _selectedRoomId,
                      hint: Text('Select a room'),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRoomId =
                              newValue; // Update the selected room
                        });
                      },
                      items:
                          _rooms.map<DropdownMenuItem<String>>((dynamic room) {
                        return DropdownMenuItem<String>(
                          value: room['id'].toString(),
                          child: Text(room['name']),
                        );
                      }).toList(),
                    ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Mobile Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.user['mobile_number']?.toString() ?? "N/A"),
            ),
            Divider(),
            ListTile(
              title: Text(
                'ID',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.user['unique_id']?.toString() ?? "N/A"),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.user['email']?.toString() ?? "N/A"),
            ),
            Divider(),
            // Edit Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  updateUser(context); // Call the update function
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Green color for edit action
                  foregroundColor: Colors.white,
                ),
                child: Text("Save Changes"),
              ),
            ),
            // Delete Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _confirmDelete(context); // Show confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red color for delete action
                  foregroundColor: Colors.white,
                ),
                child: Text("Delete User"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete User"),
          content: Text("Are you sure you want to delete this user?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                deleteUser(context); // Call the deleteUser function
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUser(BuildContext context) async {
    final response = await http.delete(
      Uri.parse(
          'https://daycare.codingindia.co.in/deleteusersrecord/${widget.user['id']}/'),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User deleted successfully!'),
      ));
      Navigator.pop(context, true); // Return true to refresh the list
    } else {
      throw Exception('Failed to delete user');
    }
  }
}
