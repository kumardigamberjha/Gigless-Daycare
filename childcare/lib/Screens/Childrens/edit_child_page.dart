import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditChildPage extends StatefulWidget {
  final int childId;

  EditChildPage({required this.childId});

  @override
  _EditChildPageState createState() => _EditChildPageState();
}

class _EditChildPageState extends State<EditChildPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _childDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildDetails();
    _fetchRooms();
  }

  List<dynamic> rooms = [];
  int? selectedRoom;

  Future<void> _fetchChildDetails() async {
    final response = await http.get(Uri.parse(
        'https://child.codingindia.co.in/student/children/${widget.childId}/'));

    if (response.statusCode == 200) {
      setState(() {
        _childDetails = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      print('Failed to load child details. Error: ${response.statusCode}');
    }
  }

  Future<void> _fetchRooms() async {
    final response = await http
        .get(Uri.parse('https://child.codingindia.co.in/student/rooms/'));
    if (response.statusCode == 200) {
      setState(() {
        rooms = json.decode(response.body);
        if (rooms.isNotEmpty && selectedRoom == null) {
          selectedRoom = rooms[0]
              ['id']; // Set initial value for the dropdown if not already set
        }
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<void> _updateChildDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.put(
        Uri.parse(
            'https://child.codingindia.co.in/student/children/${widget.childId}/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_childDetails),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
      } else {
        print('Failed to update child details. Error: ${response.statusCode}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Child Details'),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextFormField('First Name', 'first_name'),
                    _buildTextFormField('Last Name', 'last_name'),
                    _buildTextFormField('Unique ID', 'unique_id'),
                    _buildTextFormField('Date of Birth', 'date_of_birth'),
                    _buildTextFormField('Gender', 'gender'),
                    _buildTextFormField('Blood Group', 'blood_group'),
                    _buildTextFormField('Medical History', 'medical_history'),
                    _buildTextFormField(
                        'Emergency Contact Name', 'emergency_contact_name'),
                    _buildTextFormField(
                        'Emergency Contact Number', 'emergency_contact_number'),
                    _buildTextFormField('Child Fees', 'child_fees',
                        isNumeric: true),
                    _buildTextFormField('Address', 'address'),
                    _buildTextFormField('City', 'city'),
                    _buildTextFormField('State', 'state'),
                    _buildTextFormField('Zip Code', 'zip_code'),
                    _buildDropdownFormField('Room', 'room'),
                    _buildTextFormField('Parent 1 Name', 'parent1_name'),
                    _buildTextFormField(
                        'Parent 1 Contact Number', 'parent1_contact_number'),
                    _buildTextFormField('Parent 2 Name', 'parent2_name'),
                    _buildTextFormField(
                        'Parent 2 Contact Number', 'parent2_contact_number'),
                    _buildTextFormField('Is Active', 'is_active'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateChildDetails,
                      child: Text('Update'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF0891B2),
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField(String label, String key,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: _childDetails[key]?.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        onSaved: (value) {
          if (isNumeric) {
            _childDetails[key] = double.parse(value!);
          } else {
            _childDetails[key] = value!;
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the $label';
          }
          return null;
        },
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildDropdownFormField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        value: selectedRoom,
        onChanged: (int? value) {
          setState(() {
            selectedRoom = value;
          });
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: rooms.map<DropdownMenuItem<int>>((room) {
          return DropdownMenuItem<int>(
            value: room['id'],
            child: Text(room['name']),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }
}
