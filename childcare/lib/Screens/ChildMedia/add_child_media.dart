import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

class AddChildMediaPage extends StatefulWidget {
  final int childId;

  AddChildMediaPage({required this.childId});

  @override
  _AddChildMediaPageState createState() => _AddChildMediaPageState();
}

class _AddChildMediaPageState extends State<AddChildMediaPage> {
  File? _selectedMedia;
  VideoPlayerController? _videoPlayerController;
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
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

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
        return Image.file(
          _selectedMedia!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (_mediaType == 'Video') {
        _videoPlayerController ??= VideoPlayerController.file(_selectedMedia!)
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized
            setState(() {});
          });
        return _videoPlayerController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              )
            : Container();
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowCompression: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _selectedMedia = File(file.path!);
        _mediaType = file.extension == 'mp4' ? 'Video' : 'Image';
      });
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
        'https://child.codingindia.co.in/student/child-media/';
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
            _selectedMedia!.path,
          ),
        );

      final response = await request.send();

      if (response.statusCode == 201) {
        _showSnackBar('Activity saved');
        await Future.delayed(Duration(seconds: 2)); // Wait for 2 seconds
        Navigator.pop(context); // Return to previous page after saving
      } else {
        _showSnackBar('Error: Failed to upload media');
      }
    } catch (error) {
      print('Exception uploading media: $error');
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
