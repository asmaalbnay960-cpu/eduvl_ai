import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/register_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // ✅ Dialog داكن لتغيير كلمة المرور
  static Future<void> _showChangePasswordDialog(BuildContext context) async {
    const bg = Color(0xFF0F1B2B);
    const card = Color(0xFF15263D);
    const fieldBg = Color(0xFF162232);
    const accent = Color(0xFF32D296);
    const danger = Color(0xFFE74C3C);

    final currentC = TextEditingController();
    final newC = TextEditingController();
    final confirmC = TextEditingController();

    bool loading = false;
    String? errorText;

    InputDecoration deco(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: fieldBg,
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.2),
        ),
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: !loading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> submit() async {
              final user = FirebaseAuth.instance.currentUser;
              final email = user?.email;

              if (user == null || email == null) {
                setState(() => errorText = "You must be logged in.");
                return;
              }

              final currentPass = currentC.text.trim();
              final newPass = newC.text.trim();
              final confirmPass = confirmC.text.trim();

              if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                setState(() => errorText = "Please fill all fields.");
                return;
              }
              if (newPass.length < 6) {
                setState(() => errorText = "New password must be at least 6 characters.");
                return;
              }
              if (newPass != confirmPass) {
                setState(() => errorText = "New passwords do not match.");
                return;
              }

              setState(() {
                loading = true;
                errorText = null;
              });

              try {
                // ✅ Re-authentication required for sensitive actions
                final cred = EmailAuthProvider.credential(
                  email: email,
                  password: currentPass,
                );
                await user.reauthenticateWithCredential(cred);

                // ✅ Update password
                await user.updatePassword(newPass);

                if (ctx.mounted) Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated successfully.")),
                );
              } on FirebaseAuthException catch (e) {
                setState(() => errorText = e.message ?? e.code);
              } catch (e) {
                setState(() => errorText = e.toString());
              } finally {
                setState(() => loading = false);
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Change Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "For security, enter your current password first.",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    if (errorText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: bg.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: danger.withOpacity(0.7)),
                        ),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextField(
                      controller: currentC,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: deco("Current Password", Icons.lock),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: newC,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: deco("New Password", Icons.lock_reset),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: confirmC,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: deco("Confirm New Password", Icons.verified),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: loading ? null : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              foregroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: loading ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    "Update",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    currentC.dispose();
    newC.dispose();
    confirmC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // إذا لسبب ما ما فيه مستخدم
    if (user == null) {
      return const RegisterPage();
    }

    final userDocStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Material(
            color: Color(0xFF0F1B2B),
            child: SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final data = snap.data?.data() ?? {};

        final name = (data['name'] ?? 'No Name') as String;
        final studentId = (data['studentId'] ?? '—') as String;
        final module = (data['module'] ?? 'Physics Module') as String;
        final email = (data['email'] ?? user.email ?? '') as String;

        return Material(
          color: const Color(0xFF0F1B2B),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profile & Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 28),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 95,
                          height: 95,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF32D296),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF32D296),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Student ID: $studentId",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1FAF77),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            module,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "General Settings",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),

                  settingsTile(
                    icon: Icons.lock_reset,
                    title: "Change Password",
                    subtitle: "Update your account password",
                    onTap: () => _showChangePasswordDialog(context),
                  ),

                  settingsTile(
                    icon: Icons.dark_mode,
                    title: "Theme",
                    subtitle: "Dark Mode",
                    onTap: () {},
                  ),
                  settingsTile(
                    icon: Icons.notifications,
                    title: "Notifications",
                    subtitle: "Quiz reminders & updates",
                    onTap: () {},
                  ),
                  settingsTile(
                    icon: Icons.info_outline,
                    title: "About App",
                    subtitle: "EduVL-AI version 1.0",
                    onTap: () {},
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // ✅ signOut من Firebase
                        await FirebaseAuth.instance.signOut();

                        if (!context.mounted) return;

                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
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

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF15263D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF32D296)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white54,
        ),
      ),
    );
  }
}
