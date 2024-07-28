import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/Fees/fee_form.dart';
import 'package:childcare/Screens/Fees/GetFeesmonthly.dart';

class ChildListFeesPage extends StatefulWidget {
  @override
  _ChildListFeesPageState createState() => _ChildListFeesPageState();
}

class _ChildListFeesPageState extends State<ChildListFeesPage> {
  List<Map<String, dynamic>> childRecords = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse("https://child.codingindia.co.in/student/child-list/"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        childRecords = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load child records. Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Child Fees',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: childRecords.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: childRecords.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {},
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.white],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black,
                                backgroundImage: NetworkImage(
                                  childRecords[index]['image'] ??
                                      'https://via.placeholder.com/150',
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${childRecords[index]['first_name'] ?? ''} ${childRecords[index]['last_name'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Age: ${calculateAge(childRecords[index]['date_of_birth'] ?? '')}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.attach_money),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FeeFormPage(
                                            childRecords[index]['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Add Fees',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.money),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FeeListPage(
                                            childId: childRecords[index]['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Get Fees',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String calculateAge(String? dateOfBirth) {
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      DateTime birthDate = DateTime.parse(dateOfBirth);
      DateTime currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    }
    return '';
  }
}
