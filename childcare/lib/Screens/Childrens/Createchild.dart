import 'dart:convert';
import 'dart:io';
import 'package:childcare/Screens/Childrens/child_record.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Import package to format dates

class ChildCreateView extends StatefulWidget {
  @override
  _ChildCreateViewState createState() => _ChildCreateViewState();
}

class _ChildCreateViewState extends State<ChildCreateView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController childFeesController = TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();
  final TextEditingController emergencyContactNameController =
      TextEditingController();
  final TextEditingController emergencyContactNumberController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController parent1NameController = TextEditingController();
  final TextEditingController parent1ContactNumberController =
      TextEditingController();
  final TextEditingController parent2NameController = TextEditingController();
  final TextEditingController parent2ContactNumberController =
      TextEditingController();
  bool isSubmitting = false;
  String selectedGender = 'Boy';
  File? _selectedImage;
  int _currentStep = 0;

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an option'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  final picker = ImagePicker();
                  final pickedImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
                child: Text('Pick from Gallery'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  final picker = ImagePicker();
                  final pickedImage =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedImage != null) {
                    setState(() {
                      _selectedImage = File(pickedImage.path);
                    });
                  }
                },
                child: Text('Take a Photo'),
              ),
            ],
          ),
        );
      },
    );
  }

  bool isLoading = false;

  Future<void> createChild() async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl = 'http://127.0.0.1:8000/student/children/';

    String formattedDateOfBirth = '';
    if (dateOfBirthController.text.isNotEmpty) {
      formattedDateOfBirth = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(dateOfBirthController.text));
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields.addAll({
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'date_of_birth': dateOfBirthController.text,
          'medical_history': medicalHistoryController.text,
          'emergency_contact_name': emergencyContactNameController.text,
          'emergency_contact_number': emergencyContactNumberController.text,
          'gender': selectedGender,
          'child_fees': childFeesController.text,
          'address': addressController.text, // Add address value
          'city': cityController.text, // Add city value
          'state': stateController.text, // Add state value
          'zip_code': zipCodeController.text, // Add zip code value
          'parent1_name': parent1NameController.text, // Add parent 1 name value
          'parent1_contact_number': parent1ContactNumberController
              .text, // Add parent 1 contact number value
          'parent2_name': parent2NameController.text, // Add parent 2 name value
          'parent2_contact_number': parent2ContactNumberController.text,
        });

      // Attach the image file to the request
      if (_selectedImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath('image', _selectedImage!.path));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        // Child created successfully
        print('Child created successfully');
        _showSuccessDialog();
      } else {
        final errorBody = jsonDecode(await response.stream.bytesToString());
        final errorMessage = errorBody['error'] ?? 'Unknown error';
        print('Error creating child: ${response.statusCode} - $errorMessage');
        _showErrorDialog('Error creating child', errorMessage);
      }
    } catch (error) {
      print('Exception creating child: $error');
      _showErrorDialog('Exception', '$error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Child created successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildRecordsPage(),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
        title: Text('Child Record Form'),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Show loader when isLoading is true
            )
          : Form(
              key: _formKey,
              child: Stepper(
                // currentStep: _currentStep >= 0 && _currentStep < 1 ? _currentStep : 0,
                currentStep: _currentStep,
                onStepContinue: () {
                  setState(() {
                    if (_currentStep < 1) {
                      _currentStep += 1; // Progress to the next step
                    } else {
                      createChild(); // Call createChild() only on the last step
                    }
                  });
                },
                onStepCancel: () {
                  setState(() {
                    if (_currentStep > 0) {
                      _currentStep -= 1;
                    }
                  });
                },
                steps: [
                  Step(
                    title: Text('Personal Information'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1491013516836-7db643ee125a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGNoaWxkfGVufDB8fDB8fHww',
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                // Format the picked date and set it to the controller
                                dateOfBirthController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          child: Text(
                            'Pick Date of Birth',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                          ),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Boy', 'Girl']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: medicalHistoryController,
                          decoration: InputDecoration(
                            labelText: 'Medical History',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: childFeesController,
                          decoration: InputDecoration(
                            labelText: 'Fees',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: emergencyContactNameController,
                          decoration: InputDecoration(
                            labelText: 'Emergency Contact Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: emergencyContactNumberController,
                          decoration: InputDecoration(
                            labelText: 'Emergency Contact Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text('No image selected'),
                                ),
                              ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text('Pick Image'),
                        ),
                      ],
                    ),
                  ),
                  Step(
                    title: Text('Address and Contact'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                          // Handle address input
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          // Handle city input
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(),
                          ),
                          // Handle state input
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: zipCodeController,
                          decoration: InputDecoration(
                            labelText: 'Zip Code',
                            border: OutlineInputBorder(),
                          ),
                          // Handle zip code input
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: parent1NameController,
                          decoration: InputDecoration(
                            labelText: 'Parent 1 Name',
                            border: OutlineInputBorder(),
                          ),
                          // Handle parent 1 name input
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: parent1ContactNumberController,
                          decoration: InputDecoration(
                            labelText: 'Parent 1 Contact Number',
                            border: OutlineInputBorder(),
                          ),
                          // Handle parent 1 contact number input
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: parent2NameController,
                          decoration: InputDecoration(
                            labelText: 'Parent 2 Name',
                            border: OutlineInputBorder(),
                          ),
                          // Handle parent 2 name input
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: parent2ContactNumberController,
                          decoration: InputDecoration(
                            labelText: 'Parent 2 Contact Number',
                            border: OutlineInputBorder(),
                          ),
                          // Handle parent 2 contact number input
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
