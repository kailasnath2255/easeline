import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AttendanceRequestPage extends StatefulWidget {
  @override
  _AttendanceRequestPageState createState() => _AttendanceRequestPageState();
}

class _AttendanceRequestPageState extends State<AttendanceRequestPage> {
  final TextEditingController _requestController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? selectedFaculty;
  List<Map<String, dynamic>> facultyList = [];
  String? studentName, regno;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    fetchFacultyList();
    fetchStudentInfo();
    _initializeNotifications();
  }

  Future<void> fetchFacultyList() async {
    try {
      QuerySnapshot facultySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Faculty')
          .get();

      setState(() {
        facultyList = facultySnapshot.docs
            .map((doc) => {
          'id': doc.id,
          'name': doc['name'],
          'email': doc['email'],
          'subject': doc['subject'],
        })
            .toList();
      });
    } catch (e) {
      print('Error fetching faculty list: $e');
    }
  }

  Future<void> fetchStudentInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          studentName = studentDoc['name'];
          regno = studentDoc['regno'];
        });
      }
    } catch (e) {
      print('Error fetching student info: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_requestController.text.isEmpty || selectedFaculty == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    try {
      String? imageUrl;
      if (_image != null) {
        String imagePath = 'attendance_requests/${DateTime.now().millisecondsSinceEpoch}.jpg';
        // Upload image to Firebase Storage (code here as an example)
        // Reference storageRef = FirebaseStorage.instance.ref().child(imagePath);
        // UploadTask uploadTask = storageRef.putFile(File(_image!.path));
        // TaskSnapshot snapshot = await uploadTask;
        // imageUrl = await snapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('attendance_requests').add({
        'request': _requestController.text,
        'facultyId': selectedFaculty,
        'studentId': FirebaseAuth.instance.currentUser?.uid,
        'studentName': studentName,
        'regno': regno,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Notify the faculty about the new request
      _sendNotificationToFaculty(selectedFaculty);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request submitted successfully.")));
      _requestController.clear();
      setState(() {
        _image = null;
        selectedFaculty = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error submitting request: $e")));
    }
  }

  Future<void> _sendNotificationToFaculty(String? facultyId) async {
    try {
      // Assuming faculty's notification token is stored in Firestore
      DocumentSnapshot facultyDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(facultyId)
          .get();

      String facultyName = facultyDoc['name'];
      String facultyEmail = facultyDoc['email'];

      // Sending a local notification
      var androidDetails = AndroidNotificationDetails(
        'attendance_request_channel',
        'Attendance Requests',
        channelDescription: 'Notifications for attendance requests',
        importance: Importance.max,
        priority: Priority.high,
      );

      var generalNotificationDetails =
      NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        0,
        'New Attendance Request',
        'You have a new attendance request from $studentName ($regno).',
        generalNotificationDetails,
        payload: 'attendance_request_payload',
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance Request")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _requestController,
              decoration: InputDecoration(
                labelText: "Type your request",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedFaculty,
              hint: Text("Select Faculty"),
              items: facultyList.map((faculty) {
                return DropdownMenuItem<String>(
                  value: faculty['id'],
                  child: Text(faculty['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFaculty = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload_file),
              label: Text("Upload Supporting Document"),
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(File(_image!.path))
                : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRequest,
              child: Text("Submit Request"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
