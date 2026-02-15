import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/register_page.dart';
import '../student/main_nav_page.dart';
import '../admin/admin_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const Color background = Color(0xFF0F1B2B);
  static const Color accentGreen = Color(0xFF2ECC71);

  Future<String> _getRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // ✅ لو الوثيقة غير موجودة أو البيانات null نرجّع student بدل ما يعلّق/يطلع خطأ
    if (!doc.exists) return 'student';

    final data = doc.data();
    return (data?['role'] ?? 'student').toString();
  }

  Widget _loading() {
    return const Scaffold(
      backgroundColor: background,
      body: Center(
        child: CircularProgressIndicator(
          color: accentGreen,
          strokeWidth: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // ✅ Loading
        if (snap.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        // ✅ Not logged in
        final user = snap.data;
        if (user == null) {
          return const RegisterPage();
        }

        // ✅ Logged in -> get role
        return FutureBuilder<String>(
          future: _getRole(user.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return _loading();
            }

            // ✅ حتى لو صار error ما نخليه يطلع أبيض أو يوقف
            if (roleSnap.hasError) {
              return const MainNavPage(initialIndex: 0);
            }

            final role = roleSnap.data ?? 'student';

            if (role == 'admin') {
              return const AdminDashboardPage();
            }
            return const MainNavPage(initialIndex: 0);
          },
        );
      },
    );
  }
}
