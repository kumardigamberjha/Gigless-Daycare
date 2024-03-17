import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddChildMediaPage extends StatefulWidget {
  final int childId;

  AddChildMediaPage({required this.childId});

  @override
  _AddChildMediaPageState createState() => _AddChildMediaPageState();
}

class _AddChildMediaPageState extends State<AddChildMediaPage> {
  File? _selectedImage;
  String? _mediaType;
  String? _activityType;
  TextEditingController _descController = TextEditingController();

  final List<String> _mediaTypes = ['Image', 'Video'];

  final List<String> _activityTypes = ['Meal', 'Nap', 'Playtime', 'Bathroom', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Child Media'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      child: Text(
                        'No image selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _mediaType,
              decoration: InputDecoration(
                labelText: 'Media Type',
                border: OutlineInputBorder(),
              ),
              items: _mediaTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _mediaType = newValue;
                });
              },
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _activityType,
              decoration: InputDecoration(
                labelText: 'Activity Type',
                border: OutlineInputBorder(),
              ),
              items: _activityTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _activityType = newValue;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _uploadImage();
              },
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      _showSnackBar('Error: No image selected');
      return;
    }

    final String apiUrl = 'http://127.0.0.1:8000/student/child-media/';
    final String childId = widget.childId.toString();

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['child'] = childId
        ..fields['media_type'] = _mediaType ?? ''
        ..fields['activity_type'] = _activityType ?? ''
        ..fields['desc'] = _descController.text
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            _selectedImage!.path,
          ),
        );

      final response = await request.send();

      if (response.statusCode == 201) {
        _showSnackBar('Activity saved');
        await Future.delayed(Duration(seconds: 2)); // Wait for 2 seconds
        Navigator.pop(context); // Return to previous page after saving
      } else {
        _showSnackBar('Error: Failed to upload child media');
      }
    } catch (error) {
      print('Exception creating child media: $error');
      _showSnackBar('Exception: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
