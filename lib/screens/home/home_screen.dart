import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/chat/chat_page.dart';
import 'package:flutter_application_1/screens/home/home_page.dart';
import 'package:flutter_application_1/screens/replay/replay_page.dart';
import 'package:flutter_application_1/screens/settings/settings_page.dart';
import 'package:flutter_application_1/screens/timeline/timeline_page.dart';
import 'package:flutter_application_1/theme/app_colors.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  // 2. شيل الـ 'const' وشيل الـ Text وحط الـ Widgets
  final List<Widget> pages = [
    const HomePage(),        // صفحة الهوم
    const ChatPage(),        // صفحة الشات الجديدة
    const TimelinePage(),    // صفحة التايم لاين الجديدة
    const ReplayPage(),      // صفحة الريبلاي الجديدة
    const SettingsPage() // لسه زي ما هي مؤقتاً
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[currentIndex], // هنا هيعرض الصفحة المختارة
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Timeline"),
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: "Replay"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}