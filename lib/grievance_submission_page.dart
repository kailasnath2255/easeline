import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class GrievanceSubmissionPage extends StatefulWidget {
  final String studentName;
  final String studentRegNo;
  final String studentCourse;
  final String studentSection;

  GrievanceSubmissionPage({
    required this.studentName,
    required this.studentRegNo,
    required this.studentCourse,
    required this.studentSection,
  });

  @override
  _GrievanceSubmissionPageState createState() =>
      _GrievanceSubmissionPageState();
}

class _GrievanceSubmissionPageState extends State<GrievanceSubmissionPage> {
  final TextEditingController _grievanceController = TextEditingController();
  String grievanceType = "General"; // Default grievance type
  String grievanceLevel = "Moderate"; // Default grievance level
  String? selectedRecipientType; // For recipient type selection (HOD, Volunteers, All Faculties, Specific Faculty)
  String? selectedFaculty; // For faculty selection
  bool includeLocation = false; // For location option
  List<File> uploadedFiles = [];
  bool isSubmitting = false;
  Position? userLocation;
  List<String> facultyList = [];

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchFacultyList();
    if (includeLocation) {
      getUserLocation();
    }
  }

  // Fetch faculty list from Firestore
  Future<void> fetchFacultyList() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Faculty')
          .get();

      setState(() {
        facultyList = querySnapshot.docs
            .map((doc) => doc['name'] as String)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error fetching faculty list: $e"),
      ));
    }
  }

  // Get user location
  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Location services are disabled. Please enable them in the device settings."),
      ));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Location permission is denied. Please enable it."),
        ));
        return;
      }
    }

    userLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Handle image selection
  Future<void> pickFiles() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploadedFiles.add(File(pickedFile.path));
      });
    }
  }

  // Retry mechanism for uploading files
  Future<String> uploadFileWithRetry(File file, String fileName, int retryCount) async {
    try {
      if (!file.existsSync()) {
        throw Exception('File does not exist');
      }

      final fileSize = file.lengthSync();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File size is too large');
      }

      final UploadTask uploadTask = FirebaseStorage.instance.ref().child(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw Exception("Upload failed");
      }
    } catch (e) {
      if (retryCount < 3) {
        await Future.delayed(Duration(seconds: 2));
        return await uploadFileWithRetry(file, fileName, retryCount + 1);
      } else {
        throw Exception("Upload failed after multiple attempts: $e");
      }
    }
  }

  // Submit grievance
  Future<void> _submitGrievance() async {
    String grievanceText = _grievanceController.text.trim();

    if (grievanceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter your grievance before submitting."),
      ));
      return;
    }

    if (selectedRecipientType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please select a recipient type."),
      ));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Upload files to Firebase Storage
      List<String> uploadedFileUrls = [];
      for (File file in uploadedFiles) {
        if (file.existsSync()) {
          String fileName = 'grievances/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
          String fileUrl = await uploadFileWithRetry(file, fileName, 0);
          uploadedFileUrls.add(fileUrl);
        }
      }

      // Save grievance to Firestore
      User? currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('grievances').add({
        'studentId': currentUser?.uid,
        'studentName': widget.studentName,
        'studentRegNo': widget.studentRegNo,
        'studentCourse': widget.studentCourse,
        'studentSection': widget.studentSection,
        'grievanceType': grievanceType,
        'grievanceLevel': grievanceLevel,
        'grievanceText': grievanceText,
        'recipientType': selectedRecipientType,
        'recipient': selectedRecipientType == 'Specific Faculty' ? selectedFaculty : selectedRecipientType,
        'fileUrls': uploadedFileUrls,
        'location': includeLocation && userLocation != null
            ? {'latitude': userLocation!.latitude, 'longitude': userLocation!.longitude}
            : null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Grievance submitted successfully!"),
      ));

      // Clear the form
      _grievanceController.clear();
      setState(() {
        grievanceType = "General";
        grievanceLevel = "Moderate";
        selectedRecipientType = null;
        selectedFaculty = null;
        uploadedFiles.clear();
        includeLocation = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error submitting grievance: $e"),
      ));
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Grievance Submission"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Student Info
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Student Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 10),
                    Text("Name: ${widget.studentName}", style: TextStyle(fontSize: 16)),
                    Text("Reg No: ${widget.studentRegNo}", style: TextStyle(fontSize: 16)),
                    Text("Course: ${widget.studentCourse}", style: TextStyle(fontSize: 16)),
                    Text("Section: ${widget.studentSection}", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Grievance Type
            Text("Grievance Type", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: grievanceType,
              onChanged: (String? newValue) {
                setState(() {
                  grievanceType = newValue!;
                });
              },
              items: <String>['General', 'Academic', 'Facility', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
            SizedBox(height: 20),

            // Grievance Level
            Text("Grievance Level", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['Moderate', 'Serious', 'Urgent'].map((level) {
                return ChoiceChip(
                  label: Text(level),
                  selected: grievanceLevel == level,
                  onSelected: (bool selected) {
                    setState(() {
                      grievanceLevel = level;
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Grievance Description
            Text("Describe Your Grievance", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _grievanceController,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Describe your grievance here...",
              ),
            ),
            SizedBox(height: 20),

            // File Upload
            Text("Upload Supporting Files", style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton(onPressed: pickFiles, child: Text("Upload Files")),
            Wrap(
              spacing: 8,
              children: uploadedFiles.map((file) {
                return Chip(label: Text(file.path.split('/').last));
              }).toList(),
            ),
            SizedBox(height: 20),

            // Recipient Type Selection
            Text("Select Recipient Type", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedRecipientType,
              hint: Text("Select Recipient Type"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedRecipientType = newValue;
                });
              },
              items: <String>['HOD', 'Volunteers', 'All Faculties', 'Specific Faculty']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
            ),
            SizedBox(height: 20),

            // Specific Faculty Dropdown (Visible only if 'Specific Faculty' is selected)
            if (selectedRecipientType == 'Specific Faculty') ...[
              Text("Select Faculty", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedFaculty,
                hint: Text("Select Faculty"),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFaculty = newValue;
                  });
                },
                items: facultyList.map<DropdownMenuItem<String>>((String name) {
                  return DropdownMenuItem<String>(value: name, child: Text(name));
                }).toList(),
              ),
            ],
            SizedBox(height: 20),

            // Include Location
            Row(
              children: [
                Checkbox(
                  value: includeLocation,
                  onChanged: (bool? value) {
                    setState(() {
                      includeLocation = value ?? false;
                      if (includeLocation) {
                        getUserLocation();
                      }
                    });
                  },
                ),
                Text("Include Location"),
              ],
            ),
            SizedBox(height: 20),

            // Submit Button
            isSubmitting
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _submitGrievance,
              child: Text("Submit Grievance"),
            ),
          ],
        ),
      ),
    );
  }
}
