import 'dart:convert';
import 'dart:io';
import 'package:childcare/Screens/Homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'child_record.dart';
import 'dart:html' as html;
import 'dart:typed_data';

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
  // File? _selectedImage;
  // File? _selectedImage;
  dynamic _selectedImage; // Dynamic to handle both `File` and `html.File`

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
        .get(Uri.parse('https://daycare.codingindia.co.in/student/rooms/'));
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
    if (kIsWeb) {
      // Web-specific image picker
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click(); // Trigger the file input dialog

      uploadInput.onChange.listen((event) {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files!.first;
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file); // Use ArrayBuffer for binary data

          reader.onLoadEnd.listen((_) {
            setState(() {
              _selectedImage = file; // Assign the selected file
            });
          });
        }
      });
    } else {
      // Native (Android/iOS) image picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImage = File(result.files.single.path!); // Assign the file
        });
      }
    }
  }

  Future<void> createChild() async {
    setState(() {
      isSubmitting = true;
    });

    final String apiUrl = 'https://daycare.codingindia.co.in/student/children/';

    String formattedDateOfBirth = '';
    if (dateOfBirthController.text.isNotEmpty) {
      formattedDateOfBirth = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(dateOfBirthController.text));
    }

    try {
      var uri = Uri.parse(apiUrl);
      var request = http.MultipartRequest('POST', uri)
        ..fields.addAll({
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'date_of_birth': formattedDateOfBirth,
          'blood_group': selectedBloodGroup ?? '',
          'medical_history': medicalHistoryController.text,
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
          'is_active': 'true',
        });

      if (_selectedImage != null) {
        if (kIsWeb) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(_selectedImage);
          await reader.onLoadEnd.first;

          request.files.add(http.MultipartFile.fromBytes(
            'image',
            reader.result as List<int>,
            filename: (_selectedImage as html.File).name,
          ));
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              (_selectedImage as File).path,
            ),
          );
        }
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Child created successfully');
        _showSuccessDialog();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        final responseString = await response.stream.bytesToString();
        final errorBody = jsonDecode(responseString);

        String errorMessage = 'Unknown error';

        if (errorBody is Map<String, dynamic>) {
          // If the error body contains field-specific errors, format them properly
          errorMessage = errorBody.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join('\n');
        } else if (errorBody is String) {
          errorMessage = errorBody;
        }

        print('Error creating child: ${response.statusCode} - $errorMessage');
        _showErrorDialog('Error creating child', errorMessage);
      }
    } catch (error) {
      print('Exception creating child: $error');
      _showErrorDialog('Exception', 'An unexpected error occurred: $error');
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
                  MaterialPageRoute(builder: (context) => HomeScreen()),
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
                                onTap: _pickImage, // Call the _pickImage method
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: _selectedImage != null
                                        ? kIsWeb
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  html.Url.createObjectUrl(
                                                      _selectedImage),
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : DecorationImage(
                                                image: FileImage(
                                                    _selectedImage as File),
                                                fit: BoxFit.cover,
                                              )
                                        : null,
                                  ),
                                  child: _selectedImage == null
                                      ? Center(
                                          child: Icon(
                                            Icons.add_a_photo,
                                            color: Colors.blue,
                                            size: 50.0,
                                          ),
                                        )
                                      : null,
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
                                // keyboardType: TextInputType.number,
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
                                // keyboardType: TextInputType.phone,
                                keyboardType: TextInputType.number,

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
                                keyboardType: TextInputType.number,
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
