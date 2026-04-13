// lib/student/experiment_3d_page.dart
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'quiz_page.dart';

class Experiment3DPage extends StatefulWidget {
  final String lessonId;
  final String modelSrc;
  final String lessonTitle;
  final String? iosSrc;

  const Experiment3DPage({
    super.key,
    required this.lessonId,
    required this.modelSrc,
    required this.lessonTitle,
    this.iosSrc,
  });

  @override
  State<Experiment3DPage> createState() => _Experiment3DPageState();
}

class _Experiment3DPageState extends State<Experiment3DPage> {
  bool _playAnimation = true;

  @override
  Widget build(BuildContext context) {
    final src = widget.modelSrc;

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
                    Icon(
                      Icons.arrow_back,
                      color: Color(0xFF32D296),
                    ),
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
              const SizedBox(height: 16),
              Text(
                widget.lessonTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF15263D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ModelViewer(
                    src: src,
                    iosSrc: widget.iosSrc,
                    alt: widget.lessonTitle,
                    autoPlay: _playAnimation,
                    autoRotate: false,
                    cameraControls: true,
                    backgroundColor: const Color(0xFF15263D),
                    ar: true,
                    arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                    arScale: ArScale.fixed,
                    arPlacement: ArPlacement.floor,
                    disableZoom: false,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Drag to rotate the 3D model. Tap the AR icon to open it in augmented reality.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPage(
                          lessonId: widget.lessonId,
                          lessonTitle: widget.lessonTitle,
                        ),
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
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
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