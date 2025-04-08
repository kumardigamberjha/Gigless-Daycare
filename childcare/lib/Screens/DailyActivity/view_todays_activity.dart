import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ViewTodaysActivityPage extends StatefulWidget {
  final int childId;

  ViewTodaysActivityPage({required this.childId});

  @override
  _ViewTodaysActivityPageState createState() => _ViewTodaysActivityPageState();
}

class _ViewTodaysActivityPageState extends State<ViewTodaysActivityPage> {
  Map<String, dynamic> dailyActivities = {};
  Map<String, dynamic> childData = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://daycare.codingindia.co.in/student/api/daily-activity/${widget.childId}/",
        ),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic>) {
          setState(() {
            List<dynamic> dailyActivitiesList = responseData['data'];
            if (dailyActivitiesList.isNotEmpty) {
              dailyActivities =
                  Map<String, dynamic>.from(dailyActivitiesList[0]);
            } else {
              dailyActivities = {};
            }

            childData = Map<String, dynamic>.from(responseData['user']);
            isLoading = false;
          });
        } else if (responseData is List<dynamic> && responseData.isNotEmpty) {
          print('Received a List, but expected a Map. Data: $responseData');
          handleFetchError('Unexpected data format.');
        } else {
          handleFetchError('Unexpected response format.');
        }
      } else {
        handleFetchError(
            'Failed to load child details. Error: ${response.statusCode}');
      }
    } catch (error) {
      handleFetchError('Error fetching data: $error');
    }
  }

  void handleFetchError(String error) {
    setState(() {
      isLoading = false;
      errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Today's Activity",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main_bottom.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : buildChildDetails(),
      ),
    );
  }

  Widget buildChildDetails() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildCircleAvatar(),
                SizedBox(height: 20),
                buildChildInformation(),
                SizedBox(height: 20),
                buildInfoTile(
                  'Meal Description',
                  '${dailyActivities['meal_description'] ?? ''}',
                  Icons.restaurant,
                ),
                // Add other info tiles here

                buildInfoTile(
                  'nap_duration',
                  '${dailyActivities['nap_duration'] ?? ''}',
                  Icons.cake,
                ),
                buildInfoTile(
                  'Mood',
                  "${dailyActivities['mood'] ?? ''}",
                  Icons.person,
                ),
                buildInfoTile(
                  'playtime_activities',
                  '${dailyActivities['playtime_activities'] != null}',
                  Icons.access_time,
                ),
                SizedBox(height: 10),
                buildInfoTile(
                  'bathroom_breaks',
                  '${dailyActivities['bathroom_breaks'] ?? ''}',
                  Icons.phone,
                  // Add a button to initiate a call
                ),
                SizedBox(height: 10),
                buildInfoTile(
                  'temperature',
                  '${dailyActivities['temperature'] ?? ''}°F',
                  Icons.local_hospital,
                ),
                SizedBox(height: 10),
                buildInfoTile(
                  'medication_given',
                  dailyActivities['medication_given'] ?? '',
                  Icons.local_hospital,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? validatedImageUrl(String? url) {
    if (url != null &&
        Uri.tryParse(url)?.isAbsolute == true &&
        url.startsWith('https')) {
      return url;
    }
    return null;
  }

  Widget buildCircleAvatar() {
    // Get the image URL or use an empty string if not provided
    String imageUrl = childData['image'] ?? '';
    print(imageUrl);

    // Check if the image URL is empty or null, use a placeholder image
    if (imageUrl.isEmpty) {
      imageUrl =
          'https://via.placeholder.com/150'; // Placeholder URL if image URL is empty
    } else if (!imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://')) {
      // Prepend the base URL if the image URL doesn't already have http:// or https://
      imageUrl = 'https://daycare.codingindia.co.in$imageUrl';
    }

    return CircleAvatar(
      radius: 80,
      backgroundColor: Color(0xFF0891B2),
      child: CircleAvatar(
        radius: 75,
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: 150,
            height: 150,
            errorBuilder: (context, error, stackTrace) {
              // Fallback in case the image fails to load
              return Image.network(
                'https://via.placeholder.com/150', // Fallback placeholder for failed image loads
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildChildInformation() {
    return Column(
      children: [
        Text(
          '${childData['first_name']}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0891B2),
          ),
        ),
        // Add other child information widgets here
      ],
    );
  }

  Widget buildInfoTile(String title, String subtitle, IconData icon) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0891B2),
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFF0891B2),
            size: 20,
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
