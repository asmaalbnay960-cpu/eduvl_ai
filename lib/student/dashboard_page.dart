import 'package:flutter/material.dart';

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

              // Progress Percentage
              const Text(
                "75% Complete",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 6),

              // Progress Bar
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