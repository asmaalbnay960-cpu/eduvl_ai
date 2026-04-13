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

    return Material(
      color: const Color(0xFF0F1B2B),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Courses",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Select a subject to start learning.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: ListView.separated(
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = courses[index];
                    final Widget? page = item["page"] as Widget?;
                    final bool isAvailable = page != null;
                    final Color iconColor = item["color"] as Color;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          if (page != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => page),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF1C2A3A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: const Text(
                                  "This course is coming soon.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15263D),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isAvailable
                                  ? Colors.white12
                                  : Colors.white10,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item["icon"] as IconData,
                                  color: iconColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["title"] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? Colors.green.withOpacity(0.12)
                                                : Colors.white10,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            isAvailable ? "Open" : "Soon",
                                            style: TextStyle(
                                              color: isAvailable
                                                  ? Colors.greenAccent
                                                  : Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item["desc"] as String,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                isAvailable
                                    ? Icons.arrow_forward_ios_rounded
                                    : Icons.lock_outline_rounded,
                                color: Colors.white38,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}