import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  final List<Map<String, String>> events = const [
    {"title": "Created new memory", "time": "10 Dec 2025", "icon": "favorite"},
    {"title": "Chat with LifeTwin", "time": "09 Dec 2025", "icon": "chat"},
    {"title": "Twin Level upgraded", "time": "09 Dec 2025", "icon": "star"},
    {"title": "Video generated", "time": "08 Dec 2025", "icon": "play_circle_fill"},
    {"title": "New AI suggestion", "time": "07 Dec 2025", "icon": "lightbulb"},
  ];

  IconData _getIcon(String name) {
    switch (name) {
      case "favorite": return Icons.favorite;
      case "chat": return Icons.chat;
      case "star": return Icons.star;
      case "play_circle_fill": return Icons.play_circle_fill;
      case "lightbulb": return Icons.lightbulb;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline"),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final icon = _getIcon(event["icon"]!);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(icon, color: AppColors.primary),
              ),
              title: Text(event["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(event["time"]!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // ممكن تضيف مستقبلاً Navigation لتفاصيل الحدث
              },
            ),
          );
        },
      ),
    );
  }
}
