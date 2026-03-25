import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'upload_lesson_page.dart';
import 'content_management_page.dart';
import '../auth/register_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15263D),
        centerTitle: false,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Log Out",
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RegisterPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "System Overview",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: const [
              _StudentsStatCard(),
              _LessonsStatCard(),
              _QuizzesStatCard(),
              _AiUsageStatCard(),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            "Quick Actions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _actionButton(
            icon: Icons.add_box,
            label: "Add New Lesson",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadLessonPage(),
                ),
              );
            },
          ),
          _actionButton(
            icon: Icons.settings,
            label: "Manage Content",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ContentManagementPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2A3A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2ECC71)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

class _StudentsStatCard extends StatelessWidget {
  const _StudentsStatCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _StatCard(
            title: "Students",
            value: "0",
            icon: Icons.people,
          );
        }

        if (!snapshot.hasData) {
          return const _StatCard(
            title: "Students",
            value: "...",
            icon: Icons.people,
          );
        }

        final docs = snapshot.data!.docs;
        final count = docs.where((doc) {
          final data = doc.data();
          final role = (data['role'] ?? '').toString().trim().toLowerCase();
          return role == 'student';
        }).length;

        return _StatCard(
          title: "Students",
          value: count.toString(),
          icon: Icons.people,
        );
      },
    );
  }
}

class _LessonsStatCard extends StatelessWidget {
  const _LessonsStatCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('lessons').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _StatCard(
            title: "Lessons",
            value: "0",
            icon: Icons.menu_book,
          );
        }

        if (!snapshot.hasData) {
          return const _StatCard(
            title: "Lessons",
            value: "...",
            icon: Icons.menu_book,
          );
        }

        final count = snapshot.data!.docs.length;

        return _StatCard(
          title: "Lessons",
          value: count.toString(),
          icon: Icons.menu_book,
        );
      },
    );
  }
}

class _QuizzesStatCard extends StatelessWidget {
  const _QuizzesStatCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('lessons').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _StatCard(
            title: "Quizzes",
            value: "0",
            icon: Icons.quiz,
          );
        }

        if (!snapshot.hasData) {
          return const _StatCard(
            title: "Quizzes",
            value: "...",
            icon: Icons.quiz,
          );
        }

        final docs = snapshot.data!.docs;
        final count = docs.where((doc) {
          final data = doc.data();
          return data['hasQuiz'] == true;
        }).length;

        return _StatCard(
          title: "Quizzes",
          value: count.toString(),
          icon: Icons.quiz,
        );
      },
    );
  }
}

class _AiUsageStatCard extends StatelessWidget {
  const _AiUsageStatCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _StatCard(
            title: "AI Usage",
            value: "0",
            icon: Icons.smart_toy,
          );
        }

        if (!snapshot.hasData) {
          return const _StatCard(
            title: "AI Usage",
            value: "...",
            icon: Icons.smart_toy,
          );
        }

        final docs = snapshot.data!.docs;
        final count = docs.where((doc) {
          final data = doc.data();
          final role = (data['role'] ?? '').toString().trim().toLowerCase();
          final usedAI = data['usedAI'] == true;
          return role == 'student' && usedAI;
        }).length;

        return _StatCard(
          title: "AI Usage",
          value: count.toString(),
          icon: Icons.smart_toy,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2ECC71), size: 28),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}