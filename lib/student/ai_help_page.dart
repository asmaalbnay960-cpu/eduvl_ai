import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/gemini_key.dart';

class AIHelpPage extends StatefulWidget {
  const AIHelpPage({super.key});

  @override
  State<AIHelpPage> createState() => _AIHelpPageState();
}

class _AIHelpPageState extends State<AIHelpPage> {
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "text": "Hello! I am your EduAI Assistant.\nHow can I help you today? "
    }
  ];

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<String> _askGemini(String question) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": question}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final candidates = data["candidates"];
      if (candidates == null || candidates.isEmpty) return "No response.";

      final content = candidates[0]["content"];
      final parts = content?["parts"];
      if (parts == null || parts.isEmpty) return "No response text.";

      return parts[0]["text"] ?? "No response text.";
    } else {
      return "Error ${response.statusCode}: ${response.body}";
    }
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
    });

    _controller.clear();

    final reply = await _askGemini(text);

    setState(() {
      _messages.add({"sender": "ai", "text": reply});
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مهم: بدون Scaffold عشان ما يتكرر الـ BottomNavigationBar
    return Container(
      color: const Color(0xFF0F1B2B),
      child: SafeArea(
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
                  fontWeight: FontWeight.bold,
                ),
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
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        msg["text"] ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Thinking...",
                  style: TextStyle(color: Colors.white54),
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
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type your question...",
                        hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: _isLoading ? Colors.grey : Colors.blueAccent,
                    ),
                    onPressed: _isLoading ? null : sendMessage,
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
