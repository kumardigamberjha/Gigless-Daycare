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
          "http://192.168.224.81:8000/student/children/${widget.childId}/",
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
        backgroundColor: Color(0xFF007ACC),
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
                backgroundColor: Color(0xFF007ACC),
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
                  color: Color(0xFF007ACC),
                ),
              ),
              SizedBox(height: 20),
              buildInfoTile(
                'Name',
                '${childData['first_name'] ?? ''} ${childData['last_name'] ?? ''}',
                Icons.person,
                
              ),
              buildInfoTile(
                'Date of Birth',
                '${childData['date_of_birth'] ?? ''}',
                Icons.cake,
              ),
              buildInfoTile(
                'Gender',
                '${childData['gender'] ?? ''}',
                Icons.person,
              ),
              buildInfoTile(
                'Age',
                '${childData['date_of_birth'] != null ? calculateAge(DateTime.parse(childData['date_of_birth'])) : ''} years',
                Icons.access_time,
              ),
              SizedBox(height: 20),
              buildInfoTile(
                'Emergency Contact',
                'Name: ${childData['emergency_contact_name'] ?? ''}\nNumber: ${childData['emergency_contact_number'] ?? ''}',
                Icons.phone,
                button: ElevatedButton(
                  onPressed: () async {

                    final Uri url = Uri(
                      scheme: "tel",
                      path: "${childData['emergency_contact_number']}"
                    );

                    if (await canLaunchUrl(url)){
                      
                    }
                      await launchUrl(url);

                  },
                  child: Text('Call Now'),
                ),
              ),
              SizedBox(height: 20),
              buildInfoTile(
                'Medical History',
                childData['medical_history'] ?? '',
                Icons.local_hospital,
              ),
              SizedBox(height: 20),
              buildInfoTile(
                'Address',
                '${childData['address'] ?? ''}\n${childData['city'] ?? ''}, ${childData['state'] ?? ''}, ${childData['zip_code'] ?? ''}',
                Icons.location_on,
              ),
              SizedBox(height: 20),
              buildInfoTile(
                'Parents',
                'Parent 1: ${childData['parent1_name'] ?? ''} - ${childData['parent1_contact_number'] ?? ''}\nParent 2: ${childData['parent2_name'] ?? ''} - ${childData['parent2_contact_number'] ?? ''}',
                Icons.people,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoTile(String title, String subtitle, IconData icon,
      {Widget? button}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007ACC),
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              icon,
              color: Color(0xFF007ACC),
              size: 20,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
        trailing: button,
      ),
    );
  }
}
