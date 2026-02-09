import 'package:flutter/material.dart';

import 'courses_page.dart';
import 'dashboard_page.dart';
import 'ai_help_page.dart';
import 'profile_page.dart';

class MainNavPage extends StatefulWidget {
  final int initialIndex;
  const MainNavPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  late int _index;

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
  List.generate(4, (_) => GlobalKey<NavigatorState>());

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  Future<bool> _onWillPop() async {
    final currentNavigator = _navigatorKeys[_index].currentState;

    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }
    return true;
  }

  Widget _buildTabNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
    );
  }

  void _onTap(int newIndex) {
    if (newIndex == _index) {
      // إذا ضغطتِ على نفس التبويب: يرجّع أول صفحة داخل التبويب
      _navigatorKeys[newIndex].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _index = newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTabNavigator(0, const CoursesPage()),
      _buildTabNavigator(1, const DashboardPage()),
      _buildTabNavigator(2, const AIHelpPage()),
      _buildTabNavigator(3, const ProfilePage()),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1B2B),
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          backgroundColor: const Color(0xFF15263D),
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progress"),
            BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: "AI Guide"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
