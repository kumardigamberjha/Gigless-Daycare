import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class UpdateMediaPage extends StatefulWidget {
  final int roomId;
  final int mediaId;

  UpdateMediaPage({required this.roomId, required this.mediaId});

  @override
  _UpdateMediaPageState createState() => _UpdateMediaPageState();
}

class _UpdateMediaPageState extends State<UpdateMediaPage> {
  PlatformFile? _file;
  bool _isLoading = false;
  Dio dio = Dio();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  Future<void> _updateFile() async {
    if (_file == null) return;

    setState(() {
      _isLoading = true;
    });

    FormData formData = FormData.fromMap({
      'media_file':
          MultipartFile.fromFileSync(_file!.path!, filename: _file!.name),
    });

    try {
      Response response = await dio.put(
        'https://child.codingindia.co.in/student/rooms/${widget.roomId}/media/${widget.mediaId}/update/',
        data: formData,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('File updated successfully')));
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Media')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickFile, child: Text('Select File')),
            SizedBox(height: 16),
            _file != null
                ? Text('${_file!.name} selected')
                : Text('No file selected'),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateFile, child: Text('Update File')),
          ],
        ),
      ),
    );
  }
}
