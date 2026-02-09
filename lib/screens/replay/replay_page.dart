import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/memory.dart';
import '../../theme/app_colors.dart';
import '../../providers/twin_provider.dart';

class ReplayPage extends StatefulWidget {
  const ReplayPage({super.key});

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  Memory? selectedMemory;

  final List<Memory> memories = [
    Memory(
      title: "Job Interview",
      date: "10 Dec 2025",
      description: "You were nervous and rushed your answers.",
    ),
    Memory(
      title: "Important Chat",
      date: "08 Dec 2025",
      description: "You replied emotionally instead of logically.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Life Replay"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Memory",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /// Memories List
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: memories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final memory = memories[index];
                  final isSelected = selectedMemory == memory;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedMemory = memory);

                      /// ✔ كل Replay = Memories++
                      Provider.of<TwinProvider>(context, listen: false)
                          .addMemory();
                    },
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            memory.date,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.play_circle_fill,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            if (selectedMemory != null) ...[
              const Text(
                "LifeTwin Analysis",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _analysisCard(
                "What happened?",
                selectedMemory!.description,
                Icons.history,
              ),

              _analysisCard(
                "AI Insight",
                "You reacted quickly without fully analyzing the situation.",
                Icons.psychology,
              ),

              _analysisCard(
                "What if?",
                "If you had stayed calm, the conversation would have ended positively.",
                Icons.auto_graph,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _analysisCard(String title, String text, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
