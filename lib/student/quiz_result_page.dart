import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String lessonTitle;

  const QuizResultPage({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage =
    totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;

    String resultMessage;
    Color resultColor;
    IconData resultIcon;

    if (percentage >= 80) {
      resultMessage = "Excellent work!";
      resultColor = const Color(0xFF2ECC71);
      resultIcon = Icons.emoji_events_rounded;
    } else if (percentage >= 60) {
      resultMessage = "Good job!";
      resultColor = Colors.orange;
      resultIcon = Icons.thumb_up_alt_rounded;
    } else {
      resultMessage = "Keep practicing!";
      resultColor = Colors.redAccent;
      resultIcon = Icons.refresh_rounded;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15263D),
        elevation: 0,
        title: const Text(
          "Quiz Results",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF15263D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resultIcon,
                    size: 40,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  lessonTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resultMessage,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "$correctAnswers / $totalQuestions",
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Correct Answers",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: totalQuestions == 0
                        ? 0
                        : correctAnswers / totalQuestions,
                    minHeight: 12,
                    backgroundColor: Colors.white10,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${percentage.toStringAsFixed(0)}% Score",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Back to Lesson",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}