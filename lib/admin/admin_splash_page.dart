import 'package:flutter/material.dart';
import 'admin_login_page.dart';

class AdminSplashPage extends StatefulWidget {
  const AdminSplashPage({super.key});

  @override
  State<AdminSplashPage> createState() => _AdminSplashPageState();
}

class _AdminSplashPageState extends State<AdminSplashPage> {
  @override
  void initState() {
    super.initState();

    /// ⏳ Simulate loading
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminLoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0F1B2B);
    const Color accentGreen = Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🛡️ Admin Icon
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF162232),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: accentGreen,
                size: 64,
              ),
            ),

            const SizedBox(height: 24),

            /// App Name
            const Text(
              "EduVL-AI",
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// Subtitle
            Text(
              "Admin Control Panel",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            /// Loader
            const CircularProgressIndicator(
              color: accentGreen,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}