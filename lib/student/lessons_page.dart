import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_page.dart';

class PhysicsLessonsPage extends StatelessWidget {
  const PhysicsLessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1B2B);
    const card = Color(0xFF15263D);
    const green = Color(0xFF2ECC71);

    final lessonsStream = FirebaseFirestore.instance
        .collection('lessons')
        .where('category', isEqualTo: 'Physics')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Physics Lessons",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: lessonsStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error: ${snap.error}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            );
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No lessons yet. Ask admin to publish one.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final lessonId = doc.id;

              final title = (data['title'] ?? 'Untitled') as String;
              final desc = (data['description'] ?? '') as String;

              // ❌ حذفنا theoryText بالكامل

              // Optional fields
              final hasQuiz = (data['hasQuiz'] ?? false) as bool;

              final quizCountRaw = data['quizCount'];
              final int quizCount = quizCountRaw is int
                  ? quizCountRaw
                  : (quizCountRaw is num ? quizCountRaw.toInt() : 0);

              // model
              final modelUrl =
              (data['modelUrl'] ?? data['modelSrc'] ?? '') as String;
              const modelFallbackAsset =
                  'assets/models/newtons_cradle.glb';
              final modelSrc =
              modelUrl.isNotEmpty ? modelUrl : modelFallbackAsset;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonPage(
                        lessonId: lessonId,
                        lessonTitle: title,
                        lessonDescription: desc,
                        modelSrc: modelSrc,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            if (hasQuiz)
                              Text(
                                "Quiz: $quizCount questions",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: hasQuiz
                              ? const Color(0xFF1FAF77)
                              : const Color(0xFF44566C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hasQuiz ? "Has Quiz" : "Lesson",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}