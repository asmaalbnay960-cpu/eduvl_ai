import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'upload_lesson_page.dart';

class ContentManagementPage extends StatelessWidget {
  const ContentManagementPage({super.key});

  Future<void> _deleteLesson(
      BuildContext context,
      String lessonId,
      String lessonTitle,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2A3A),
        title: const Text(
          "Delete Lesson",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "$lessonTitle"?\n\nThis will also delete all quiz questions for this lesson.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final lessonRef = firestore.collection('lessons').doc(lessonId);

      final quizSnapshot = await lessonRef.collection('quizQuestions').get();

      if (quizSnapshot.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in quizSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await lessonRef.delete();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "$lessonTitle" successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0F1B2B);
    const Color accentGreen = Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.redAccent),
                    SizedBox(width: 6),
                    Text(
                      "Back to Dashboard",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Content Management",
                style: TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('lessons')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Failed to load lessons",
                          style: TextStyle(color: Colors.red.shade300),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No lessons found yet",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();

                        final title =
                        (data['title'] ?? 'Untitled Lesson').toString();
                        final category =
                        (data['category'] ?? 'No Category').toString();
                        final description =
                        (data['description'] ?? 'No Description')
                            .toString();
                        final quizCountRaw = data['quizCount'];
                        final int quizCount = quizCountRaw is int
                            ? quizCountRaw
                            : (quizCountRaw is num
                            ? quizCountRaw.toInt()
                            : 0);
                        final hasQuiz = (data['hasQuiz'] ?? false) as bool;

                        final subtitle = hasQuiz
                            ? "$category | Quiz: $quizCount"
                            : "$category | No Quiz";

                        return _lessonCard(
                          title: title,
                          subtitle: subtitle,
                          description: description,
                          statusColor: accentGreen,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadLessonPage(
                                  lessonId: doc.id,
                                  existingData: data,
                                ),
                              ),
                            );
                          },
                          onDelete: () =>
                              _deleteLesson(context, doc.id, title),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UploadLessonPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Add New Lesson",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _lessonCard({
    required String title,
    required String subtitle,
    required String description,
    required Color statusColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}