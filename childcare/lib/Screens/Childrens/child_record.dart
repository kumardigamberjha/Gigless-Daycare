import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:childcare/Screens/Childrens/showchild.dart'; // Import for child details page
import 'package:childcare/Screens/Childrens/EditChild.dart'; // Import for edit child page

class ChildRecordsPage extends StatefulWidget {
  @override
  _ChildRecordsPageState createState() => _ChildRecordsPageState();
}

class _ChildRecordsPageState extends State<ChildRecordsPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> childRecords = [];
  List<Map<String, dynamic>> filteredChildRecords = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isLoading = true; // To track the loading state
  bool isSuperuser = false;
  TextEditingController searchController =
      TextEditingController(); // Controller for search bar

  @override
  void initState() {
    super.initState();
    fetchData();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose(); // Dispose the search controller
    super.dispose();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? superuserStatus = prefs.getBool('is_superuser');

    // Update isSuperuser state
    setState(() {
      isSuperuser = superuserStatus ?? false; // Default to false if null
    });

    final response = await http.get(
        Uri.parse("https://daycare.codingindia.co.in/student/child-list/"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        childRecords = data.cast<Map<String, dynamic>>();
        filteredChildRecords =
            List.from(childRecords); // Initialize filtered list
        isLoading = false; // Set loading to false after data is fetched
        _animationController.forward();
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false if fetching fails
      });
      print('Failed to load child records. Error: ${response.statusCode}');
    }
  }

  // Group students by room name
  Map<String, List<Map<String, dynamic>>> groupStudentsByRoomName() {
    Map<String, List<Map<String, dynamic>>> roomWiseStudents = {};

    for (var child in filteredChildRecords) {
      String roomName =
          child['roomname'] ?? 'Unassigned Room'; // Default room name if null
      if (!roomWiseStudents.containsKey(roomName)) {
        roomWiseStudents[roomName] = [];
      }
      roomWiseStudents[roomName]!.add(child);
    }

    return roomWiseStudents;
  }

  // Filter child records based on search query
  void filterChildRecords(String query) {
    setState(() {
      filteredChildRecords = childRecords.where((child) {
        final String fullName =
            '${child['first_name'] ?? ''} ${child['last_name'] ?? ''}';
        final String uniqueId = child['unique_id'] ?? '';
        return fullName.toLowerCase().contains(query.toLowerCase()) ||
            uniqueId.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomWiseStudents = groupStudentsByRoomName();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Room-wise Child Records',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0891B2),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                filterChildRecords(value); // Filter child records as user types
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : roomWiseStudents.isEmpty
              ? Center(
                  child: Text(
                    'No records available', // Show "No Record" message
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: roomWiseStudents.length,
                  itemBuilder: (context, index) {
                    String roomName = roomWiseStudents.keys.elementAt(index);
                    List<Map<String, dynamic>> studentsInRoom =
                        roomWiseStudents[roomName]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Room: $roomName',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        if (studentsInRoom.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'No students in this room.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ...studentsInRoom.map((child) {
                          DateTime birthDate =
                              DateTime.parse(child['date_of_birth'] ?? '');
                          int age = DateTime.now().year - birthDate.year;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: GestureDetector(
                              onTap: () => viewChildDetail(child['id']),
                              child: ScaleTransition(
                                scale: _animation,
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Display child image
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            child['image'] ??
                                                'https://via.placeholder.com/150',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.network(
                                                'https://via.placeholder.com/150',
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${child['first_name'] ?? ''} ${child['last_name'] ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'ID: ${child['unique_id'] ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Age: $age',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Gender: ${child['gender'] ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Fees: \$${child['child_fees'] ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSuperuser)
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.lightBlue),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditChildPage(
                                                          childId: child['id']),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
    );
  }

  void viewChildDetail(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ShowChildDetail(childId: childId)),
    );
  }
}
