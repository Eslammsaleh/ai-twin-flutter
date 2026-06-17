import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/chat/chat_page.dart';
import 'package:flutter_application_1/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.displayName != null &&
        user!.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }

    String email = user?.email ?? "User";
    String namePart = email.split('@')[0];
    String cleanName = namePart.replaceAll(RegExp(r'\d'), '');

    return cleanName.isNotEmpty ? cleanName : "User";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = _getUserName();

    Color adaptive(Color light, Color dark) {
      return isDark ? dark : light;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                userName,
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
              const SizedBox(height: 35),
              const Text(
                "What would you like to do?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Create AI Movie
              _actionCard(
                context,
                icon: Icons.movie_creation,
                title: "Create AI Movie",
                subtitle:
                    "Generate cinematic videos from your ideas",
                bgColor: adaptive(
                  const Color(0xFFF4ECFA),
                  const Color(0xFF2A1F33),
                ),
                iconColor: Colors.deepPurple,
                onTap: () {
                  Navigator.pushNamed(context, '/replay');
                },
              ),

              const SizedBox(height: 15),

              // AI Assistant
              _actionCard(
                context,
                icon: Icons.smart_toy,
                title: "AI Assistant",
                subtitle:
                    "Get help with prompts, characters and scenes",
                bgColor: adaptive(
                  const Color(0xFFEFF6FF),
                  const Color(0xFF1A2A3A),
                ),
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // Settings
              _actionCard(
                context,
                icon: Icons.settings,
                title: "Settings",
                subtitle:
                    "Customize your experience and account",
                bgColor: adaptive(
                  const Color(0xFFFFF4EA),
                  const Color(0xFF2A241C),
                ),
                iconColor: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return _AnimatedActionCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDarkText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: iconColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Color isDarkText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }
}

class _AnimatedActionCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedActionCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedActionCard> createState() =>
      _AnimatedActionCardState();
}

class _AnimatedActionCardState
    extends State<_AnimatedActionCard> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.97),
      onTapUp: (_) {
        setState(() => scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}