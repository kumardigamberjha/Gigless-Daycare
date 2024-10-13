import 'dart:convert';
import 'package:childcare/Screens/Parent/ChildInformation/childinfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Childrens/showchild.dart';

class ParentListPage extends StatefulWidget {
  @override
  _ParentListPageState createState() => _ParentListPageState();
}

class _ParentListPageState extends State<ParentListPage> {
  List<dynamic> users = [];

  Future<void> fetchUsers() async {
    final response = await http
        .get(Uri.parse('https://child.codingindia.co.in/ParentList/'));
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
          'Parent List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ParentDetailPage(parentId: users[index]['id']),
                ),
              );
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

class ParentDetailPage extends StatefulWidget {
  final int parentId;

  ParentDetailPage({required this.parentId});

  @override
  _ParentDetailPageState createState() => _ParentDetailPageState();
}

class _ParentDetailPageState extends State<ParentDetailPage> {
  Map<String, dynamic> parentData = {};
  List<dynamic> children = [];

  @override
  void initState() {
    super.initState();
    fetchParentDetails();
  }

  Future<void> fetchParentDetails() async {
    final response = await http.get(Uri.parse(
        'https://child.codingindia.co.in/ParentListDetail/${widget.parentId}/'));
    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        parentData = data['user'];
        children = data['children'];
      });
    } else {
      throw Exception('Failed to load parent details');
    }
  }

  Future<void> deleteParent(BuildContext context) async {
    final response = await http.delete(
      Uri.parse(
          'https://child.codingindia.co.in/deleteusersrecord/${widget.parentId}/'),
    );

    if (response.statusCode == 204) {
      // If the server returns 204 No Content, navigate back to the parent list
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Parent deleted successfully!'),
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ParentListPage()), // Navigate to ParentChildPage
      ); // Return true to indicate the parent was deleted
    } else {
      throw Exception('Failed to delete parent');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Parent"),
          content: Text("Are you sure you want to delete this parent?"),
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
                deleteParent(context); // Call the deleteParent function
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
          'Parent Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parent Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ListTile(
                title: Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(parentData['username'] ?? ''),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'User Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(parentData['usertype'] ?? ''),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Mobile Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(parentData['mobile_number'] ?? ''),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'ID',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(parentData['unique_id'] ?? ''),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(parentData['email'] ?? ''),
              ),
              Divider(),
              SizedBox(height: 16),
              Text(
                'Children',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                child: Column(
                  children: children.map((child) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ShowChildDetail(childId: child['id']),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              '${child['first_name']} ${child['last_name']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(child['date_of_birth']),
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
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
                      backgroundColor:
                          Colors.red, // Red color for delete action
                      foregroundColor: Colors.white),
                  child: Text("Delete Parent"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ParentListPage(),
  ));
}
