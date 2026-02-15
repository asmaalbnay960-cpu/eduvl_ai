import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadLessonPage extends StatefulWidget {
  const UploadLessonPage({super.key});

  @override
  State<UploadLessonPage> createState() => _UploadLessonPageState();
}

class _UploadLessonPageState extends State<UploadLessonPage> {
  String selectedCategory = "Select Category";

  final List<String> categories = [
    "Physics",
    "Chemistry",
    "Biology",
    "Space Science",
  ];

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  /// ===== Quiz dynamic list =====
  final List<_QuizQuestionForm> _questions = [
    _QuizQuestionForm(), // start with 1 question
  ];

  bool _isPublishing = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0F1B2B);
    const Color cardColor = Color(0xFF1C2A3A);
    const Color accentGreen = Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
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
                "Upload New Lesson",
                style: TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              _label("Lesson Title"),
              _inputField(_titleCtrl, "e.g., Electromagnetism Basics"),

              const SizedBox(height: 18),

              _label("Category"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  dropdownColor: cardColor,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(
                      value: "Select Category",
                      child: Text(
                        "Select Category",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    ...categories.map(
                          (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 18),

              _label("Lesson Description"),
              _inputField(_descCtrl, "Short summary for learners...", maxLines: 4),

              const SizedBox(height: 22),

              _label("3D Model File (.glb / .obj)"),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, color: Colors.white70),
                      SizedBox(width: 8),
                      Text(
                        "Choose File",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              /// ===== Quiz section =====
              _sectionTitle("Quiz Questions (Optional)"),
              const SizedBox(height: 10),

              ...List.generate(_questions.length, (i) {
                final q = _questions[i];
                return _questionCard(
                  index: i,
                  q: q,
                  cardColor: cardColor,
                  onRemove: _questions.length == 1
                      ? null
                      : () {
                    setState(() {
                      final removed = _questions.removeAt(i);
                      removed.dispose();
                    });
                  },
                );
              }),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _questions.add(_QuizQuestionForm());
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Add Question",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isPublishing ? null : _publishLessonWithQuiz,
                  icon: _isPublishing
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _isPublishing ? "Publishing..." : "Publish Lesson",
                    style: const TextStyle(fontSize: 18),
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

  /// ===== Firestore publish =====
  Future<void> _publishLessonWithQuiz() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty) {
      _toast("Please enter lesson title");
      return;
    }
    if (selectedCategory == "Select Category") {
      _toast("Please select a category");
      return;
    }
    if (desc.isEmpty) {
      _toast("Please enter lesson description");
      return;
    }

    // Build quiz list (only valid questions)
    final quiz = <_QuizQuestionData>[];
    for (final q in _questions) {
      final data = q.toDataOrNull();
      if (data != null) quiz.add(data);
    }

    setState(() => _isPublishing = true);

    try {
      final firestore = FirebaseFirestore.instance;

      // 1) Create lesson doc
      final lessonRef = await firestore.collection('lessons').add({
        'title': title,
        'category': selectedCategory,
        'description': desc,
        // TODO later: 'modelUrl': uploaded file URL from Firebase Storage
        'createdAt': FieldValue.serverTimestamp(),
        'hasQuiz': quiz.isNotEmpty,
        'quizCount': quiz.length,
      });

      // 2) Save quiz as subcollection
      if (quiz.isNotEmpty) {
        final batch = firestore.batch();

        for (final q in quiz) {
          final qRef = lessonRef.collection('quizQuestions').doc();
          batch.set(qRef, {
            'question': q.question,
            'options': q.options, // List<String>
            'correctIndex': q.correctIndex, // int
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        await batch.commit(); // atomic-ish multi writes
      }

      _toast("Lesson published ✅");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _toast("Failed: $e");
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _questionCard({
    required int index,
    required _QuizQuestionForm q,
    required Color cardColor,
    VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Question ${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Remove question",
                ),
            ],
          ),
          const SizedBox(height: 8),

          _label("Question"),
          _inputField(q.questionCtrl, "Write the question here..."),

          const SizedBox(height: 10),

          _label("Options (4)"),
          _inputField(q.optA, "Option A"),
          const SizedBox(height: 8),
          _inputField(q.optB, "Option B"),
          const SizedBox(height: 8),
          _inputField(q.optC, "Option C"),
          const SizedBox(height: 8),
          _inputField(q.optD, "Option D"),

          const SizedBox(height: 12),

          _label("Correct Answer"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF162232),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              value: q.correctIndex,
              isExpanded: true,
              dropdownColor: const Color(0xFF162232),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 0, child: Text("A", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 1, child: Text("B", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 2, child: Text("C", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 3, child: Text("D", style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => q.correctIndex = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.white70)),
  );

  Widget _inputField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1C2A3A),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// ===== Helper classes =====
class _QuizQuestionForm {
  final TextEditingController questionCtrl = TextEditingController();
  final TextEditingController optA = TextEditingController();
  final TextEditingController optB = TextEditingController();
  final TextEditingController optC = TextEditingController();
  final TextEditingController optD = TextEditingController();
  int correctIndex = 0;

  void dispose() {
    questionCtrl.dispose();
    optA.dispose();
    optB.dispose();
    optC.dispose();
    optD.dispose();
  }

  _QuizQuestionData? toDataOrNull() {
    final q = questionCtrl.text.trim();
    final a = optA.text.trim();
    final b = optB.text.trim();
    final c = optC.text.trim();
    final d = optD.text.trim();

    // If admin تركها فاضية بالكامل: نتجاهلها
    if (q.isEmpty && a.isEmpty && b.isEmpty && c.isEmpty && d.isEmpty) return null;

    // إذا بدأ يكتب لازم يكملها
    if (q.isEmpty || a.isEmpty || b.isEmpty || c.isEmpty || d.isEmpty) {
      // نعتبرها غير صالحة (بنترك التحقق في الصفحة لو تبين)
      return null;
    }

    return _QuizQuestionData(
      question: q,
      options: [a, b, c, d],
      correctIndex: correctIndex,
    );
  }
}

class _QuizQuestionData {
  final String question;
  final List<String> options;
  final int correctIndex;
  _QuizQuestionData({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}
