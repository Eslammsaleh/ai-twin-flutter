import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/app_colors.dart';
import 'package:flutter_application_1/widgets/info_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome
            const Text("Welcome back",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            const Text("Alex",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text(
              "Your LifeTwin is growing stronger each conversation",
              style: TextStyle(fontSize: 15, color: AppColors.textLight),
            ),
            const SizedBox(height: 25),

            // Info Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                InfoCard(title: "Memories", value: "24", icon: Icons.favorite),
                InfoCard(title: "Twin Level", value: "Advanced", icon: Icons.star),
                InfoCard(title: "This Week", value: "12", icon: Icons.access_time),
              ],
            ),

            const SizedBox(height: 35),

            const Text("FEATURED TOOLS",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight)),
            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _featureBox(Icons.camera_alt, "AI Photos", Colors.blue),
                _featureBox(Icons.auto_graph, "Progress", Colors.green),
                _featureBox(Icons.favorite, "Memories", Colors.red),
                _featureBox(Icons.settings, "Settings", Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/settings')),
              ],
            ),

            const SizedBox(height: 30),

            // Create Video Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFe1b2ff), Color(0xFFd3a4ff)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      "Create Video\nAI generated memories in minutes",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.flash_on, color: AppColors.primary, size: 45),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureBox(IconData icon, String title, Color color, {VoidCallback? onTap}) {
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
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
