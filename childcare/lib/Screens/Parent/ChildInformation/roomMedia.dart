import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChildRoomMedia extends StatefulWidget {
  final int childId;

  ChildRoomMedia({required this.childId});

  @override
  _ChildRoomMediaState createState() => _ChildRoomMediaState();
}

class _ChildRoomMediaState extends State<ChildRoomMedia> {
  List<dynamic> _mediaFiles = [];
  bool _isLoading = true;
  bool isSuperuser = false;

  @override
  void initState() {
    super.initState();
    fetchRoomMedia(widget.childId);
  }

  // Function to fetch media files for the room
  Future<void> fetchRoomMedia(int childId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    bool? superuserStatus = prefs.getBool('is_superuser');

    // Update isSuperuser state
    setState(() {
      isSuperuser = superuserStatus ?? false; // Default to false if null
    });

    final response = await http.get(
      Uri.parse(
          'https://daycare.codingindia.co.in/Parent/childroomforparents/$childId/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _mediaFiles =
            jsonDecode(response.body)['media']; // Assuming 'media' is returned
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load media files');
    }
  }

  // Function to delete a media file
  Future<void> deleteMediaFile(int mediaId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await http.delete(
      Uri.parse(
          'https://daycare.codingindia.co.in/Parent/roommedia/$mediaId/delete/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

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

  // Confirmation dialog for deleting media
  void confirmDelete(int mediaId) {
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
                deleteMediaFile(mediaId);
              },
            ),
          ],
        );
      },
    );
  }

  // Open full-screen image view
  void _openImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(imageUrl: imageUrl),
      ),
    );
  }

  // Convert relative image path to full URL
  String getImageUrl(String path) {
    String baseUrl =
        "https://daycare.codingindia.co.in"; // Replace with your actual base URL
    return path.startsWith('/') ? "$baseUrl$path" : path;
  }

  String enforceHttps(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/150'; // Default placeholder image
    }
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room Media')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _mediaFiles.isEmpty
              ? Center(child: Text('No media uploaded'))
              : ListView.builder(
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    final media = _mediaFiles[index];
                    final mediaUrl = enforceHttps(
                        'https://daycare.codingindia.co.in${media['media_file']}');

                    return Card(
                      child: ListTile(
                        leading: media['media_file'].endsWith(".jpg") ||
                                media['media_file'].endsWith(".png")
                            ? GestureDetector(
                                onTap: () {
                                  _openImage(mediaUrl);
                                },
                                child: Image.network(
                                  mediaUrl,
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
