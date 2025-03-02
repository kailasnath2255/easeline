import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Student Profile"),
        elevation: 5,
        shadowColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : studentInfo == null
          ? Center(child: Text("No student data available."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Student Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/student.png'),
            ),
            SizedBox(height: 20),

            // Student Name
            Text(
              studentInfo!['name'] ?? 'Student',
              style: TextStyle(
                fontSize: 26,
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
              shadowColor: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildDetailTile(
                      "Email",
                      studentInfo!['email'] ?? 'N/A',
                      Icons.email,
                    ),
                    Divider(),
                    buildDetailTile(
                      "Course",
                      studentInfo!['course'] ?? 'N/A',
                      Icons.book,
                    ),
                    Divider(),
                    buildDetailTile(
                      "Registration No",
                      studentInfo!['regno'] ?? 'N/A',
                      Icons.confirmation_num,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
