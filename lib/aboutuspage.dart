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
            // Hero Section
            Stack(
              alignment: Alignment.center,
              children: [

                Column(
                  children: [
                    SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/app_logo.png", // Add the logo in assets
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
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text("Learn More", style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),

            // How We Help People Section
            Padding(
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
                  SizedBox(height: 30),
                ],
              ),
            ),

            // Testimonials Section
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  _buildTestimonialCard("May Smith", "EaseLine has transformed how we handle complaints at Christ University. The process is efficient and transparent."),
                  _buildTestimonialCard("Bob Perry", "A truly revolutionary grievance management system. The AI-powered tracking ensures quick resolutions."),
                  _buildTestimonialCard("Marry Hudson", "EaseLine has made grievance handling seamless and student-friendly. Highly recommended!"),
                ],
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Testimonial Card Widget
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
}
