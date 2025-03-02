import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StudentGrievancesPage extends StatefulWidget {
  final String facultyName;

  StudentGrievancesPage({required this.facultyName});

  @override
  _StudentGrievancesPageState createState() => _StudentGrievancesPageState();
}

class _StudentGrievancesPageState extends State<StudentGrievancesPage> {
  TextEditingController _commentController = TextEditingController();
  bool isSubmittingComment = false;

  Future<QuerySnapshot> _fetchGrievances() async {
    return FirebaseFirestore.instance
        .collection('grievances')
        .where('recipient', isEqualTo: widget.facultyName)
        .orderBy('timestamp', descending: true)
        .get();
  }

  Future<void> _submitComment(String grievanceId) async {
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a comment")));
      return;
    }

    setState(() {
      isSubmittingComment = true;
    });

    try {
      String facultyName = widget.facultyName;

      await FirebaseFirestore.instance
          .collection('grievances')
          .doc(grievanceId)
          .collection('comments')
          .add({
        'facultyName': facultyName,
        'commentText': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Comment submitted successfully!")));
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting comment: $e")));
    } finally {
      setState(() {
        isSubmittingComment = false;
      });
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleMap(Map<String, dynamic> grievanceData) {
    if (grievanceData['location'] != null) {
      var latitude = grievanceData['location']['latitude'];
      var longitude = grievanceData['location']['longitude'];

      return Container(
        height: 200.0,
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 12,
            ),
            markers: {
              Marker(
                markerId: MarkerId('grievance_location'),
                position: LatLng(latitude, longitude),
              ),
            },
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Color _getGrievanceLevelColor(String level) {
    switch (level) {
      case 'Moderate':
        return Colors.yellow[700]!;
      case 'Serious':
        return Colors.orange[700]!;
      case 'Urgent':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grievances for Faculty: ${widget.facultyName}"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchGrievances(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching grievances"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No grievances found for this faculty",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var grievances = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: grievances.map((grievanceDoc) {
                var grievanceData =
                grievanceDoc.data() as Map<String, dynamic>;
                String grievanceId = grievanceDoc.id;

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Student Details",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueAccent),
                        ),
                        SizedBox(height: 10),
                        Text("Name: ${grievanceData['studentName']}",
                            style: TextStyle(fontSize: 16)),
                        Text("Reg No: ${grievanceData['studentRegNo']}",
                            style: TextStyle(fontSize: 16)),
                        Text("Course: ${grievanceData['studentCourse']}",
                            style: TextStyle(fontSize: 16)),
                        Text("Section: ${grievanceData['studentSection']}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text(
                          "Grievance Type: ${grievanceData['grievanceType']}",
                          style: TextStyle(
                              fontSize: 16, color: Colors.blueAccent),
                        ),
                        Text(
                          "Grievance Level: ${grievanceData['grievanceLevel']}",
                          style: TextStyle(
                              fontSize: 16,
                              color: _getGrievanceLevelColor(grievanceData['grievanceLevel'])),
                        ),
                        SizedBox(height: 10),
                        Text("Grievance Description:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(grievanceData['grievanceText'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        if (grievanceData['fileUrls'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Uploaded Files:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.from(grievanceData['fileUrls'])
                                    .map<Widget>((fileUrl) {
                                  return GestureDetector(
                                    onTap: () => _showFullImage(fileUrl),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: NetworkImage(fileUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        _buildGoogleMap(grievanceData),
                        SizedBox(height: 20),
                        Text(
                          "Comments:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue),
                        ),
                        SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('grievances')
                              .doc(grievanceId)
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, commentSnapshot) {
                            if (commentSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (commentSnapshot.hasError) {
                              return Center(
                                  child: Text("Error loading comments"));
                            }

                            var comments = commentSnapshot.data!.docs;

                            return Column(
                              children: comments.map((commentDoc) {
                                var commentData =
                                commentDoc.data() as Map<String, dynamic>;
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          commentData['facultyName'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(commentData['commentText']),
                                        SizedBox(height: 5),
                                        Text(
                                          "Posted at: ${commentData['timestamp']?.toDate()}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Text("Add a Comment",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Write your comment here...",
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                          ),
                        ),
                        SizedBox(height: 10),
                        isSubmittingComment
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                          onPressed: () => _submitComment(grievanceId),
                          child: Text("Submit Comment"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
