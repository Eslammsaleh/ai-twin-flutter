import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/twin_provider.dart';

class LifeTwinEditorPage extends StatelessWidget {
  const LifeTwinEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final twin = Provider.of<TwinProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit LifeTwin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: twin.mood,
              min: 0,
              max: 100,
              divisions: 10,
              label: twin.mood.round().toString(),
              onChanged: (value) {
                twin.setMood(value);
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'Confidence',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: twin.confidence,
              min: 0,
              max: 100,
              divisions: 10,
              label: twin.confidence.round().toString(),
              onChanged: (value) {
                twin.setConfidence(value);
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'Logic',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: twin.logic,
              min: 0,
              max: 100,
              divisions: 10,
              label: twin.logic.round().toString(),
              onChanged: (value) {
                twin.setLogic(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
