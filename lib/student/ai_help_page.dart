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

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$geminiApiKey",
        );

        final response = await http
            .post(
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
        )
            .timeout(const Duration(seconds: 20));

        debugPrint("Gemini model: $modelName");
        debugPrint("Gemini attempt: ${attempt + 1}");
        debugPrint("Gemini status: ${response.statusCode}");
        debugPrint("Gemini body: ${response.body}");

        final Map<String, dynamic> data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final candidates = data["candidates"];

          if (candidates is List && candidates.isNotEmpty) {
            final firstCandidate = candidates[0];
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
            if (finishReason != null) {
              debugPrint("Gemini finishReason: $finishReason");

              if (attempt < 1) {
                await Future.delayed(const Duration(seconds: 2));
                continue;
              }

              return "I couldn’t complete this response right now. Please try asking in a simpler way.";
            }
          }

          final promptFeedback = data["promptFeedback"];
          if (promptFeedback != null) {
            debugPrint("Prompt feedback: $promptFeedback");

            if (attempt < 1) {
              await Future.delayed(const Duration(seconds: 2));
              continue;
            }

            return "I couldn’t answer this request right now. Please try asking in a different way.";
          }

          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }

          return "I couldn’t get a clear response right now. Please try again.";
        }

        if (response.statusCode == 429) {
          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return "The AI is busy right now. Please try again in a moment.";
        }

        if (response.statusCode == 503) {
          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return "The AI service is temporarily unavailable. Please try again.";
        }

        final error = data["error"];
        final errorMessage =
        error is Map && error["message"] != null ? error["message"].toString() : "";

        if (errorMessage.toLowerCase().contains("high demand")) {
          if (attempt < 1) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return "The AI is currently under heavy load. Please try again in a moment.";
        }

        if (response.statusCode == 400) {
          return "There was a problem with the request sent to the AI service.";
        }

        if (response.statusCode == 403) {
          return "The AI service key is invalid or access is restricted.";
        }

        if (errorMessage.isNotEmpty) {
          return errorMessage;
        }

        if (attempt < 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        return "Sorry, I couldn’t respond right now. Please try again.";
      } on TimeoutException {
        debugPrint("Gemini timeout on attempt ${attempt + 1}");

        if (attempt < 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        return "The request took too long. Please check your internet and try again.";
      } on FormatException catch (e) {
        debugPrint("Gemini JSON format error: $e");
        return "The AI response was not in the expected format.";
      } catch (e) {
        debugPrint("Gemini request error on attempt ${attempt + 1}: $e");

        if (attempt < 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        return "Sorry, I couldn’t respond right now. Please try again.";
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "EduAI Assistant",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                        color: Colors.white.withOpacity(0.65),
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
                            color: Colors.white.withOpacity(0.45),
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