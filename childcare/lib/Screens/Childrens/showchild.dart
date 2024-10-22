import 'package:childcare/Screens/Childrens/child_record.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ShowChildDetail extends StatefulWidget {
  final int childId;

  ShowChildDetail({required this.childId});

  @override
  _ShowChildDetailState createState() => _ShowChildDetailState();
}

class _ShowChildDetailState extends State<ShowChildDetail> {
  Map<String, dynamic> childData = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://child.codingindia.co.in/student/children/${widget.childId}/",
        ),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic>) {
          setState(() {
            childData = responseData;
          });
        } else if (responseData is List<dynamic> && responseData.isNotEmpty) {
          print('Received a List, but expected a Map. Data: $responseData');
        } else {
          print('Unexpected response format. Data: $responseData');
        }
      } else {
        print('Failed to load child details. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> deleteChild(BuildContext context) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://child.codingindia.co.in/student/delete-child-data/${widget.childId}/'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Child deleted successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChildRecordsPage()), // Navigate to ParentChildPage
        ); // Go back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete child.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Child"),
          content: Text("Are you sure you want to delete this child's data?"),
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
                deleteChild(context); // Call the delete function
              },
            ),
          ],
        );
      },
    );
  }

  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  void launchPhoneDialer(String phoneNumber) async {
    final Uri _phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(_phoneLaunchUri.toString())) {
      await launch(_phoneLaunchUri.toString());
    } else {
      throw 'Could not launch ${_phoneLaunchUri.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Child Detail',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF0891B2),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundColor: Color(0xFF0891B2),
                child: CircleAvatar(
                    radius: 75,
                    backgroundImage: childData['image'] != null
                        ? NetworkImage(childData['image'])
                        : AssetImage('assets/images/placeholder_image.png')
                            as ImageProvider),
              ),
              SizedBox(height: 20),
              Text(
                "#${childData['unique_id']}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0891B2),
                ),
              ),
              SizedBox(height: 20),
              buildInfoCard(
                'Name',
                '${childData['first_name'] ?? ''} ${childData['last_name'] ?? ''}',
                Icons.person,
              ),
              buildInfoCard(
                'Date of Birth',
                '${childData['date_of_birth'] ?? ''}',
                Icons.cake,
              ),
              buildInfoCard(
                'Gender',
                '${childData['gender'] ?? ''}',
                Icons.person,
              ),
              buildInfoCard(
                'Age',
                '${childData['date_of_birth'] != null ? calculateAge(DateTime.parse(childData['date_of_birth'])) : ''} years',
                Icons.access_time,
              ),
              SizedBox(height: 20),
              buildInfoCard(
                'Emergency Contact',
                'Name: ${childData['emergency_contact_name'] ?? ''}\nNumber: ${childData['emergency_contact_number'] ?? ''}',
                Icons.phone,
                button: ElevatedButton(
                  onPressed: () async {
                    final Uri url = Uri(
                        scheme: "tel",
                        path: "${childData['emergency_contact_number']}");

                    if (await canLaunchUrl(url)) {}
                    await launchUrl(url);
                  },
                  child: Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFF0891B2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildInfoCard(
                'Medical History',
                childData['medical_history'] ?? '',
                Icons.local_hospital,
              ),
              SizedBox(height: 20),
              buildInfoCard(
                'Address',
                '${childData['address'] ?? ''}\n${childData['city'] ?? ''}, ${childData['state'] ?? ''}, ${childData['zip_code'] ?? ''}',
                Icons.location_on,
              ),
              SizedBox(height: 20),
              buildInfoCard(
                'Parents',
                'Parent 1: ${childData['parent1_name'] ?? ''} - ${childData['parent1_contact_number'] ?? ''}\nParent 2: ${childData['parent2_name'] ?? ''} - ${childData['parent2_contact_number'] ?? ''}',
                Icons.people,
              ),
              SizedBox(height: 20),
              // Delete Button
              ElevatedButton(
                onPressed: () {
                  _confirmDelete(context); // Show confirmation dialog
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white // Red color for delete action
                    ),
                child: Text("Delete Child"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(String title, String subtitle, IconData icon,
      {Widget? button}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Color(0xFF0891B2),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0891B2),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          if (button != null) button,
        ],
      ),
    );
  }
}
