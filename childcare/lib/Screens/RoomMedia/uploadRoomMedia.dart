import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class UploadMediaPage extends StatefulWidget {
  final int roomId;

  UploadMediaPage({required this.roomId});

  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  List<PlatformFile>? _files;
  List<XFile>? _imageFiles;
  bool _isLoading = false;
  Dio dio = Dio();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFilesFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _files = result.files;
        _imageFiles = null; // clear previously selected images from camera
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _imageFiles = [image];
        _files = null; // clear previously selected files
      });
    }
  }

  Future<void> _pickImagesFromGallery() async {
    List<XFile>? images = await _picker.pickMultiImage();
    
    if (images != null && images.isNotEmpty) {
      setState(() {
        _imageFiles = images;
        _files = null; // clear previously selected files
      });
    }
  }

  Future<void> _uploadFiles() async {
    if ((_files == null || _files!.isEmpty) && (_imageFiles == null || _imageFiles!.isEmpty)) return;

    setState(() {
      _isLoading = true;
    });

    FormData formData = FormData();

    if (_files != null && _files!.isNotEmpty) {
      formData.files.addAll(_files!.map((file) => MapEntry(
          'media_files',
          MultipartFile.fromFileSync(file.path!, filename: file.name))));
    }

    if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      formData.files.addAll(_imageFiles!.map((image) => MapEntry(
          'media_files',
          MultipartFile.fromFileSync(image.path, filename: image.name))));
    }

    try {
      Response response = await dio.post(
        'http://127.0.0.1:8000/student/rooms/${widget.roomId}/upload/',
        data: formData,
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Files uploaded successfully')));
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
                  }),
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
      return Column(
        children: _files!.map((file) => Text(file.name)).toList(),
      );
    } else if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      return Column(
        children: _imageFiles!.map((image) => Image.file(File(image.path), height: 100, width: 100)).toList(),
      );
    } else {
      return Text('No files or images selected');
    }
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
                child: Text('Select Files or Media')),
            SizedBox(height: 16),
            _buildFilePreview(),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadFiles, child: Text('Upload')),
          ],
        ),
      ),
    );
  }
}
