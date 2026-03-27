// lib/student/lesson_page.dart
import 'package:flutter/material.dart';
import 'package:eduvl_ai/student/experiment_3d_page.dart';

class LessonPage extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;
  final String lessonDescription;

  // ممكن يكون URL (http...) أو asset path
  final String modelSrc;

  const LessonPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.modelSrc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15263D),
        title: Text(lessonTitle, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lessonDescription,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),

            const Spacer(),

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
                        lessonId: lessonId,
                        modelSrc: modelSrc,
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