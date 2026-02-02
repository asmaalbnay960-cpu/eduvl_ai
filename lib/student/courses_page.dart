import 'package:flutter/material.dart';
import 'lessons_page.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> courses = [
      {
        "title": "Physics",
        "desc": "Explore motion, gravity, energy & more.",
        "icon": Icons.science,
        "color": Colors.green,
        "page": const PhysicsLessonsPage(),
      },
      {
        "title": "Chemistry",
        "desc": "Coming soon...",
        "icon": Icons.bubble_chart,
        "color": Colors.orange,
        "page": null,
      },
      {
        "title": "Biology",
        "desc": "Coming soon...",
        "icon": Icons.biotech,
        "color": Colors.blue,
        "page": null,
      },
      {
        "title": "Mathematics",
        "desc": "Coming soon...",
        "icon": Icons.calculate,
        "color": Colors.purple,
        "page": null,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose a Course",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final item = courses[index];
                    return GestureDetector(
                      onTap: () {
                        if (item["page"] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => item["page"],
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF15263D),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(item["icon"], color: item["color"], size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["title"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item["desc"],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white54)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
