import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:childcare/Screens/ChildMedia/add_child_media.dart';
import 'package:childcare/Screens/ChildMedia/show_child_media.dart';

class ShowChildActivityMediaPage extends StatefulWidget {
  @override
  _ShowChildActivityMediaPageState createState() =>
      _ShowChildActivityMediaPageState();
}

class _ShowChildActivityMediaPageState
    extends State<ShowChildActivityMediaPage> {
  List<Map<String, dynamic>> childRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("https://daycare.codingindia.co.in/student/child-list/"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> updatedRecords = [];

        await Future.wait(data.map((child) async {
          try {
            final statusResponse = await http.get(Uri.parse(
              "https://daycare.codingindia.co.in/student/api/daily-activity/${child['id']}",
            ));

            if (statusResponse.statusCode == 200) {
              final statusData = json.decode(statusResponse.body);
              child['isActivitySaved'] =
                  statusData['is_activity_saved'] ?? false;
            } else {
              child['isActivitySaved'] = false;
            }
          } catch (e) {
            child['isActivitySaved'] = false;
          }
          updatedRecords.add(Map<String, dynamic>.from(child));
        }));

        setState(() {
          childRecords = updatedRecords;
          isLoading = false;
        });
      } else {
        print('Failed to load child records. Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  void navigateToAddMedia(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildMediaPage(childId: childId),
      ),
    );
  }

  void navigateToViewMedia(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildMediaDetailPage(childId: childId),
      ),
    );
  }

  String enforceHttps(String? url) {
    if (url == null || url.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activity Media",
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0891B2),
        elevation: 4,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : childRecords.isEmpty
              ? Center(
                  child: Text('No child records available'),
                )
              : ListView.builder(
                  itemCount: childRecords.length,
                  itemBuilder: (context, index) {
                    final child = childRecords[index];
                    final imageUrl = enforceHttps(child['image']);
                    final name =
                        '${child['first_name'] ?? ''} ${child['last_name'] ?? ''}';
                    final isActivitySaved = child['isActivitySaved'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.brown,
                                    width: 4,
                                  ),
                                  image: DecorationImage(
                                    image: (imageUrl != null &&
                                            imageUrl.isNotEmpty)
                                        ? NetworkImage(
                                            imageUrl.startsWith('http://')
                                                ? imageUrl.replaceFirst(
                                                    'http://', 'https://')
                                                : imageUrl,
                                          )
                                        : AssetImage(
                                                'assets/images/placeholder_image.png')
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              navigateToAddMedia(child['id']),
                                          icon: Icon(Icons.add),
                                          label: Text('Add Media'),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Color(0xFF0891B2),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              navigateToViewMedia(child['id']),
                                          icon: Icon(Icons.visibility),
                                          label: Text('View Media'),
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      isActivitySaved
                                          ? 'Activity saved for today'
                                          : 'Activity not saved for today',
                                      style: TextStyle(
                                        color: isActivitySaved
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
