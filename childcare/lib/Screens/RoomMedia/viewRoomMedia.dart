import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewMediaPage extends StatefulWidget {
  final int roomId;

  ViewMediaPage({required this.roomId});

  @override
  _ViewMediaPageState createState() => _ViewMediaPageState();
}

class _ViewMediaPageState extends State<ViewMediaPage> {
  List<dynamic> _mediaFiles = [];
  bool _isLoading = true;

  Future<void> _fetchMediaFiles() async {
    final response = await http.get(Uri.parse(
        'https://child.codingindia.co.in/student/rooms/${widget.roomId}/media/'));

    if (response.statusCode == 200) {
      setState(() {
        _mediaFiles = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load media files');
    }
  }

  Future<void> _deleteMediaFile(int mediaId) async {
    final response = await http.delete(Uri.parse(
        'https://child.codingindia.co.in/student/rooms/${widget.roomId}/media/$mediaId/delete/'));

    if (response.statusCode == 204) {
      setState(() {
        _mediaFiles.removeWhere((media) => media['id'] == mediaId);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Media deleted successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete media')));
    }
  }

  void _confirmDelete(int mediaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Media'),
          content: Text('Are you sure you want to delete this media?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMediaFile(mediaId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchMediaFiles();
  }

  void _openImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Files')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _mediaFiles.isEmpty
              ? Center(child: Text('No media uploaded'))
              : ListView.builder(
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    final media = _mediaFiles[index];
                    final mediaUrl =
                        'https://child.codingindia.co.in${media['media_file']}'; // Full URL for the image

                    return Card(
                      child: ListTile(
                        leading: media['media_file'].endsWith(".jpg") ||
                                media['media_file'].endsWith(".png")
                            ? GestureDetector(
                                onTap: () {
                                  _openImage(
                                      mediaUrl); // Use full URL for full-screen view
                                },
                                child: Image.network(
                                  mediaUrl, // Full URL for image preview
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 50);
                                  },
                                ),
                              )
                            : Icon(Icons.insert_drive_file),
                        title: Text(media['media_file'].split('/').last),
                        subtitle: Text('Uploaded on: ${media['uploaded_at']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(media['id']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Full-Screen Image")),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, size: 150);
          },
        ),
      ),
    );
  }
}
