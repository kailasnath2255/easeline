import 'package:flutter/material.dart';

class AIChatBotPage extends StatefulWidget {
  @override
  _AIChatBotPageState createState() => _AIChatBotPageState();
}

class _AIChatBotPageState extends State<AIChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final Map<String, String> botResponses = {
    // Greetings
    "hi": "Hey there! 👋 I’m EaseLine’s assistant. What can I help you with today?\n\nTry asking:\n"
        "- How do I submit a grievance?\n"
        "- What are the different grievance categories?\n"
        "- How long does it take to resolve an issue?",

    "hai": "Hello! 😊 I’m here to assist you with your grievances. Need help?\n\nYou can ask:\n"
        "- Can I track my grievance status?\n"
        "- How do I contact support?\n"
        "- What if my issue is not resolved?",

    "hello": "Hi there! How’s your day going? 😊 Let me know how I can assist you.\n\nYou can ask me:\n"
        "- How do I submit a grievance?\n"
        "- What are the different grievance categories?",

    "hey": "Hey! 😊 Need assistance with EaseLine? I’m here to help.\n\nTry asking:\n"
        "- Where can I find my grievances?\n"
        "- Can I edit my submitted grievance?",

    "good morning": "Good morning! ☀️ I hope you have a great day ahead! How can I assist you?\n\nYou might want to ask:\n"
        "- How do I submit a grievance?\n"
        "- How long does it take to resolve an issue?",

    "good afternoon": "Good afternoon! 🌞 Need help with something?\n\nTry asking:\n"
        "- What are the different grievance categories?\n"
        "- Can I track my grievance status?",

    "good evening": "Good evening! 🌙 How can I support you today?\n\nYou can ask me:\n"
        "- How do I contact support?\n"
        "- Can I edit my submitted grievance?",

    "good night": "Good night! 🌙 If you need assistance, feel free to ask anytime. Here are some things I can help with:\n"
        "- Submitting a grievance\n"
        "- Tracking grievances\n"
        "- Contacting support",

    // General Assistance
    "how are you?": "I’m always here and ready to help! 😊 What can I assist you with?\n\nYou can ask me:\n"
        "- How do I submit a grievance?\n"
        "- Can I track my grievance status?",

    "what can you do?": "I can assist you with grievance submission, tracking, and general queries about the EaseLine app.\n\nTry asking:\n"
        "- What if my issue is not resolved?\n"
        "- Can I contact support?\n"
        "- How long does it take to resolve an issue?",

    "help": "Of course! What do you need help with? 😊 You can ask about:\n"
        "- Submitting a grievance\n"
        "- Tracking a grievance\n"
        "- Contacting support",

    "what is EaseLine?": "EaseLine is an AI-powered grievance management system designed for Christ University students and faculty. It helps in resolving grievances quickly and efficiently.\n\nTry asking:\n"
        "- How do I submit a grievance?\n"
        "- Can I escalate an unresolved grievance?",

    // Grievance Submission & Tracking
    "how do i submit a grievance?": "Submitting a grievance is simple! 📝 Just go to the 'Submit Grievance' section in the EaseLine app, provide the necessary details, and submit it.\n\nWant to know more?\n"
        "- What are the grievance categories?\n"
        "- How long does it take to resolve an issue?",

    "where can i find my grievances?": "You can find your submitted grievances in the 'My Grievances' section of the app. 📋\n\nNeed more help?\n"
        "- Can I edit my submitted grievance?\n"
        "- Can I track my grievance status?",

    "can i track my grievance status?": "Yes! ✅ Just head to the 'My Grievances' section in the app to see real-time updates on your grievance.\n\nWant to know more?\n"
        "- How long does it take to resolve an issue?\n"
        "- What if my issue is not resolved?",

    "how long does it take to resolve an issue?": "⏳ Most grievances are resolved within 3-5 working days. However, complex cases might take longer.\n\nYou might also want to ask:\n"
        "- Can I escalate an unresolved grievance?\n"
        "- How do I contact support?",

    "what if my issue is not resolved?": "If your grievance is not resolved within the given time, you can escalate it through the 'Escalate Grievance' button in the app. 🚀\n\nWant to know more?\n"
        "- Can I contact support?\n"
        "- Can I edit my submitted grievance?",

    "can i edit my submitted grievance?": "Yes, you can edit your grievance within 24 hours of submission in the 'My Grievances' section. ✏️\n\nLooking for something else?\n"
        "- Can I track my grievance status?\n"
        "- What if my issue is not resolved?",

    // Grievance Categories
    "what are the different grievance categories?": "EaseLine supports various grievance categories:\n"
        "- 📚 Academic Issues\n"
        "- 🏡 Hostel Complaints\n"
        "- 🏢 Administration Issues\n"
        "- 🖥️ Technical Problems\n\nWhich category do you need help with?\n"
        "- Academic Issues\n"
        "- Hostel Complaints\n"
        "- Technical Problems",

    "academic issues": "For academic issues, please provide details about your concern, such as course name, faculty, and specific problems you are facing. 📖\n\nNeed more help?\n"
        "- How do I submit a grievance?\n"
        "- Can I track my grievance status?",

    "hostel complaints": "For hostel-related complaints, mention your block name, room number, and the nature of the issue. 🏡\n\nWant to explore more?\n"
        "- How do I submit a grievance?\n"
        "- How long does it take to resolve an issue?",

    "technical problems": "If you’re facing technical issues with the app or university systems, describe the problem so we can assist you. 💻\n\nYou might also want to ask:\n"
        "- Can I contact support?\n"
        "- What if my issue is not resolved?",

    // Contact & Support
    "how do i contact support?": "You can reach out to our support team via the 'Help & Support' section in the EaseLine app or email us at support@easeline.com. 📧\n\nNeed help with something else?\n"
        "- Can I escalate an unresolved grievance?\n"
        "- Can I track my grievance status?",

    "is there a customer support number?": "Currently, you can contact our support team via the app or email. Phone support will be available soon!\n\nMeanwhile, you can ask:\n"
        "- Can I escalate my grievance?\n"
        "- How do I submit a grievance?",

    // Friendly Conversations
    "thank you": "You're welcome! 😊 If you need more help, just ask!\n\nHere are some things you might want to explore:\n"
        "- How do I submit a grievance?\n"
        "- What are the grievance categories?",

    "thanks": "No problem! Glad to help. Have a great day! 😃\n\nIf you need anything else, just ask!",

    "bye": "Goodbye! 👋 Have a great day ahead!\n\nIf you ever need help, I’m here!",

    "see you": "See you soon! 😊 Need help before you go?\n"
        "- Can I track my grievance?\n"
        "- How do I contact support?",

    // Default Response for Unrecognized Queries
    "default": "I’m not sure how to respond to that. 🤔 Try asking about grievance submission, tracking, or categories!"
  };


  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"user": message});
    });

    _messageController.clear();

    // Get response from predefined map with a default fallback
    String botReply = botResponses[message.toLowerCase()] ?? botResponses["default"]!;

    // Delay response for a natural feel
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({"ai": botReply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EaseLine AI Chat Bot"),
        backgroundColor: Colors.white70,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.containsKey("user");
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isUser ? message["user"]! : message["ai"]!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () => sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
