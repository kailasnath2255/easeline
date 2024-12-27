import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'student_grevances.dart'; // Correct import for the grievances page

class FacultyPage extends StatefulWidget {
  @override
  _FacultyPageState createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  late Stream<QuerySnapshot> emergencyStream;
  Map<String, dynamic>? facultyInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    emergencyStream = FirebaseFirestore.instance
        .collection('emergency')
        .orderBy('timestamp', descending: true)
        .snapshots();
    fetchFacultyInfo();
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
            Text(
              "Faculty Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailTile("Name", facultyInfo?['name'] ?? 'N/A', Icons.person),
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
    );
  }

  Widget buildDetailTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value),
    );
  }
}
