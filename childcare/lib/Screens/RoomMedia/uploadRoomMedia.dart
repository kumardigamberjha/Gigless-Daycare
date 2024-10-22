import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class UploadMediaPage extends StatefulWidget {
  final int roomId;

  UploadMediaPage({required this.roomId});

  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  List<PlatformFile>? _files;
  bool _isLoading = false;
  Dio dio = Dio();

  Future<void> _pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _files = result.files;
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (_files == null || _files!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    FormData formData = FormData.fromMap({
      'media_files': _files!
          .map((file) =>
              MultipartFile.fromFileSync(file.path!, filename: file.name))
          .toList(),
    });

    try {
      Response response = await dio.post(
        'https://child.codingindia.co.in/student/rooms/${widget.roomId}/upload/',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Media')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickFiles, child: Text('Select Files')),
            SizedBox(height: 16),
            _files != null
                ? Text('${_files!.length} files selected')
                : Text('No files selected'),
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
