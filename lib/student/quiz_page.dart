import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduvl_ai/student/quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const QuizPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  int questionIndex = 0;
  int selectedIndex = -1;
  int correctAnswers = 0;

  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('lessons')
          .doc(widget.lessonId)
          .collection('quizQuestions')
          .orderBy('createdAt', descending: false)
          .get();

      final list = snap.docs.map((d) {
        final data = d.data();

        final options = List<String>.from((data['options'] ?? []) as List);

        return {
          "question": (data['question'] ?? '') as String,
          "options": options,
          "answer": (data['correctIndex'] ?? 0) as int,
        };
      }).toList();

      list.shuffle();
      final limited = list.length > 3 ? list.take(3).toList() : list;

      setState(() {
        questions = limited;
        loading = false;
        errorText = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorText = e.toString();
      });
    }
  }

  int _calculateStars(int correct, int total) {
    if (total == 0) return 0;

    final percentage = (correct / total) * 100;

    if (percentage >= 80) return 3;
    if (percentage >= 60) return 2;
    if (percentage >= 40) return 1;
    return 0;
  }

  Future<void> _saveQuizCompletion() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final stars = _calculateStars(correctAnswers, questions.length);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('lessonProgress')
          .doc(widget.lessonId)
          .set({
        'lessonTitle': widget.lessonTitle,
        'status': 'Completed',
        'stars': stars,
        'correctAnswers': correctAnswers,
        'totalQuestions': questions.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving quiz completion: $e');
    }
  }

  Future<void> submitAnswer() async {
    if (selectedIndex == questions[questionIndex]["answer"]) {
      correctAnswers++;
    }

    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
        selectedIndex = -1;
      });
    } else {
      await _saveQuizCompletion();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            correctAnswers: correctAnswers,
            totalQuestions: questions.length,
            lessonTitle: widget.lessonTitle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1B2B),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF32D296)),
        ),
      );
    }

    if (errorText != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1B2B),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Error loading quiz:\n$errorText",
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1B2B),
        body: Center(
          child: Text(
            "No quiz questions available for this lesson.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final q = questions[questionIndex];
    final options = q["options"] as List<String>;
    final progress = (questionIndex + 1) / questions.length;
    final isLastQuestion = questionIndex == questions.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quick Quiz",
                style: TextStyle(
                  color: Color(0xFF32D296),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.lessonTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    "Question ${questionIndex + 1} of ${questions.length}",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Color(0xFF32D296),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFF32D296),
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15263D),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q["question"] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: options.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final isSelected = selectedIndex == index;
                            final optionLetter =
                            String.fromCharCode(65 + index); // A, B, C...

                            return GestureDetector(
                              onTap: () => setState(() => selectedIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF32D296)
                                      : const Color(0xFF1C2A3A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF32D296)
                                        : Colors.white10,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.22)
                                            : Colors.white10,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          optionLetter,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        options[index],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 15.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedIndex == -1 ? null : submitAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF32D296),
                            disabledBackgroundColor: const Color(0xFF3A4A5A),
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            isLastQuestion ? "Finish Quiz" : "Next Question",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}