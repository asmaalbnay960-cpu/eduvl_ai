import 'package:flutter/material.dart';
import 'lesson_page.dart';
import 'courses_page.dart';
import 'dashboard_page.dart';
import 'ai_help_page.dart';
import 'profile_page.dart';

class PhysicsLessonsPage extends StatefulWidget {
  const PhysicsLessonsPage({super.key});

  @override
  State<PhysicsLessonsPage> createState() => _PhysicsLessonsPageState();
}

class _PhysicsLessonsPageState extends State<PhysicsLessonsPage> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> lessons = [
    {
      "title": "Lesson 1: Motion",
      "desc": "Explore speed, velocity, and acceleration.",
      "status": "In Progress",
      "model": "motion.glb",
    },
    {
      "title": "Lesson 2: Gravity",
      "desc": "Simulate free fall and orbital mechanics.",
      "status": "Not Started",
      "model": "gravity.glb",
    },
    {
      "title": "Lesson 3: Energy",
      "desc": "Kinetic and potential energy concepts.",
      "status": "Not Started",
      "model": "energy.glb",
    },
  ];

  void _onNavTap(int index) {
    if (index == _currentIndex) return; // ✅ لا تعيد فتح نفس الصفحة

    setState(() => _currentIndex = index); // ✅ يحدث التبويب

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CoursesPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AIHelpPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePage()),
      );
    }
  }


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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final item = lessons[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonPage(
                        lessonTitle: item["title"] as String,
                        lessonDescription: item["desc"] as String,
                        theoryText:
                        "Theory content for ${item["title"]} will go here.",
                        // ✅ ثابت للاختبار الآن
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
                            Text(
                              item["title"] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item["desc"] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (item["status"] == "In Progress")
                              ? const Color(0xFFE0A800)
                              : const Color(0xFF44566C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item["status"] as String,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white54),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF15263D),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white54,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Progress"),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined), label: "AI Guide"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
