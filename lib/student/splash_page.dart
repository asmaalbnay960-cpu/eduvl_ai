import 'package:flutter/material.dart';
import '../auth/register_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

    // يخلي السبلاش يظهر أولاً ثم يبدأ العد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0F1B2B); // deep navy
    const Color accentGreen = Color(0xFF2ECC71);
    const Color iconBg = Color(0xFF193047);

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: iconBg,
              ),
              child: ClipOval(
                child: Transform.translate(
                  offset: const Offset(0, 12), // 👈 نزليه لتحت (عدلي الرقم)
                  child: Transform.scale(
                    scale: 2.9,
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // TITLE
            const Text(
              "EduVL-AI",
              style: TextStyle(
                fontSize: 32,
                color: accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // SUBTITLE
            Text(
              "Interactive Virtual Learning",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 35),

            // LOADING SPINNER
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
