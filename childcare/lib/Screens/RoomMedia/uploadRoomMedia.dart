import 'dart:io';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class UploadMediaPage extends StatefulWidget {
  final int roomId;

  UploadMediaPage({required this.roomId});

  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  List<dynamic>? _files; // Handles both File and html.File
  bool _isLoading = false;
  Dio dio = Dio();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFilesFromGallery() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*,video/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          setState(() {
            _files = uploadInput.files;
          });
        }
      });
    } else {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        setState(() {
          _files = result.files;
        });
      }
    }
  }

  Future<void> _pickImagesFromGallery() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          setState(() {
            _files = uploadInput.files;
          });
        }
      });
    } else {
      List<XFile>? images = await _picker.pickMultiImage();

      if (images != null && images.isNotEmpty) {
        setState(() {
          _files = images.map((image) => File(image.path)).toList();
        });
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (!kIsWeb) {
      XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _files = [File(image.path)];
        });
      }
    }
  }

  Future<void> _uploadFiles() async {
    if (_files == null || _files!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    FormData formData = FormData();

    if (kIsWeb) {
      for (var file in _files!) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first;

        formData.files.add(
          MapEntry(
            'media_files',
            MultipartFile.fromBytes(
              reader.result as List<int>,
              filename: file.name,
            ),
          ),
        );
      }
    } else {
      for (var file in _files!) {
        if (file is File) {
          formData.files.add(
            MapEntry(
              'media_files',
              await MultipartFile.fromFile(file.path,
                  filename: file.path.split('/').last),
            ),
          );
        }
      }
    }

    try {
      Response response = await dio.post(
        'https://daycare.codingindia.co.in/student/rooms/${widget.roomId}/upload/',
        data: formData,
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Files uploaded successfully')),
        );
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSelectionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.folder),
                title: Text("Files"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFilesFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilePreview() {
    if (_files != null && _files!.isNotEmpty) {
      if (kIsWeb) {
        return Column(
          children: (_files! as List<html.File>)
              .map((file) => Text(file.name))
              .toList(),
        );
      } else {
        return Column(
          children: (_files! as List<File>)
              .map((file) => Text(file.path.split('/').last))
              .toList(),
        );
      }
    }
    return Text('No files or images selected');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Media')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showSelectionDialog,
              child: Text('Select Files or Media'),
            ),
            SizedBox(height: 16),
            _buildFilePreview(),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadFiles,
                    child: Text('Upload'),
                  ),
          ],
        ),
      ),
    );
  }
}
