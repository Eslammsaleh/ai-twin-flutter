import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/settings/life_twin_editor_page.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/twin_provider.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// User Info
          Row(
            children: const [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alex",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "alex@email.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          /// 🔥 LifeTwin Profile (Clickable)
          const SizedBox(height: 25),

          Consumer<TwinProvider>(
            builder: (context, twin, _) {
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LifeTwinEditorPage(),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppColors.cardBackground,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "LifeTwin Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Level: ${twin.profile.level}"),
                        Text("Conversations: ${twin.profile.conversations}"),
                        Text("Memories: ${twin.profile.memories}"),
                        const SizedBox(height: 8),
                        const Text(
                          "Tap to edit",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),
          const Text(
            "GENERAL",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 10),

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeProvider.isDark,
            onChanged: themeProvider.toggleTheme,
            activeColor: AppColors.primary,
          ),

          SwitchListTile(
            title: const Text("Notifications"),
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.primary,
          ),

          ListTile(
            title: const Text("Language"),
            subtitle: const Text("English"),
            trailing: const Icon(Icons.language),
            onTap: () {},
          ),

          ListTile(
            title: const Text("About App"),
            trailing: const Icon(Icons.info_outline),
            onTap: () {},
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {},
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
