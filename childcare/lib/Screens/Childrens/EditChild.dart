import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:childcare/Screens/Childrens/child_record.dart';
import 'package:childcare/Screens/Homescreen/homescreen.dart';
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
  Map<String, dynamic> childData = {};
  bool isLoading = true;

  // TextEditingControllers for all fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController uniqueIdController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController parent1NameController = TextEditingController();
  final TextEditingController parent1ContactController =
      TextEditingController();
  final TextEditingController parent2NameController = TextEditingController();
  final TextEditingController parent2ContactController =
      TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();

  String? isActive; // Dropdown for active status
  int? roomId; // Dropdown for room selection
  List<dynamic> rooms = [];
  Uint8List? _selectedImageBytes; // Holds the selected image bytes for web
  String? _imageName;

  @override
  void initState() {
    super.initState();
    fetchChildDetails();
    fetchRooms();
  }

  Future<void> fetchChildDetails() async {
    final response = await http.get(
      Uri.parse(
          'https://daycare.codingindia.co.in/student/children/${widget.childId}/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        childData = data;
        firstNameController.text = data['first_name'] ?? '';
        lastNameController.text = data['last_name'] ?? '';
        dateOfBirthController.text = data['date_of_birth'] ?? '';
        genderController.text = data['gender'] ?? '';
        bloodGroupController.text = data['blood_group'] ?? '';
        feesController.text = data['child_fees']?.toString() ?? '';
        addressController.text = data['address'] ?? '';
        uniqueIdController.text = data['unique_id'] ?? '';
        cityController.text = data['city'] ?? '';
        stateController.text = data['state'] ?? '';
        zipCodeController.text = data['zip_code'] ?? '';
        parent1NameController.text = data['parent1_name'] ?? '';
        parent1ContactController.text = data['parent1_contact_number'] ?? '';
        parent2NameController.text = data['parent2_name'] ?? '';
        parent2ContactController.text = data['parent2_contact_number'] ?? '';
        medicalHistoryController.text = data['medical_history'] ?? '';
        isActive = data['is_active'] == true ? 'True' : 'False';
        roomId = data['room'];
        isLoading = false;
      });
    } else {
      print('Failed to load child details: ${response.statusCode}');
    }
  }

  Future<void> fetchRooms() async {
    final response = await http.get(
      Uri.parse('https://daycare.codingindia.co.in/student/rooms/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        rooms = data['data'];
      });
    } else {
      print('Failed to load rooms: ${response.statusCode}');
    }
  }

  Future<void> pickImageWeb() async {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        setState(() {
          _selectedImageBytes = reader.result as Uint8List?;
          _imageName = file.name;
        });
      });
    });
  }

  Future<void> updateChildDetails() async {
    if (!_formKey.currentState!.validate()) return;

    final String apiUrl =
        'https://daycare.codingindia.co.in/student/children/${widget.childId}/';

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));

      // Add text fields
      request.fields.addAll({
        'id': '${widget.childId}',
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'date_of_birth': dateOfBirthController.text,
        'gender': genderController.text,
        'blood_group': bloodGroupController.text,
        'child_fees': feesController.text,
        'address': addressController.text,
        'unique_id': uniqueIdController.text,
        'city': cityController.text,
        'state': stateController.text,
        'zip_code': zipCodeController.text,
        'parent1_name': parent1NameController.text,
        'parent1_contact_number': parent1ContactController.text,
        'parent2_name': parent2NameController.text,
        'parent2_contact_number': parent2ContactController.text,
        'medical_history': medicalHistoryController.text,
        'is_active': isActive == 'True' ? 'True' : 'False',
        'room': roomId?.toString() ?? '',
      });

      // Add image file if selected
      if (_selectedImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _selectedImageBytes!,
          filename: _imageName,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Child updated successfully!')),
        );
        // Navigate back after successful update
        // Navigator.push(context, '/childRecordsPage');
        // Navigator.popAndPushNamed(context, '/childRecordsPage');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        print('Failed to update child: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update child.')),
        );
      }
    } catch (error) {
      print('Error updating child: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Child Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: dateOfBirthController,
                      decoration: InputDecoration(labelText: 'Date of Birth'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: genderController,
                      decoration: InputDecoration(labelText: 'Gender'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: bloodGroupController,
                      decoration: InputDecoration(labelText: 'Blood Group'),
                    ),
                    TextFormField(
                      controller: feesController,
                      decoration: InputDecoration(labelText: 'Fees'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(labelText: 'Address'),
                    ),
                    TextFormField(
                      controller: uniqueIdController,
                      decoration: InputDecoration(labelText: 'Unique ID'),
                    ),
                    TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(labelText: 'City'),
                    ),
                    TextFormField(
                      controller: stateController,
                      decoration: InputDecoration(labelText: 'State'),
                    ),
                    TextFormField(
                      controller: zipCodeController,
                      decoration: InputDecoration(labelText: 'Zip Code'),
                    ),
                    TextFormField(
                      controller: parent1NameController,
                      decoration: InputDecoration(labelText: 'Parent 1 Name'),
                    ),
                    TextFormField(
                      controller: parent1ContactController,
                      decoration:
                          InputDecoration(labelText: 'Parent 1 Contact'),
                    ),
                    TextFormField(
                      controller: parent2NameController,
                      decoration: InputDecoration(labelText: 'Parent 2 Name'),
                    ),
                    TextFormField(
                      controller: parent2ContactController,
                      decoration:
                          InputDecoration(labelText: 'Parent 2 Contact'),
                    ),
                    TextFormField(
                      controller: medicalHistoryController,
                      decoration: InputDecoration(labelText: 'Medical History'),
                    ),
                    ElevatedButton(
                      onPressed: pickImageWeb,
                      child: Text('Pick Image'),
                    ),
                    _selectedImageBytes != null
                        ? Image.memory(
                            _selectedImageBytes!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : Text('No image selected'),
                    DropdownButtonFormField<String>(
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      decoration: InputDecoration(labelText: 'Active Status'),
                      items: ['True', 'False']
                          .map((status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                    ),
                    DropdownButtonFormField<int>(
                      value: roomId,
                      onChanged: (value) => setState(() => roomId = value),
                      decoration: InputDecoration(labelText: 'Room'),
                      items: rooms
                          .map((room) => DropdownMenuItem<int>(
                                value: room['id'],
                                child: Text(room['name']),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateChildDetails,
                      child: Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
