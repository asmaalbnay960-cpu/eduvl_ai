import 'package:flutter/material.dart';

class AIHelpPage extends StatefulWidget {
  const AIHelpPage({super.key});

  @override
  State<AIHelpPage> createState() => _AIHelpPageState();
}

class _AIHelpPageState extends State<AIHelpPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      "sender": "ai",
      "text":
      "Hello! I am your EduAI Assistant.\nHow can I help you with your physics concepts today? Try asking me about \"Newton's First Law\"."
    }
  ];

  final TextEditingController _controller = TextEditingController();

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": _controller.text.trim()});
      _messages.add({
        "sender": "ai",
        "text":
        "Great question! Mass is the amount of matter in an object, while Weight is the force of gravity acting on that mass."
      });
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              child: const Text(
                "EduAI Assistant",
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["sender"] == "user";

                  return Align(
                    alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF1FAF77)
                            : const Color(0xFF243B55),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        msg["text"],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Text Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF15263D),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type your question...",
                        hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: sendMessage,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}