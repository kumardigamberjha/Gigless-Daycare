import 'dart:convert';
import 'dart:io';
import 'package:childcare/Screens/DailyActivity/ShowDailyActivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DailyActivityPage extends StatefulWidget {
  final int childId;

  DailyActivityPage({required this.childId});

  @override
  _DailyActivityPageState createState() => _DailyActivityPageState();
}

class _DailyActivityPageState extends State<DailyActivityPage> {
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

  File? _selectedMedia;

  bool _isSaving = false;

  Future<void> saveDailyActivity() async {
    setState(() {
      _isSaving = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://child.codingindia.co.in/student/api/create-daily-activity/${widget.childId}/'),
      );
      request.fields['child'] = widget.childId.toString();
      request.fields['meal_description'] = mealDescriptionController.text;
      request.fields['nap_duration'] = napDurationController.text;
      request.fields['playtime_activities'] = playtimeActivitiesController.text;
      request.fields['bathroom_breaks'] = bathroomBreaksController.text;
      request.fields['mood'] = moodController.text;
      request.fields['temperature'] = temperatureController.text;
      request.fields['medication_given'] = medicationGivenController.text;

      if (_selectedMedia != null) {
        var mediaStream = http.ByteStream(_selectedMedia!.openRead());
        var mediaLength = await _selectedMedia!.length();
        var mediaUri = Uri.file(_selectedMedia!.path);

        var mediaMultipart = http.MultipartFile(
          'image',
          mediaStream,
          mediaLength,
          filename: mediaUri.pathSegments.last,
        );

        request.files.add(mediaMultipart);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
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
  void initState() {
    super.initState();
    childIdController.text = widget.childId.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Activity Form',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
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
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF0891B2), // text color
              ),
              child: _isSaving
                  ? CircularProgressIndicator()
                  : Text('Save Daily Activity'),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DailyActivityPage(childId: 1), // Replace with the actual childId
  ));
}
