import 'package:flutter/material.dart';
import '../auth/auth_gate.dart'; // ✅ تأكدي هذا المسار صحيح عندك

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0F1B2B);
    const Color accentGreen = Color(0xFF2ECC71);
    const Color iconBg = Color(0xFF193047);

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
              ),
              child: ClipOval(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, 10), // ✅ نزّل اللوقو لتحت (عدلي الرقم إذا تبين)
                    child: Transform.scale(
                      scale: 3.2,
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
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
