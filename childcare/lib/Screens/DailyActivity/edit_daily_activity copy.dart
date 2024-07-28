import 'dart:convert';
import 'dart:io';

import 'package:childcare/Screens/DailyActivity/ShowDailyActivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditDailyActivityPage extends StatefulWidget {
  final int childId;

  EditDailyActivityPage({required this.childId});

  @override
  _EditDailyActivityPageState createState() => _EditDailyActivityPageState();
}

class _EditDailyActivityPageState extends State<EditDailyActivityPage> {
  final TextEditingController mealDescriptionController =
      TextEditingController();
  final TextEditingController napDurationController = TextEditingController();
  final TextEditingController playtimeActivitiesController =
      TextEditingController();
  final TextEditingController bathroomBreaksController =
      TextEditingController();
  final TextEditingController moodController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();
  final TextEditingController medicationGivenController =
      TextEditingController();

  final TextEditingController childIdController = TextEditingController();

  bool _isSaving = false;
  bool isLoading = false;
  String errorMessage = '';
  Map<String, dynamic> dailyActivities = {};

  @override
  void initState() {
    super.initState();
    childIdController.text = widget.childId.toString();
    fetchData(); // Call fetchData method to fetch data from API
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          "https://child.codingindia.co.in/student/api/daily-activity/${widget.childId}/",
        ),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print("Dynamic Value: $responseData");

        if (responseData is Map<String, dynamic>) {
          setState(() {
            List<dynamic> dailyActivitiesList = responseData['data'];
            if (dailyActivitiesList.isNotEmpty) {
              // Assign the first daily activity data to the dailyActivities map
              dailyActivities =
                  Map<String, dynamic>.from(dailyActivitiesList[0]);
            } else {
              // If no daily activities found, reset the dailyActivities map
              dailyActivities = {};
            }

            isLoading = false;
            updateControllers(); // Update controllers with fetched data
          });
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

  void updateControllers() {
    mealDescriptionController.text = dailyActivities['meal_description'] ?? '';
    napDurationController.text = dailyActivities['nap_duration'] ?? '';
    playtimeActivitiesController.text =
        dailyActivities['playtime_activities'] ?? '';
    bathroomBreaksController.text =
        dailyActivities['bathroom_breaks']?.toString() ?? '';
    moodController.text = dailyActivities['mood'] ?? '';
    temperatureController.text =
        dailyActivities['temperature']?.toString() ?? '';
    medicationGivenController.text = dailyActivities['medication_given'] ?? '';
  }

  Future<void> saveDailyActivity() async {
    setState(() {
      _isSaving = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://child.codingindia.co.in/student/api/edit-daily-activity/${widget.childId}/'),
      );
      request.fields['child'] = widget.childId.toString();
      request.fields['meal_description'] = mealDescriptionController.text;
      request.fields['nap_duration'] = napDurationController.text;
      request.fields['playtime_activities'] = playtimeActivitiesController.text;
      request.fields['bathroom_breaks'] = bathroomBreaksController.text;
      request.fields['mood'] = moodController.text;
      request.fields['temperature'] = temperatureController.text;
      request.fields['medication_given'] = medicationGivenController.text;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Daily activity with media saved successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily activity saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ShowDailyActivityPage(),
          ),
        );
      } else {
        print('Failed to save daily activity with media');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save daily activity'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while saving. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Save Daily Activity with Media'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: childIdController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Child ID'),
            ),
            TextField(
              controller: mealDescriptionController,
              decoration: InputDecoration(
                  labelText: 'Meal Description',
                  hintText: 'e.g. Chicken Pasta'),
            ),
            TextField(
              controller: napDurationController,
              decoration: InputDecoration(
                  labelText: 'Nap Duration', hintText: 'e.g. 2:30'),
            ),
            TextField(
              controller: playtimeActivitiesController,
              decoration: InputDecoration(
                  labelText: 'Playtime Activities',
                  hintText: 'e.g. Coloring, Puzzle'),
            ),
            TextField(
              controller: bathroomBreaksController,
              decoration: InputDecoration(
                  labelText: 'Bathroom Breaks', hintText: 'e.g. 2'),
            ),
            TextField(
              controller: moodController,
              decoration: InputDecoration(
                  labelText: 'Mood', hintText: 'e.g. Happy, Sad'),
            ),
            TextField(
              controller: temperatureController,
              decoration: InputDecoration(
                  labelText: 'Temperature', hintText: 'e.g. 98.6'),
            ),
            TextField(
              controller: medicationGivenController,
              decoration: InputDecoration(
                  labelText: 'Medication Given',
                  hintText: 'e.g. Tylenol, None'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isSaving ? null : saveDailyActivity,
              child: _isSaving
                  ? CircularProgressIndicator()
                  : Text('Save Daily Activity with Media'),
            ),
          ],
        ),
      ),
    );
  }
}
