import 'package:childcare/Screens/Childrens/showchild.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: ChildrenPage(roomId: 1),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        color: Colors.blue[800],
        elevation: 0,
        // textTheme: TextTheme(
        //   headline6: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        // ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.blue[600],
      ),
      cardTheme: CardTheme(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue[700],
        textTheme: ButtonTextTheme.primary,
      ),
    ),
  ));
}

class ChildrenPage extends StatefulWidget {
  final int roomId;

  ChildrenPage({required this.roomId});

  @override
  _ChildrenPageState createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  List<dynamic> _children = [];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    final response = await http.get(
      Uri.parse(
          'https://child.codingindia.co.in/student/rooms/children/${widget.roomId}'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      try {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse != null && jsonResponse['data'] != null) {
          setState(() {
            _children = jsonResponse['data'];
          });
        } else {
          throw FormatException('Invalid or missing "data" key in response');
        }
      } catch (e) {
        print('Failed to parse response: $e');
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Records'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: child['image'] != null
                      ? NetworkImage(
                          "https://child.codingindia.co.in/media/${child['image']}")
                      : AssetImage('assets/images/placeholder_image.png')
                          as ImageProvider,
                ),
                title: Text(
                  '${child['first_name']} ${child['last_name']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ID: ${child['unique_id']}'),
                    Text('Parent Number: ${child['parent1_contact_number']}'),
                    // Text('ID: ${child['parent1_contact_number']}'),

                    Text('Gender: ${child['gender']}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.visibility, color: Colors.blue[800]),
                  onPressed: () => viewChildDetail(child['id']),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void viewChildDetail(int childId) {
    // Navigation logic to view child details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowChildDetail(childId: childId),
      ),
    );
  }
}
