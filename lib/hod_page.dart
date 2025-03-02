import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'announcement_page.dart'; // Import the page for making announcements
import 'announcement_display.dart'; // Import the page for viewing announcements

class HODPage extends StatefulWidget {
  @override
  _HODPageState createState() => _HODPageState();
}

class _HODPageState extends State<HODPage> {
  late Stream<QuerySnapshot> emergencyStream;
  Map<String, dynamic>? hodInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    emergencyStream = FirebaseFirestore.instance
        .collection('emergency')
        .orderBy('timestamp', descending: true)
        .snapshots();
    fetchHODInfo();
  }

  Future<void> fetchHODInfo() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot hodDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (hodDoc.exists) {
          setState(() {
            hodInfo = hodDoc.data() as Map<String, dynamic>?; // Update HOD info
            isLoading = false;
          });
        } else {
          showMessage("HOD data not found.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        showMessage("User not logged in.");
      }
    } catch (e) {
      showMessage("Error fetching HOD info: $e");
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

  void navigateToAnnouncementPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementPage(), // Navigate to Announcement Page
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
              leading: Icon(Icons.announcement),
              title: Text('Make Announcement'),
              onTap: navigateToAnnouncementPage, // Redirect to announcement page
            ),
            ListTile(
              leading: Icon(Icons.view_list),
              title: Text('View Announcements'),
              onTap: navigateToViewAnnouncements, // Redirect to view announcements page
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
              "HOD Information",
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
                    buildDetailTile("Name", hodInfo?['name'] ?? 'N/A', Icons.person),
                    buildDetailTile("Email", hodInfo?['email'] ?? 'N/A', Icons.email),
                    buildDetailTile("Faculty ID", hodInfo?['facultyid'] ?? 'N/A', Icons.badge),
                    buildDetailTile("Department", hodInfo?['department'] ?? 'N/A', Icons.business),
                    buildDetailTile("Role", hodInfo?['role'] ?? 'N/A', Icons.star),
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
