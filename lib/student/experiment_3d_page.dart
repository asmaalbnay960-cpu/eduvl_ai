import 'package:flutter/material.dart';
import 'package:eduvl_ai/student/quiz_page.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Experiment3DPage extends StatelessWidget {
  final String modelFile; // مثال: assets/models/newtons_cradle.glb
  final String lessonTitle;

  const Experiment3DPage({
    super.key,
    required this.modelFile,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: Color(0xFF32D296)),
                    SizedBox(width: 6),
                    Text(
                      "Back to Details",
                      style: TextStyle(
                        color: Color(0xFF32D296),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Text(
                lessonTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF15263D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ModelViewer(
                    src: modelFile, // ✅ يعرض ملف glb من assets
                    ar: false,
                    autoRotate: true,
                    cameraControls: true,
                    backgroundColor: const Color(0xFF15263D),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Drag to rotate the 3D model...",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizPage(lessonTitle: lessonTitle),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Take Quiz",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
