import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'child_record.dart';

class ChildCreateView extends StatefulWidget {
  @override
  _ChildCreateViewState createState() => _ChildCreateViewState();
}

class _ChildCreateViewState extends State<ChildCreateView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController childFeesController = TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController(); // Optional
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
  final TextEditingController parent2NameController =
      TextEditingController(); // Optional
  final TextEditingController parent2ContactNumberController =
      TextEditingController(); // Optional
  bool isSubmitting = false;
  String selectedGender = 'Boy';
  String? selectedBloodGroup;
  File? _selectedImage;
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? selectedRoom;
  List<dynamic> _rooms = [];
  int _noOfRooms = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final response = await http
        .get(Uri.parse('https://child.codingindia.co.in/student/rooms/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _rooms = data['data'];
        _noOfRooms = data['no_of_rooms'];
      });
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> createChild() async {
    setState(() {
      isSubmitting = true;
    });

    final String apiUrl = 'https://child.codingindia.co.in/student/children/';

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
          'date_of_birth': formattedDateOfBirth,
          'blood_group': selectedBloodGroup ?? '',
          'medical_history': medicalHistoryController.text, // Optional field
          'gender': selectedGender,
          'child_fees': childFeesController.text,
          'address': addressController.text,
          'city': cityController.text,
          'state': stateController.text,
          'zip_code': zipCodeController.text,
          'parent1_name': parent1NameController.text,
          'parent1_contact_number': parent1ContactNumberController.text,
          'parent2_name': parent2NameController.text,
          'parent2_contact_number': parent2ContactNumberController.text,
          'room': selectedRoom.toString(),
          'is_active': 'true', // Ensure is_active is set to true
        });

      if (_selectedImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath('image', _selectedImage!.path));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
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
        isSubmitting = false;
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChildRecordsPage()),
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
        title: Text(
          'Add Student',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: isSubmitting
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _rooms.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Stepper(
                      type: StepperType.vertical,
                      currentStep: _currentStep,
                      onStepContinue: () {
                        setState(() {
                          if (_currentStep < 1) {
                            _currentStep += 1;
                            _animationController.forward(from: 0.0);
                          } else {
                            if (_formKey.currentState!.validate()) {
                              createChild();
                            }
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
                              GestureDetector(
                                onTap: _pickImage,
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        image: _selectedImage != null
                                            ? DecorationImage(
                                                image:
                                                    FileImage(_selectedImage!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: _selectedImage == null
                                          ? Center(
                                              child: Icon(
                                                Icons.add_a_photo,
                                                color: Color(0xFF0891B2),
                                                size: 50.0,
                                              ),
                                            )
                                          : null,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: firstNameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter first name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: lastNameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter last name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: dateOfBirthController,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (pickedDate != null) {
                                        setState(() {
                                          dateOfBirthController.text =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                readOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select date of birth';
                                  }
                                  return null;
                                },
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
                                items: [
                                  'Boy',
                                  'Girl'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select gender';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: selectedBloodGroup,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedBloodGroup = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Blood Group',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  'A+',
                                  'A-',
                                  'B+',
                                  'B-',
                                  'AB+',
                                  'AB-',
                                  'O+',
                                  'O-'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select blood group';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: medicalHistoryController,
                                decoration: InputDecoration(
                                  labelText: 'Medical History',
                                  border: OutlineInputBorder(),
                                ),
                                // Removed validation as it's optional
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: childFeesController,
                                decoration: InputDecoration(
                                  labelText: 'Fees',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter fees';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              DropdownButtonFormField<int>(
                                value: selectedRoom,
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedRoom = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Room',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    _rooms.map<DropdownMenuItem<int>>((room) {
                                  return DropdownMenuItem<int>(
                                    value: room['id'],
                                    child: Text(room['name']),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a room';
                                  }
                                  return null;
                                },
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: cityController,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter city';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: stateController,
                                decoration: InputDecoration(
                                  labelText: 'State',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter state';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: zipCodeController,
                                decoration: InputDecoration(
                                  labelText: 'Zip Code',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter zip code';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: parent1NameController,
                                decoration: InputDecoration(
                                  labelText: 'Parent 1 Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter parent 1 name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: parent1ContactNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Parent 1 Contact Number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter parent 1 contact number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: parent2NameController,
                                decoration: InputDecoration(
                                  labelText: 'Parent 2 Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: parent2ContactNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Parent 2 Contact Number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
