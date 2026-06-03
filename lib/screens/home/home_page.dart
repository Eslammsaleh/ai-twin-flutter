import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/chat/chat_page.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/widgets/info_card.dart';

import '../../providers/twin_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    
    // 1. محاولة جلب الـ Nickname المخزن في الـ displayName أولاً
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }

    // 2. حل احتياطي في حال كان الحساب قديماً ولم يسجل بـ Nickname
    String email = user?.email ?? "User";
    String namePart = email.split('@')[0];
    String cleanName = namePart.replaceAll(RegExp(r'\d'), '');

    return cleanName.isNotEmpty ? cleanName : "User";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final twin = Provider.of<TwinProvider>(context);
    final userName = _getUserName();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              const Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                userName, // سيعرض هنا الـ Nickname الجديد مباشرة 🔥
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your AI Cinematic Assistant is ready",
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 25),
              // Info Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoCard(
                    title: "Memories",
                    value: twin.profile.memories.toString(),
                    icon: Icons.favorite,
                  ),
                  InfoCard(
                    title: "Twin Level",
                    value: twin.profile.level,
                    icon: Icons.star,
                  ),
                  InfoCard(
                    title: "Assistant",
                    value: "Open",
                    icon: Icons.smart_toy,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Text(
                "FEATURED TOOLS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _featureBox(
                    Icons.smart_toy,
                    "AI Assistant",
                    Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatPage(),
                        ),
                      );
                    },
                  ),
                  _featureBox(
                    Icons.auto_graph,
                    "Progress",
                    Colors.green,
                  ),
                  _featureBox(
                    Icons.favorite,
                    "Memories",
                    Colors.red,
                  ),
                  _featureBox(
                    Icons.settings,
                    "Settings",
                    Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/settings',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Cinematic Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFe1b2ff),
                      Color(0xFFd3a4ff),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        "AI Cinematic Assistant\nLearn cinematic prompting",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.flash_on,
                      color: AppColors.primary,
                      size: 45,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureBox(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}