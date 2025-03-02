import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  double _rating = 0; // Stores the user's rating

  // Function to launch different intents
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open: $url")),
      );
    }
  }

  // Function to make a phone call
  void _makeCall() {
    _launchURL("tel:+918888888888"); // Replace with your phone number
  }

  // Function to send an email
  void _sendEmail() {
    _launchURL("mailto:support@easeline.com?subject=Support Request");
  }

  // Function to open WhatsApp chat
  void _openWhatsApp() {
    _launchURL("https://wa.me/918888888888"); // Replace with your WhatsApp number
  }

  // Function to send an SMS
  void _sendSMS() {
    _launchURL("sms:+918888888888?body=Hello, I need assistance.");
  }

  // Function to share the app link
  void _shareApp() {
    Share.share("Check out EaseLine: Your AI-powered grievance management system! Download here: https://easeline.com");
  }

  // Function to open website
  void _openWebsite() {
    _launchURL("https://www.easeline.com");
  }

  // Rating Dialog
  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rate EaseLine"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Tap the stars to rate"),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog before updating state
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Contact Us"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Contact Us Header
              Text(
                "Get in Touch",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 10),
              Text(
                "We'd love to hear from you! Reach out to us through any of the following ways.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),

              // Contact Options
              _buildContactCard(Icons.call, "Call Us", "Talk to our support team", _makeCall),
              _buildContactCard(Icons.email, "Email Us", "Send us your queries", _sendEmail),
              _buildContactCard(Icons.language, "Visit Website", "Learn more about EaseLine", _openWebsite),
              _buildContactCard(Icons.message, "SMS Support", "Quick assistance via SMS", _sendSMS),
              _buildContactCard(Icons.share, "Share Our App", "Tell your friends about EaseLine", _shareApp),
              _buildContactCard(Icons.chat, "WhatsApp", "Chat with our support team", _openWhatsApp),

              SizedBox(height: 30),

              // Rating & Feedback Section
              Text(
                "Rate & Feedback",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 10),
              Text("Help us improve by providing your feedback!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black87)),
              SizedBox(height: 10),

              // Rating Stars
              GestureDetector(
                onTap: _showRatingDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 35,
                    );
                  }),
                ),
              ),
              SizedBox(height: 20),

              // Feedback Text Field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write your feedback here...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Submit Feedback Button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Thank you for your feedback!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text("Submit Feedback", style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Function to create a Contact Card
  Widget _buildContactCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black54)),
        onTap: onTap,
      ),
    );
  }
}
