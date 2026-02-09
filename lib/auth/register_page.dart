import 'package:flutter/material.dart';
import '../student/home_page.dart';
import '../admin/admin_login_page.dart';
import '../admin/admin_dashboard_page.dart';
import '../admin/admin_splash_page.dart';

class RegisterPage extends StatefulWidget {
  final bool forceAdmin;

  const RegisterPage({super.key, this.forceAdmin = false});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLogin = true;
  String selectedRole = 'student';

  bool get isAdmin => selectedRole == 'admin';

  @override
  void initState() {
    super.initState();
    if (widget.forceAdmin) {
      selectedRole = 'admin';
      isLogin = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF0F1B2B);
    const Color cardColor = Color(0xFF1C2A3A);
    const Color accentGreen = Color(0xFF2ECC71);
    const Color accentRed = Color(0xFFE74C3C);

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
                  isAdmin
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
                  isAdmin
                      ? "Administrator Access Only"
                      : isLogin
                      ? "Welcome back to EduVL-AI"
                      : "Join EduVL-AI Virtual Learning",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 30),

                _buildInputField(icon: Icons.email, hint: "Email"),
                const SizedBox(height: 18),
                _buildInputField(
                  icon: Icons.lock,
                  hint: "Password",
                  isPassword: true,
                ),

                if (!isLogin && !isAdmin) ...[
                  const SizedBox(height: 18),
                  _buildInputField(
                    icon: Icons.lock_outline,
                    hint: "Confirm Password",
                    isPassword: true,
                  ),
                ],

                const SizedBox(height: 20),

                /// ROLE SELECTOR (DEV ONLY)
                if (!widget.forceAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF162232),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF162232),
                      underline: const SizedBox(),
                      iconEnabledColor: Colors.white70,
                      items: const [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text("Student",
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text("Admin",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                          if (isAdmin) isLogin = true;
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isAdmin) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardPage(),
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isAdmin ? accentRed : accentGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isAdmin
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

                if (!isAdmin)
                  TextButton(
                    onPressed: () =>
                        setState(() => isLogin = !isLogin),
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
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
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