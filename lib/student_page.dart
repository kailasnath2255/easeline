import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'grievance_submission_page.dart';
import 'grievance_logs_page.dart';
import 'announcement_display.dart';
import 'student_profile.dart';
import 'ai_chat_bot_page.dart';
import 'aboutuspage.dart';
import 'contact.dart';
import 'package:flutter_apps/AttendanceHoldOnRequestPage.dart';

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  Map<String, dynamic>? studentInfo;
  bool isLoading = true;
  int _selectedIndex = 0; // Default to Home Page

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
  }

  // Fetch student info from Firestore
  Future<void> fetchStudentInfo() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot studentDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (studentDoc.exists) {
          setState(() {
            studentInfo = studentDoc.data() as Map<String, dynamic>?;
            isLoading = false;
          });
        } else {
          showMessage("Student data not found.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        showMessage("User not logged in.");
      }
    } catch (e) {
      showMessage("Error fetching student info: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Home Page UI with Emergency Button
  Widget _buildHomePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_logo.png', height: 100),
            SizedBox(height: 20),
            Text(
              "Welcome to EaseLine!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "EaseLine helps students submit grievances, view announcements, and get assistance through an AI chatbot.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text(
              "For extreme emergencies only:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Confirm Emergency"),
                    content: Text("Are you sure you want to send an emergency notification?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('emergency').add({
                            'studentId': FirebaseAuth.instance.currentUser?.uid,
                            'studentName': studentInfo?['name'] ?? 'Unknown',
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          Navigator.pop(context, true);
                          showMessage("Emergency notification sent.");
                        },
                        child: Text("Confirm"),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.warning, color: Colors.white),
              label: Text(
                "Send Emergency Alert",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Functions for Bottom Navigation Bar
  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return _buildHomePage(); // Home Page
      case 1:
        return GrievanceSubmissionPage(
          studentName: studentInfo?['name'] ?? 'N/A',
          studentRegNo: studentInfo?['regno'] ?? 'N/A',
          studentCourse: studentInfo?['course'] ?? 'N/A',
          studentSection: studentInfo?['section'] ?? 'N/A',
        );
      case 2:
        return AnnouncementListPage();
      case 3:
        return GrievanceLogsPage(
          studentId: FirebaseAuth.instance.currentUser?.uid ?? '',
        );
      case 4:
        return AIChatBotPage();
      default:
        return _buildHomePage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        elevation: 10,
        shadowColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
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
                  SizedBox(height: 10),
                  // Display Logged-in User's Name Below App Name
                  Text(
                    studentInfo?['name'] ?? 'Student Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudentProfilePage()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text('Submit Grievance'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('Announcements'),
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Grievance Logs'),
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Attendance Hold On'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttendanceRequestPage()),
              ),
            ),

            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About Us'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Contact & Support'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: logoutUser,
            ),
          ],
        ),
      ),
      body: _getScreen(_selectedIndex), // Display content based on bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: "Submit Grievance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: "Announcements",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Grievance Logs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "AI Chatbot",
          ),
        ],
      ),

    );
  }
}
