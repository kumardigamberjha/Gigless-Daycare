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

  @override
  void initState() {
    super.initState();
    fetchRoomMedia(widget.childId);
  }

  // Function to fetch media files for the room
  Future<void> fetchRoomMedia(int childId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(
          'https://child.codingindia.co.in/Parent/childroomforparents/$childId/'),
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
          'https://child.codingindia.co.in/Parent/roommedia/$mediaId/delete/'),
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
  void openImage(String imageUrl) {
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
        "https://child.codingindia.co.in"; // Replace with your actual base URL
    return path.startsWith('/') ? "$baseUrl$path" : path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room Media')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _mediaFiles.isEmpty
              ? Center(child: Text('No media uploaded'))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Number of images per row
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    final media = _mediaFiles[index];
                    final mediaUrl = getImageUrl(
                        media['media_file']); // Full URL for the image

                    return GestureDetector(
                      onTap: () {
                        openImage(mediaUrl); // Open image in full-screen view
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Image.network(
                          mediaUrl, // Full URL for image
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 50);
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
