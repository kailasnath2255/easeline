import 'package:flutter/material.dart';

class AIChatBotPage extends StatefulWidget {
  @override
  _AIChatBotPageState createState() => _AIChatBotPageState();
}

class _AIChatBotPageState extends State<AIChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];

  // Bot predefined responses
  final Map<String, String> botResponses = {
    "hai": "Hey there! I’m EaseLine’s assistant. How can I help? Here are some things you can ask me:\n"
        "- How do I submit a grievance?\n"
        "- What are the different grievance categories?\n"
        "- How long does it take to resolve an issue?",

    "hello": "Hello! I’m here to assist with any queries about the EaseLine app. What would you like to know?",

    "how do i submit a grievance?": "You can submit a grievance from the EaseLine app by going to the 'Submit Grievance' section and filling in the details.",

    "what are the different grievance categories?": "EaseLine supports different grievance categories, including:\n"
        "- Academic Issues\n- Hostel Complaints\n- Administration Issues\n- Technical Problems\n\nWhich category do you need help with?",

    "how long does it take to resolve an issue?": "Most grievances are resolved within 3-5 working days, depending on the complexity of the issue.",

    "can i track my grievance status?": "Yes! You can track the status of your grievance in the 'My Grievances' section of the app.",

    "how do i contact support?": "You can contact support via the 'Help & Support' section in the EaseLine app or email us at support@easeline.com.",

    "what if my issue is not resolved?": "If your grievance is not resolved within the given time, you can escalate it through the 'Escalate Grievance' button in the app.",

    "can i edit my submitted grievance?": "Yes, you can edit your grievance within 24 hours of submission in the 'My Grievances' section.",

    "default": "I’m not sure how to respond to that. Try asking me about grievance submission, tracking, or categories!"
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
