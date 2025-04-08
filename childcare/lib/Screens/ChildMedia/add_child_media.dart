import 'dart:typed_data'; // For handling bytes
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert'; // Import to handle base64 encoding for web

class AddChildMediaPage extends StatefulWidget {
  final int childId;

  AddChildMediaPage({required this.childId});

  @override
  _AddChildMediaPageState createState() => _AddChildMediaPageState();
}

class _AddChildMediaPageState extends State<AddChildMediaPage> {
  dynamic _selectedMedia; // Handles both File (mobile) and html.File (web)
  String? _mediaType;
  String? _activityType;
  TextEditingController _descController = TextEditingController();
  bool _isUploading = false;

  final List<String> _activityTypes = [
    'Meal',
    'Nap',
    'Playtime',
    'Bathroom',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Child Pictures",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectedMedia(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickMedia,
              child: Text('Select Media'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0891B2),
                foregroundColor: Colors.white,
              ),
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
              onPressed: _isUploading
                  ? null
                  : () async {
                      await _uploadMedia();
                    },
              child: _isUploading
                  ? CircularProgressIndicator()
                  : Text('Upload Media'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0891B2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMedia() {
    if (_selectedMedia != null) {
      if (_mediaType == 'Image') {
        if (kIsWeb) {
          return Image.network(
            html.Url.createObjectUrl(_selectedMedia),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        } else {
          return Image.file(
            _selectedMedia as File,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        }
      } else if (_mediaType == 'Video') {
        return Container(
          height: 200,
          child: Center(
            child: Text('Video preview is not supported in this demo.'),
          ),
        );
      }
    }
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          'No media selected',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _pickMedia() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*,video/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files!.first;
          setState(() {
            _mediaType = file.type.startsWith('video/') ? 'Video' : 'Image';
            _selectedMedia = file;
          });
        }
      });
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowCompression: true,
      );

      if (result != null) {
        final file = result.files.first;
        setState(() {
          _mediaType = file.extension == 'mp4' ? 'Video' : 'Image';
          _selectedMedia = File(file.path!);
        });
      }
    }
  }

  Future<void> _uploadMedia() async {
    setState(() {
      _isUploading = true;
    });

    if (_selectedMedia == null) {
      _showSnackBar('Error: No media selected');
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final String apiUrl =
        'https://daycare.codingindia.co.in/student/child-media/';
    final String childId = widget.childId.toString();

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['child'] = childId
        ..fields['media_type'] = _mediaType ?? ''
        ..fields['activity_type'] = _activityType ?? ''
        ..fields['desc'] = _descController.text;

      if (kIsWeb) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_selectedMedia);
        await reader.onLoadEnd.first;

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            reader.result as List<int>,
            filename: (_selectedMedia as html.File).name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            (_selectedMedia as File).path,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        _showSnackBar('Activity saved');
        Navigator.pop(context);
      } else {
        _showSnackBar('Error: Failed to upload media');
      }
    } catch (error) {
      _showSnackBar('Exception: $error');
    } finally {
      setState(() {
        _isUploading = false;
      });
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
