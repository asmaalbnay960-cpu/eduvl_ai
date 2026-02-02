import 'package:flutter/material.dart';
import '../auth/register_page.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegisterPage(forceAdmin: true);
  }
}
