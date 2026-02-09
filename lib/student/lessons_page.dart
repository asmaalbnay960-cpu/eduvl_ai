import 'package:flutter/material.dart';
import 'lesson_page.dart';

class PhysicsLessonsPage extends StatelessWidget {
  const PhysicsLessonsPage({super.key});

  final List<Map<String, dynamic>> lessons = const [
    {
      "title": "Lesson 1: Motion",
      "desc": "Explore speed, velocity, and acceleration.",
      "status": "In Progress",
    },
    {
      "title": "Lesson 2: Gravity",
      "desc": "Simulate free fall and orbital mechanics.",
      "status": "Not Started",
    },
    {
      "title": "Lesson 3: Energy",
      "desc": "Kinetic and potential energy concepts.",
      "status": "Not Started",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B2B),
        elevation: 0,
        title: const Text(
          "Physics Lessons",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final item = lessons[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonPage(
                    lessonTitle: item["title"],
                    lessonDescription: item["desc"],
                    theoryText: "Theory content for ${item["title"]}",
                    modelFile: 'assets/models/newtons_cradle.glb',
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF15263D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["title"],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(item["desc"],
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item["status"] == "In Progress"
                          ? const Color(0xFFE0A800)
                          : const Color(0xFF44566C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item["status"],
                        style:
                        const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
