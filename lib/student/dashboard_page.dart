import 'package:flutter/material.dart';
import 'courses_page.dart';
import 'dashboard_page.dart';
import 'ai_help_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
              const Text(
                "My Academic Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "75% Complete",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 12,
                  color: Colors.green,
                  backgroundColor: Colors.white10,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Earned 3 stars in Physics Fundamentals",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              const Text(
                "Physics Lesson Status",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              statusRow("Lesson 1: Motion", "Completed", Colors.green),
              const SizedBox(height: 14),
              statusRow("Lesson 2: Gravity", "In Progress", Colors.orange),
              const SizedBox(height: 14),
              statusRow("Lesson 3: Energy", "Not Started", Colors.grey),
            ],
          ),
        ),
      ),

      // ✅ Bottom Navigation Bar (المفقود)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Dashboard = index 1
        backgroundColor: const Color(0xFF15263D),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          Widget page;

          if (index == 0) {
            page = const CoursesPage();
          } else if (index == 1) {
            page = const DashboardPage();
          } else if (index == 2) {
            page = const AIHelpPage();
          } else {
            page = const ProfilePage();
          }

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => page),
                (route) => false,
          );
        },
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

  Widget statusRow(String lesson, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          lesson,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: color),
            const SizedBox(width: 6),
            Text(status, style: TextStyle(color: color)),
          ],
        )
      ],
    );
  }
}
