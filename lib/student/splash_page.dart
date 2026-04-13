import 'package:flutter/material.dart';
import '../auth/auth_gate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 الشعار بدون دائرة
            SizedBox(
              width: 200,
              height: 200,
              child: Transform.scale(
                scale: 2.5, // 👈 هذا اللي يكبر الشعار
                child: Image.asset(
                  "assets/images/logo.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "EduVL-AI",
              style: TextStyle(
                fontSize: 32,
                color: accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Interactive Virtual Learning",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 35),

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