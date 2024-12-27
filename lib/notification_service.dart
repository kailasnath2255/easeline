import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static Future<void> sendEmergencyNotification() async {
    try {
      QuerySnapshot facultySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'faculty')
          .get();

      for (var doc in facultySnapshot.docs) {
        String? token = doc['fcmToken'];
        if (token != null) {
          print("Notification sent to faculty with token: $token");
          // Use FCM or another service to send the notification
        }
      }
    } catch (e) {
      throw Exception("Error sending notification: $e");
    }
  }
}
