import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChildMediaPage extends StatefulWidget {
  final int childId;

  ChildMediaPage({required this.childId});

  @override
  _ChildMediaPageState createState() => _ChildMediaPageState();
}

class _ChildMediaPageState extends State<ChildMediaPage> {
  List<ChildMedia> childMediaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildMedia();
  }

  Future<void> fetchChildMedia() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://child.codingindia.co.in/Parent/dailyactivitymediaforparent/${widget.childId}'),
        // Replace 'https://child.codingindia.co.in/ChildMediaForParent/${widget.childId}' with your actual API endpoint
        headers: {
          'Content-Type': 'application/json',
          // Add any required headers
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body)['data'];
        setState(() {
          childMediaList =
              responseData.map((data) => ChildMedia.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load child media');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Child Pictures',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: childMediaList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(childMediaList[index].activityType),
                      subtitle: Text(childMediaList[index].description),
                      trailing: Icon(Icons.play_arrow),
                      onTap: () {
                        // Implement logic to display media when tapped
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ChildMedia {
  final int id;
  final String mediaType;
  final String fileUrl;
  final String activityType;
  final String description;

  ChildMedia({
    required this.id,
    required this.mediaType,
    required this.fileUrl,
    required this.activityType,
    required this.description,
  });

  factory ChildMedia.fromJson(Map<String, dynamic> json) {
    return ChildMedia(
      id: json['id'],
      mediaType: json['media_type'],
      fileUrl: json['file'],
      activityType: json['activity_type'],
      description: json['desc'],
    );
  }
}
