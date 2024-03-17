import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChildMediaDetailPage extends StatefulWidget {
  final int childId;

  ChildMediaDetailPage({required this.childId});

  @override
  _ChildMediaDetailPageState createState() => _ChildMediaDetailPageState();
}

class _ChildMediaDetailPageState extends State<ChildMediaDetailPage> {
  List<dynamic> _childMediaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChildMedia();
  }

  Future<void> _fetchChildMedia() async {
    final url = 'http://127.0.0.1:8000/student/child-media/${widget.childId}/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        _childMediaList = json.decode(response.body)['data'];
      });
    } else {
      print('Failed to fetch child media');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Media Detail'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _childMediaList.isEmpty
              ? Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: _childMediaList.length,
                  itemBuilder: (context, index) {
                    final childMedia = _childMediaList[index];
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(childMedia['file']),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.network(
                              childMedia[
                                  'file'], // Assuming 'file' contains the image URL
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Media Type: ${childMedia['media_type']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                      'Activity Type: ${childMedia['activity_type']}'),
                                  SizedBox(height: 8),
                                  Text(
                                      'Uploaded At: ${childMedia['uploaded_at']}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
