import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

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
    final url =
        'https://child.codingindia.co.in/student/child-media/${widget.childId}/';
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
        title: Text(
          'Child Pictures Detail',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
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
                      onTap: () => _showMedia(
                          childMedia['file'], childMedia['media_type']),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMediaWidget(
                                childMedia['file'], childMedia['media_type']),
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

  Widget _buildMediaWidget(String fileUrl, String mediaType) {
    if (mediaType == 'Image') {
      return Image.network(
        fileUrl,
        height: 200,
        fit: BoxFit.cover,
      );
    } else if (mediaType == 'Video') {
      return VideoPlayerWidget(videoUrl: fileUrl);
    } else {
      return SizedBox.shrink();
    }
  }

  void _showMedia(String fileUrl, String mediaType) {
    if (mediaType == 'Video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoUrl: fileUrl),
        ),
      );
    } else {
      _showFullScreenImage(fileUrl);
    }
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

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true); // This will loop the video indefinitely
    _controller.play(); // This will start playing the video
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Center(
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }
}
