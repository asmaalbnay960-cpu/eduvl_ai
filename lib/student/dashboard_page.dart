import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xFF0F1B2B),
      child: SafeArea(
        child: SingleChildScrollView( // ✅ يمنع overflow
          padding: EdgeInsets.all(20),
          child: _DashboardBody(),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Academic Progress",
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text("75% Complete", style: TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.75,
            minHeight: 12,
            color: Colors.green,
            backgroundColor: Colors.white10,
          ),
        ),
        const SizedBox(height: 10),
        const Text("Earned 3 stars in Physics Fundamentals", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 30),
        const Text(
          "Physics Lesson Status",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _statusRow("Lesson 1: Motion", "Completed", Colors.green),
        const SizedBox(height: 14),
        _statusRow("Lesson 2: Gravity", "In Progress", Colors.orange),
        const SizedBox(height: 14),
        _statusRow("Lesson 3: Energy", "Not Started", Colors.grey),
      ],
    );
  }

  static Widget _statusRow(String lesson, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            lesson,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
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
