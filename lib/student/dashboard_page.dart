import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final String _userId;
  late final Stream<DashboardData> _dashboardStream;

  @override
  void initState() {
    super.initState();

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No logged in user found.');
    }

    _userId = user.uid;
    _dashboardStream = _getDashboardData();
  }

  Stream<DashboardData> _getDashboardData() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('lessonProgress')
        .snapshots()
        .asyncMap((progressSnapshot) async {
      final lessonsSnapshot = await _firestore.collection('lessons').get();

      final lessonDocs = lessonsSnapshot.docs;
      final progressDocs = progressSnapshot.docs;

      final Map<String, Map<String, dynamic>> progressMap = {
        for (var doc in progressDocs) doc.id: doc.data(),
      };

      int completedLessons = 0;
      int inProgressLessons = 0;
      int notStartedLessons = 0;
      int totalStars = 0;

      List<LessonProgressItem> lessonItems = [];

      for (final lessonDoc in lessonDocs) {
        final lessonId = lessonDoc.id;
        final lessonData = lessonDoc.data();
        final lessonTitle =
        (lessonData['title'] ?? 'Untitled Lesson').toString();

        final progressData = progressMap[lessonId];

        final status = (progressData?['status'] ?? 'Not Started').toString();
        final dynamic starsRaw = progressData?['stars'] ?? 0;
        final int stars = starsRaw is int
            ? starsRaw
            : int.tryParse(starsRaw.toString()) ?? 0;

        if (status == 'Completed') {
          completedLessons++;
        } else if (status == 'In Progress') {
          inProgressLessons++;
        } else {
          notStartedLessons++;
        }

        totalStars += stars;

        lessonItems.add(
          LessonProgressItem(
            lessonId: lessonId,
            title: lessonTitle,
            status: status,
            stars: stars,
          ),
        );
      }

      final totalLessons = lessonDocs.length;
      final completionPercent =
      totalLessons == 0 ? 0.0 : completedLessons / totalLessons;

      return DashboardData(
        totalLessons: totalLessons,
        completedLessons: completedLessons,
        inProgressLessons: inProgressLessons,
        notStartedLessons: notStartedLessons,
        totalStars: totalStars,
        completionPercent: completionPercent,
        lessons: lessonItems,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F1B2B),
      child: SafeArea(
        child: StreamBuilder<DashboardData>(
          stream: _dashboardStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2ECC71),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Something went wrong:\n${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'No dashboard data found.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Progress",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Track your completed lessons, progress, and stars.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15263D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${(data.completionPercent * 100).toStringAsFixed(0)}% Complete",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: data.completionPercent,
                            minHeight: 12,
                            color: const Color(0xFF2ECC71),
                            backgroundColor: Colors.white10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "You earned ${data.totalStars} stars in ${data.completedLessons} completed lessons.",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatCard(
                        title: 'Total Lessons',
                        value: data.totalLessons.toString(),
                        icon: Icons.menu_book_rounded,
                      ),
                      _buildStatCard(
                        title: 'Completed',
                        value: data.completedLessons.toString(),
                        icon: Icons.check_circle_rounded,
                      ),
                      _buildStatCard(
                        title: 'In Progress',
                        value: data.inProgressLessons.toString(),
                        icon: Icons.timelapse_rounded,
                      ),
                      _buildStatCard(
                        title: 'Stars',
                        value: data.totalStars.toString(),
                        icon: Icons.star_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "Lesson Status",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (data.lessons.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2A3A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "No lesson progress found yet.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ...data.lessons.map(
                          (lesson) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLessonCard(lesson),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A3A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2ECC71), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLessonCard(LessonProgressItem lesson) {
    final color = _statusColor(lesson.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lesson.status,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lesson.stars > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      lesson.stars,
                          (index) => const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF2ECC71);
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class DashboardData {
  final int totalLessons;
  final int completedLessons;
  final int inProgressLessons;
  final int notStartedLessons;
  final int totalStars;
  final double completionPercent;
  final List<LessonProgressItem> lessons;

  DashboardData({
    required this.totalLessons,
    required this.completedLessons,
    required this.inProgressLessons,
    required this.notStartedLessons,
    required this.totalStars,
    required this.completionPercent,
    required this.lessons,
  });
}

class LessonProgressItem {
  final String lessonId;
  final String title;
  final String status;
  final int stars;

  LessonProgressItem({
    required this.lessonId,
    required this.title,
    required this.status,
    required this.stars,
  });
}