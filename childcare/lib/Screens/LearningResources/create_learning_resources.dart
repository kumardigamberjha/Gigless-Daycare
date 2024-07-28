import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class LearningResourceForm extends StatefulWidget {
  @override
  _LearningResourceFormState createState() => _LearningResourceFormState();
}

class _LearningResourceFormState extends State<LearningResourceForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitForm() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://child.codingindia.co.in/student/api/resources/'), // Replace with your backend URL
      );
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;

      // Upload the selected video file
      if (_selectedFile != null) {
        request.files.add(
          http.MultipartFile(
            'file',
            _selectedFile!.readAsBytes().asStream(),
            _selectedFile!.lengthSync(),
            filename: _selectedFile!.path.split('/').last,
          ),
        );
      }

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 201) {
        // Resource created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resource created successfully')),
        );
        // Navigate back to the previous page
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to create resource');
      }
    } catch (e) {
      // Handle errors
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Learning Resource'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Select Video'),
            ),
            SizedBox(height: 20),
            _selectedFile != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Video:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(_selectedFile!.path),
                      SizedBox(height: 20),
                    ],
                  )
                : SizedBox(),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
