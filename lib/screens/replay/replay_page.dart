import 'package:flutter/material.dart';

class ReplayPage extends StatelessWidget {
  const ReplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Replay")),
      body: const Center(
        child: Icon(Icons.play_circle_fill, size: 80, color: Colors.blue),
      ),
    );
  }
}