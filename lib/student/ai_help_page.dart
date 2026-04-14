import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      "text": "Hello! I am your EduAI Assistant.\nHow can I help you today?"
    }
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'__'), '')
        .replaceAll(RegExp(r'_'), '')
        .trim();
  }

  Future<String> _askGemini(String question) async {
    const String modelName = "gemini-2.5-flash";

    // فحص المفتاح قبل الإرسال
    if (geminiApiKey.trim().isEmpty) {
      debugPrint("Gemini API key is empty.");
      return "Gemini API key is missing. Please check gemini_key.dart";
    }

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$geminiApiKey",
    );

    final requestBody = {
      "contents": [
        {
          "parts": [
            {"text": question}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "maxOutputTokens": 500,
      }
    };

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        debugPrint("========== GEMINI REQUEST ==========");
        debugPrint("Model: $modelName");
        debugPrint("Attempt: ${attempt + 1}");
        debugPrint("URL: $url");
        debugPrint("Request Body: ${jsonEncode(requestBody)}");

        final response = await http
            .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(requestBody),
        )
            .timeout(const Duration(seconds: 20));

        debugPrint("========== GEMINI RESPONSE ==========");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");

        Map<String, dynamic> data = {};
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint("JSON decode error: $e");
          return "The AI returned an unreadable response.";
        }

        if (response.statusCode == 200) {
          final candidates = data["candidates"];

          if (candidates is List && candidates.isNotEmpty) {
            final firstCandidate = candidates.first;
            final content = firstCandidate["content"];
            final parts = content?["parts"];

            if (parts is List && parts.isNotEmpty) {
              final buffer = StringBuffer();

              for (final part in parts) {
                if (part is Map<String, dynamic> && part["text"] != null) {
                  buffer.writeln(part["text"].toString());
                }
              }

              final text = _cleanText(buffer.toString());
              if (text.isNotEmpty) {
                return text;
              }
            }

            final finishReason = firstCandidate["finishReason"];
            debugPrint("Finish Reason: $finishReason");

            if (attempt < 1) {
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }

            return "I couldn’t complete this response right now. Please try again.";
          }

          final promptFeedback = data["promptFeedback"];
          if (promptFeedback != null) {
            debugPrint("Prompt Feedback: $promptFeedback");

            if (attempt < 1) {
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }

            return "Your request could not be processed. Please try changing the wording.";
          }

          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }

          return "No valid response was returned from Gemini.";
        }

        // معالجة الأخطاء الواضحة
        final error = data["error"];
        final errorMessage = error is Map && error["message"] != null
            ? error["message"].toString()
            : "Unknown error";

        debugPrint("Gemini Error Message: $errorMessage");

        if (response.statusCode == 400) {
          return "Bad request to Gemini: $errorMessage";
        }

        if (response.statusCode == 403) {
          return "Access denied. Check your Gemini API key and permissions.";
        }

        if (response.statusCode == 404) {
          return "Model not found. Please check the model name.";
        }

        if (response.statusCode == 429) {
          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return "Gemini is busy right now. Please try again in a moment.";
        }

        if (response.statusCode == 500 || response.statusCode == 503) {
          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return "Gemini service is temporarily unavailable.";
        }

        return "Gemini error ${response.statusCode}: $errorMessage";
      } on TimeoutException {
        debugPrint("Gemini timeout on attempt ${attempt + 1}");

        if (attempt < 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        return "The request timed out. Please check your connection and try again.";
      } catch (e) {
        debugPrint("Gemini request exception on attempt ${attempt + 1}: $e");

        if (attempt < 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        return "Request failed: $e";
      }
    }

    return "The AI is busy right now. Please try again.";
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'usedAI': true,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("AI usage tracking error: $e");
    }

    final reply = await _askGemini(text);

    if (!mounted) return;

    setState(() {
      _messages.add({"sender": "ai", "text": reply});
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F1B2B),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F1B2B),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Color(0xFF2ECC71),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "EduAI Assistant",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
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
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFF15263D),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 6),
                          bottomRight: Radius.circular(isUser ? 6 : 18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        msg["text"] ?? "",
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : Colors.white.withOpacity(0.92),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2ECC71),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Thinking...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF15263D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2A3A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => sendMessage(),
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Ask about your lesson or experiment...",
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? Colors.white10
                          : const Color(0xFF2ECC71),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: _isLoading ? Colors.white38 : Colors.white,
                      ),
                      onPressed: _isLoading ? null : sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}