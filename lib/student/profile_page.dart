import 'package:flutter/material.dart';
import '../auth/register_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Profile & Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.white24),

              const SizedBox(height: 25),

              // Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF32D296),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF32D296),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Asmaa S. Albannay",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Student ID: 45012308",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1FAF77),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Physics Module",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // General Settings
              const Text(
                "General Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.white24),

              const SizedBox(height: 10),

              // Theme
              settingsTile(
                icon: Icons.dark_mode,
                title: "Theme",
                subtitle: "Dark Mode",
                onTap: () {},
              ),

              // Notifications
              settingsTile(
                icon: Icons.notifications,
                title: "Notifications",
                subtitle: "Quiz reminders & updates",
                onTap: () {},
              ),

              const Spacer(),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                        (route) => false,
                  );
                },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 55),
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

  static Widget settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF32D296)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing:
      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
    );
  }
}