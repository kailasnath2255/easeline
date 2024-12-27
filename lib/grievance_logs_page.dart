import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting the date and time

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
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            Image.asset(
              'assets/images/app_logo.png', // Add the path to your logo here
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              "Grievance Logs",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              .orderBy('timestamp', descending: true)
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
                final facultyReply = grievance['facultyReply'] ?? '';
                final facultyName = grievance['facultyName'] ?? 'Unknown Faculty';
                final timestamp =
                    (grievance['timestamp'] as Timestamp?)?.toDate() ??
                        DateTime.now();
                final formattedDate =
                DateFormat('yyyy-MM-dd – hh:mm a').format(timestamp);

                // Faculty reply timestamp
                final replyTimestamp =
                (grievance['replyTimestamp'] as Timestamp?)?.toDate();
                final formattedReplyDate = replyTimestamp != null
                    ? DateFormat('yyyy-MM-dd – hh:mm a')
                    .format(replyTimestamp)
                    : 'Not yet replied';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

                        // Faculty Response Details
                        if (facultyReply.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Faculty Response from: $facultyName',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Reply: $facultyReply',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Replied on: $formattedReplyDate',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        // No reply yet
                        if (facultyReply.isEmpty)
                          Text(
                            'No reply yet from the faculty.',
                            style: TextStyle(
                                fontSize: 14, color: Colors.orange),
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
