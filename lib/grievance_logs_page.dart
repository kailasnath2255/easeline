import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting the date and time
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GrievanceLogsPage extends StatefulWidget {
  final String studentId; // Pass the studentId from the logged-in student

  GrievanceLogsPage({required this.studentId});

  @override
  _GrievanceLogsPageState createState() => _GrievanceLogsPageState();
}

class _GrievanceLogsPageState extends State<GrievanceLogsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Row(
          children: [
            SizedBox(width: 10),
            Text(
              "Grievance Logs",
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('grievances')
              .where('studentId', isEqualTo: widget.studentId)
          // Order by recipient and timestamp as per index
              .orderBy('recipient')
              .orderBy('timestamp', descending: true)
              .orderBy('__name__', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            // Show loading spinner while fetching data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Handle errors
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error fetching grievance logs: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            // Check if there is data
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No grievance logs found.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            // Get the list of grievances
            final grievances = snapshot.data!.docs;

            return ListView.builder(
              itemCount: grievances.length,
              itemBuilder: (ctx, index) {
                final grievance = grievances[index];

                // Safely access fields to avoid runtime errors
                final grievanceText = grievance['grievanceText'] ?? '';
                final grievanceLevel = grievance['grievanceLevel'] ?? '';
                final facultyName = grievance['recipient'] ?? 'Unknown Faculty';
                final timestamp =
                    (grievance['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                final formattedDate =
                DateFormat('yyyy-MM-dd – hh:mm a').format(timestamp);

                // Location for Google Maps
                final location = grievance['location'];
                double? latitude, longitude;
                if (location != null) {
                  latitude = location['latitude'];
                  longitude = location['longitude'];
                }

                // Image URLs (fileUrls) stored in Firestore
                final fileUrls = List<String>.from(grievance['fileUrls'] ?? []);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grievance Details
                        Text(
                          'Grievance Submitted on: $formattedDate',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 8),

                        // Grievance Text
                        Text(
                          'Grievance: $grievanceText',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(height: 12),

                        // Grievance Level
                        Text(
                          'Level: $grievanceLevel',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 12),

                        // Display images from fileUrls
                        if (fileUrls.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: fileUrls.map((url) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      url,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Location for Google Map
                        if (latitude != null && longitude != null)
                          Container(
                            height: 250.0,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueAccent, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
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
                          ),

                        // Displaying Faculty Responses (Comments)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('grievances')
                              .doc(grievance.id) // Reference the specific grievance
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (ctx, commentSnapshot) {
                            if (commentSnapshot.connectionState == ConnectionState.waiting) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (commentSnapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Center(
                                  child: Text('Error loading comments: ${commentSnapshot.error}'),
                                ),
                              );
                            }

                            final comments = commentSnapshot.data?.docs ?? [];

                            if (comments.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  'No comments from the faculty.',
                                  style: TextStyle(fontSize: 14, color: Colors.orange),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: comments.map((comment) {
                                  final commentText = comment['commentText'] ?? 'No comment';
                                  final facultyName = comment['facultyName'] ?? 'Unknown Faculty';
                                  final commentTimestamp =
                                  (comment['timestamp'] as Timestamp?)?.toDate();
                                  final formattedCommentDate = commentTimestamp != null
                                      ? DateFormat('yyyy-MM-dd – hh:mm a').format(commentTimestamp)
                                      : 'Unknown Date';

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Faculty: $facultyName',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.green[700]),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Comment: $commentText',
                                          style: TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Commented on: $formattedCommentDate',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
