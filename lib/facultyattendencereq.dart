import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FacultyAttendanceRequestsPage extends StatefulWidget {
  @override
  _FacultyAttendanceRequestsPageState createState() =>
      _FacultyAttendanceRequestsPageState();
}

class _FacultyAttendanceRequestsPageState
    extends State<FacultyAttendanceRequestsPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  late Stream<QuerySnapshot> _attendanceStream;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeAttendanceRequestsStream();
  }

  // Initialize local notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Initialize the Firestore stream for attendance requests
  void _initializeAttendanceRequestsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _attendanceStream = FirebaseFirestore.instance
          .collection('attendance_requests')
          .where('facultyId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  // Listen for new requests and send a notification
  void _listenForNewRequests() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('attendance_requests')
        .where('facultyId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          _sendNotification(doc.doc);
        }
      }
    });
  }

  Future<void> _sendNotification(DocumentSnapshot request) async {
    var androidDetails = const AndroidNotificationDetails(
      'attendance_request_channel',
      'Attendance Requests',
      channelDescription: 'New attendance request received',
      importance: Importance.max,
      priority: Priority.high,
    );

    var generalNotificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Attendance Request',
      'Request from ${request['studentName']} (${request['regno']})',
      generalNotificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Please log in first")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _attendanceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading requests"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No attendance requests available"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];

              // Ensure null safety for fields
              String studentName = doc['studentName'] ?? 'Unknown Student';
              String regNo = doc['regno'] ?? 'Unknown RegNo';
              String requestDetails = doc['request'] ?? 'No details provided';
              String imageUrl = doc['imageUrl'] ?? '';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    '$studentName ($regNo)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(requestDetails),
                      SizedBox(height: 10),
                      if (imageUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                content: Image.network(imageUrl),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 8),
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
