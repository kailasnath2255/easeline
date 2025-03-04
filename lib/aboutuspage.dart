import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("About EaseLine"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            _buildAppLogoSection(),
            SizedBox(height: 30),
            _buildHowWeHelpSection(),
            SizedBox(height: 30),
            _buildTestimonialsSection(),
            SizedBox(height: 30),
            _buildDeveloperTeamSection(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogoSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            "assets/images/app_logo.png",
            width: 120,
            height: 120,
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "EaseLine - Your Grievance Management Solution",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            "EaseLine is an AI-powered grievance management system designed for students and faculty at Christ University. It ensures a seamless and transparent way to address grievances efficiently.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: Text("Learn More", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildHowWeHelpSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            "How We Help People",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "With AI-powered grievance handling, real-time tracking, and a structured complaint resolution system, EaseLine makes student well-being a priority.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Text(
            "User Testimonials",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildTestimonialCard("Reshma ", "EaseLine has made grievance handling seamless and student-friendly. Highly recommended!"),
          _buildTestimonialCard("Devi", "A truly revolutionary grievance management system. The tracking ensures quick resolutions."),
          _buildTestimonialCard("Suresh", "EaseLine has transformed how we handle complaints at Christ University. The process is efficient and transparent."),
        ],
      ),
    );
  }

  Widget _buildDeveloperTeamSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            "Meet Our Team",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDeveloperCard("Kailas Nath S", "Developer", "assets/images/student.png"),
              _buildDeveloperCard("Rashmitha Sevi", "Designer", "assets/images/student.png"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(String name, String feedback) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedback,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                SizedBox(width: 10),
                Text(
                  name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(String name, String role, String imagePath) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              imagePath,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 5),
          Text(
            role,
            style: TextStyle(fontSize: 14, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
