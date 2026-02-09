import 'package:flutter/material.dart';
import 'experiment_3d_page.dart';

class LessonPage extends StatelessWidget {
  final String lessonTitle;
  final String lessonDescription;
  final String theoryText;
  final String modelFile;

  const LessonPage({
    super.key,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.theoryText,
    required this.modelFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15263D),
        title: Text(
          lessonTitle,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lessonDescription,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Theory Overview",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              theoryText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),

            const Spacer(),

            // 🚀 Start 3D Experiment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.science, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Experiment3DPage(
                        modelFile: modelFile,
                        lessonTitle: lessonTitle,
                      ),
                    ),
                  );
                },
                label: const Text(
                  "Start 3D Experiment",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
