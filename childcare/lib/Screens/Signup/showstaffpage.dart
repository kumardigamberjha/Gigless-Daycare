import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> users = [];

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('https://child.codingindia.co.in/userslist/'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
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
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsPage(user: users[index]),
                ),
              );
              if (result == true) {
                fetchUsers(); // Refresh the list after deletion
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
                    Text(
                      users[index]['username'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ID: ${users[index]['unique_id']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Add more fields as needed
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final dynamic user;

  UserDetailsPage({required this.user});

  Future<void> deleteUser(BuildContext context) async {
    final response = await http.delete(
      Uri.parse(
          'https://child.codingindia.co.in/deleteusersrecord/${user['id']}/'),
    );

    if (response.statusCode == 200) {
      // If the server returns 204 No Content, navigate back to the user list
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User deleted successfully!'),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserListPage()), // Navigate to ParentChildPage
      );
    } else {
      throw Exception('Failed to delete user');
    }
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user['username']),
            ),
            Divider(),
            ListTile(
              title: Text(
                'User Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user['usertype']),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Mobile Number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user['mobile_number']),
            ),
            Divider(),
            ListTile(
              title: Text(
                'ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user['unique_id']),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user['email']),
            ),
            Divider(),

            // Add more ListTile widgets for additional user details

            // Delete Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _confirmDelete(context); // Show confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red color for delete action
                    foregroundColor: Colors.white),
                child: Text("Delete User"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
