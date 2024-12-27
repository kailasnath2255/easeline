import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart'; // Import the login_page.dart
import 'grievance_submission_page.dart'; // Import the new GrievanceSubmissionPage
import 'grievance_logs_page.dart'; //import grevancelogspage
class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  Map<String, dynamic>? studentInfo;
  bool isLoading = true;

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

  // Send emergency notification
  Future<void> sendEmergencyNotification() async {
    try {
      await FirebaseFirestore.instance.collection('emergency').add({
        'studentId': FirebaseAuth.instance.currentUser?.uid,
        'studentName': studentInfo?['name'] ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });
      showMessage("Emergency notification sent.");
    } catch (e) {
      showMessage("Error sending emergency notification: $e");
    }
  }

  // Logout functionality
  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to Login Page
    );
  }

  // Navigate to Grievance Submission page with student details
  void navigateToGrievanceSubmission() {
    if (studentInfo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrievanceSubmissionPage(
            studentName: studentInfo!['name'] ?? 'N/A',
            studentRegNo: studentInfo!['regno'] ?? 'N/A',
            studentCourse: studentInfo!['course'] ?? 'N/A',
            studentSection: studentInfo!['section'] ?? 'N/A',
          ),
        ),
      );
    } else {
      showMessage("Student information is not available.");
    }
  }

  //navigate to grevance logs
  void navigateToGrievancelogs() {
    if (studentInfo != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrievanceLogsPage(
            studentId: FirebaseAuth.instance.currentUser?.uid ?? '',

          ),
        ),
      );
    } else {
      showMessage("Student information is not available.");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text('Grievance Submission'),
              onTap: navigateToGrievanceSubmission,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Grievance Logs'),
              onTap: navigateToGrievancelogs,
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
          : studentInfo == null
          ? Center(child: Text("No student data available."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Section with Welcome Text
            Text(
              "Welcome, ${studentInfo!['name'] ?? 'Student'}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),

            // Student Details Card
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
                    buildDetailTile(
                      "Full Name",
                      studentInfo!['name'] ?? 'N/A',
                      Icons.person,
                    ),
                    buildDetailTile(
                      "Email",
                      studentInfo!['email'] ?? 'N/A',
                      Icons.email,
                    ),
                    buildDetailTile(
                      "Date of Birth",
                      studentInfo!['DOB'] ?? 'N/A',
                      Icons.calendar_today,
                    ),
                    buildDetailTile(
                      "Course",
                      studentInfo!['course'] ?? 'N/A',
                      Icons.book,
                    ),
                    buildDetailTile(
                      "Section",
                      studentInfo!['section'] ?? 'N/A',
                      Icons.group,
                    ),
                    buildDetailTile(
                      "Registration No",
                      studentInfo!['regno'] ?? 'N/A',
                      Icons.confirmation_num,
                    ),
                    buildDetailTile(
                      "Role",
                      studentInfo!['role'] ?? 'N/A',
                      Icons.school,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Emergency Button with Styled Appearance
            ElevatedButton(
              onPressed: sendEmergencyNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Emergency",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
    );
  }

}
