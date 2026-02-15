import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/register_page.dart';
import '../student/main_nav_page.dart';
import '../admin/admin_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String> _getRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    return (data?['role'] ?? 'student') as String;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // Loading
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        final user = snap.data;
        if (user == null) {
          return const RegisterPage(); // نفس صفحتكم (Login/Register)
        }

        // Logged in -> get role
        return FutureBuilder<String>(
          future: _getRole(user.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
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
