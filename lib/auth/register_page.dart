import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

=======
>>>>>>> 32988e1845ab3c13267f7d02f2ab264f81cdf749
import '../student/main_nav_page.dart';
import '../admin/admin_dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  // forceAdmin واجهة فقط (ما يعطي صلاحية)
  final bool forceAdmin;
  const RegisterPage({super.key, this.forceAdmin = false});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLogin = true;

  // Controllers
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  final _nameC = TextEditingController();
  final _studentIdC = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    _nameC.dispose();
    _studentIdC.dispose();
    super.dispose();
  }

  Future<String?> _getRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    return (data?['role'] ?? 'student') as String;
  }

  /// ✅ إنشاء/تحديث بيانات المستخدم
  /// - createdAt: نضبطها مرة وحدة فقط (إذا ما كانت موجودة)
  /// - lastLoginAt: تتحدث دايم
  Future<void> _upsertUserDoc({
    required String uid,
    required String email,
    String? name,
    String? studentId,
    String role = 'student',
    bool setCreatedAtIfMissing = true,
  }) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);

    final payload = <String, dynamic>{
      'email': email,
      'role': role,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'totalRuntimeSeconds': FieldValue.increment(0),
    };

    if (name != null) payload['name'] = name;
    if (studentId != null) payload['studentId'] = studentId;

    // ✅ createdAt مرة وحدة فقط
    if (setCreatedAtIfMissing) {
      final snap = await ref.get();
      if (!snap.exists || (snap.data()?['createdAt'] == null)) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }
    }

    await ref.set(payload, SetOptions(merge: true));
  }

  // ✅ Forgot password (بدون واجهة منفصلة)
  Future<void> _resetPassword() async {
    setState(() => _error = null);

    final email = _emailC.text.trim();
    if (email.isEmpty) {
      setState(() => _error = "Please enter your email first.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reset link sent to $email (check Spam too).")),
      );
    } on FirebaseAuthException catch (e) {
      // ✅ رسائل أوضح
      if (e.code == 'user-not-found') {
        setState(() => _error = "No account found for this email.");
      } else if (e.code == 'invalid-email') {
        setState(() => _error = "Invalid email format.");
      } else {
        setState(() => _error = e.message ?? e.code);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _error = null);

    final email = _emailC.text.trim();
    final pass = _passC.text;
    final bool adminModeUIOnly = widget.forceAdmin;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = "Please enter email and password.");
      return;
    }

    // ✅ وقت التسجيل فقط
    if (!isLogin && !adminModeUIOnly) {
      if (_confirmC.text != pass) {
        setState(() => _error = "Passwords do not match.");
        return;
      }

      final name = _nameC.text.trim();
      final sid = _studentIdC.text.trim();

      if (name.isEmpty || sid.isEmpty) {
        setState(() => _error = "Please enter your name and student ID.");
        return;
      }
      if (pass.length < 6) {
        setState(() => _error = "Password must be at least 6 characters.");
        return;
      }
    }

    setState(() => _loading = true);

    try {
      final auth = FirebaseAuth.instance;

      UserCredential cred;

      if (isLogin) {
        // ✅ Login
        cred = await auth.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );

        final user = cred.user;
        if (user == null) {
          setState(() => _error = "Login failed. Please try again.");
          return;
        }

        final uid = user.uid;

        // ✅ مهم: لا ننشئ doc جديد أثناء Login إذا ما كان موجود
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (!userDoc.exists) {
          // هذا يعني عندك مستخدم Auth لكن بيانات Firestore ما انحفظت لأي سبب
          // نسوي إنشاء بسيط (بدون name/id لأنهم ما ينطلبون في Login)
          await _upsertUserDoc(
            uid: uid,
            email: email,
            role: 'student',
            setCreatedAtIfMissing: true,
          );
        } else {
          // فقط نحدث lastLoginAt
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        }

        final role = await _getRole(uid) ?? 'student';

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const MainNavPage(initialIndex: 0)),
          );
        }
      } else {
        // ✅ Register
        cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );

        final user = cred.user;
        if (user == null) {
          setState(() => _error = "Registration failed. Please try again.");
          return;
        }

        final uid = user.uid;

        await _upsertUserDoc(
          uid: uid,
          email: email,
          name: _nameC.text.trim(),
          studentId: _studentIdC.text.trim(),
          role: 'student',
          setCreatedAtIfMissing: true,
        );

        // الدور الحقيقي من Firestore (هنا غالبًا student)
        final role = await _getRole(uid) ?? 'student';

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const MainNavPage(initialIndex: 0)),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // ✅ رسائل أوضح
      if (e.code == 'user-not-found') {
        setState(() => _error = "No account found for this email.");
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() => _error = "Wrong email or password.");
      } else if (e.code == 'email-already-in-use') {
        setState(() => _error = "This email is already registered. Try Login.");
      } else {
        setState(() => _error = e.message ?? e.code);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0F1B2B);
    const Color cardColor = Color(0xFF1C2A3A);
    const Color accentGreen = Color(0xFF2ECC71);
    const Color accentRed = Color(0xFFE74C3C);

    final bool adminModeUIOnly = widget.forceAdmin;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(22),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  adminModeUIOnly
                      ? "Admin Login"
                      : isLogin
                          ? "Login"
                          : "Create Account",
                  style: const TextStyle(
                    color: accentGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  adminModeUIOnly
                      ? "Administrator Access Only"
                      : isLogin
                          ? "Welcome back to EduVL-AI"
                          : "Join EduVL-AI Virtual Learning",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),

                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentRed.withOpacity(0.6)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ===== Email =====
                _buildInputField(
                  controller: _emailC,
                  icon: Icons.email,
                  hint: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                // ===== Password =====
                _buildInputField(
                  controller: _passC,
                  icon: Icons.lock,
                  hint: "Password",
                  isPassword: true,
                ),

                // ✅ Forgot password يظهر فقط في Login
                if (isLogin) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: accentGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],

                // ✅ Confirm مباشرة تحت Password
                if (!isLogin && !adminModeUIOnly) ...[
                  const SizedBox(height: 18),
                  _buildInputField(
                    controller: _confirmC,
                    icon: Icons.lock_outline,
                    hint: "Confirm Password",
                    isPassword: true,
                  ),
                ],

                // ✅ بعدها الاسم والـ ID
                if (!isLogin && !adminModeUIOnly) ...[
                  const SizedBox(height: 18),
                  _buildInputField(
                    controller: _nameC,
                    icon: Icons.person,
                    hint: "Full Name",
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 18),
                  _buildInputField(
                    controller: _studentIdC,
                    icon: Icons.badge,
                    hint: "Student ID",
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          adminModeUIOnly ? accentRed : accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            adminModeUIOnly
                                ? "Admin Login"
                                : isLogin
                                    ? "Login"
                                    : "Register",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                if (!adminModeUIOnly)
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                      style: const TextStyle(
                        color: accentGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF162232),
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
