import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'login_page.dart';
import 'student_grevances.dart'; // Correct import for the grievances page
import 'announcement_display.dart';
import 'ai_chat_bot_page.dart';
import 'aboutuspage.dart';
import 'contact.dart';
import 'facultyattendencereq.dart';
// Import the page for viewing announcements

class FacultyPage extends StatefulWidget {
  @override
  _FacultyPageState createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  late Stream<QuerySnapshot> emergencyStream;
  Map<String, dynamic>? facultyInfo;
  bool isLoading = true;

  // Notification variables
  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  int _selectedIndex = 0; // Track selected index for BottomNavigationBar

  @override
  void initState() {
    super.initState();
    emergencyStream = FirebaseFirestore.instance
        .collection('emergency')
        .orderBy('timestamp', descending: true)
        .snapshots();

    fetchFacultyInfo();
    initializeNotifications();
  }

  // Initialize Firebase Cloud Messaging and local notifications
  void initializeNotifications() {
    _firebaseMessaging = FirebaseMessaging.instance;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Request notification permission for iOS
    _firebaseMessaging.requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(message.notification!);
      }
    });

    // Handle background and terminated state notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tapped logic here
    });
  }

  // Show local notification when an emergency is received
  Future<void> showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      notificationDetails,
      payload: 'emergency_payload',
    );
  }

  Future<void> fetchFacultyInfo() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot facultyDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (facultyDoc.exists) {
          setState(() {
            facultyInfo = facultyDoc.data() as Map<String, dynamic>?; // Update faculty info
            isLoading = false;
          });
        } else {
          showMessage("Faculty data not found.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        showMessage("User not logged in.");
      }
    } catch (e) {
      showMessage("Error fetching faculty info: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to login
    );
  }

  void navigateToStudentGrevances() {
    // Pass the faculty name to StudentGrievancesPage
    String facultyName = facultyInfo?['name'] ?? 'N/A';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentGrievancesPage(facultyName: facultyName), // Passing faculty name
      ),
    );
  }

  void navigateToViewAnnouncements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementListPage(), // Navigate to Announcement Display Page
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        navigateToStudentGrevances();
        break;
      case 1:
        navigateToViewAnnouncements();
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FacultyAttendanceRequestsPage(), // Attendance Request Page
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text("EaseLine"),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    height: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "EaseLine",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Student Grievances'),
              onTap: navigateToStudentGrevances, // Redirect to student grievances page
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('View Announcements'),
              onTap: navigateToViewAnnouncements, // Redirect to view announcements page
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Attendance Request'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FacultyAttendanceRequestsPage()),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About Us'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Contact & Support'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: logoutUser,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/kns.jpeg'), // Profile picture
            ),
            SizedBox(height: 20),
            Text(
              facultyInfo?['name'] ?? 'Faculty Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailTile("Email", facultyInfo?['email'] ?? 'N/A', Icons.email),
                    buildDetailTile("Faculty ID", facultyInfo?['facultyid'] ?? 'N/A', Icons.badge),
                    buildDetailTile("Course", facultyInfo?['course'] ?? 'N/A', Icons.book),
                    buildDetailTile("Subject", facultyInfo?['subject'] ?? 'N/A', Icons.school),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Emergency Notifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: emergencyStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No emergency notifications."));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;

                      // Check timestamp validity (5 hours)
                      DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
                      if (DateTime.now().difference(timestamp).inHours > 5) {
                        FirebaseFirestore.instance
                            .collection('emergency')
                            .doc(doc.id)
                            .delete();
                        return SizedBox.shrink();
                      }

                      // Trigger notification when an emergency is received
                      FirebaseMessaging.instance
                          .subscribeToTopic("faculty_${facultyInfo?['facultyid']}");

                      return Card(
                        color: Colors.red[50],
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Icon(Icons.warning, color: Colors.red),
                          title: Text("Emergency from: ${data['studentName'] ?? 'Unknown'}"),
                          subtitle: Text(
                            "Time: ${timestamp.toString()}",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Student Grievances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'View Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Attendance Request',
          ),
        ],
      ),
    );
  }

  Widget buildDetailTile(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 10),
        Text(
          "$title:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
