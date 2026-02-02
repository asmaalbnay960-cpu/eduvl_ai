import 'package:flutter/material.dart';
import 'package:eduvl_ai/student/quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  final String lessonTitle;

  const QuizPage({super.key, required this.lessonTitle});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  int questionIndex = 0;
  int selectedIndex = -1;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() {
    List<Map<String, dynamic>> allQuestions = [
      {
        "question": "What is the change in position of an object over time?",
        "options": ["Motion", "Equilibrium", "Inertia"],
        "answer": 0,
      },
      {
        "question": "Which force pulls objects toward Earth?",
        "options": ["Gravity", "Friction", "Magnetism"],
        "answer": 0,
      },
      {
        "question": "Which term describes resistance to change in motion?",
        "options": ["Acceleration", "Inertia", "Velocity"],
        "answer": 1,
      },
    ];

    allQuestions.shuffle();
    questions = allQuestions;

    setState(() {});
  }

  void submitAnswer() {
    if (selectedIndex == questions[questionIndex]["answer"]) {
      correctAnswers++;
    }

    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
        selectedIndex = -1;
      });
    } else {
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
    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1B2B),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF32D296)),
        ),
      );
    }

    final q = questions[questionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quick Quiz",
                style: const TextStyle(
                  color: Color(0xFF32D296),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Question ${questionIndex + 1} of ${questions.length}",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 25),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15263D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q["question"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),

                      ...List.generate(
                        q["options"].length,
                            (index) => GestureDetector(
                          onTap: () => setState(() => selectedIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? const Color(0xFF32D296)
                                  : const Color(0xFF1E3450),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              q["options"][index],
                              style: TextStyle(
                                color: selectedIndex == index
                                    ? Colors.black
                                    : Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      ElevatedButton(
                        onPressed:
                        selectedIndex == -1 ? null : submitAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF32D296),
                          disabledBackgroundColor: const Color(0xFF3A4A5A),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          questionIndex == questions.length - 1
                              ? "Finish Quiz"
                              : "Next Question",
                          style: const TextStyle(fontSize: 18),
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
