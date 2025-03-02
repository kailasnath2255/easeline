import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> submitAnnouncement() async {
    String heading = _headingController.text.trim();
    String content = _contentController.text.trim();
    if (heading.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    try {
      String imageUrl = '';

      if (_image != null) {
        // Upload the image to Firebase Storage
        Reference storageRef = FirebaseStorage.instance.ref().child('announcements/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageRef.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Add the announcement details to Firestore
      await FirebaseFirestore.instance.collection('announcements').add({
        'heading': heading,
        'content': content,
        'imageUrl': imageUrl, // Store the image URL if an image was uploaded
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement submitted successfully')));
      _headingController.clear();
      _contentController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting announcement: $e')));
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
              'assets/images/app_logo.png', // Make sure to add your app logo here
              height: 40,
            ),
            SizedBox(width: 10),
            Text("EaseLine", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading Section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Make Announcement',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),

            // Heading TextField
            TextField(
              controller: _headingController,
              decoration: InputDecoration(
                labelText: 'Announcement Heading',
                labelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Content TextField
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Announcement Content',
                labelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Image Picker Section
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: pickImage,
                  icon: Icon(Icons.add_a_photo),
                  label: Text('Pick Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Correct way to set the background color
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                if (_image != null)
                  Text(
                    'Image selected',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            SizedBox(height: 16),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: submitAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Correct way to set the background color
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit Announcement',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
