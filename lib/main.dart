import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
import 'package:flutter_application_1/screens/settings/settings_page.dart';
import 'package:flutter_application_1/screens/chat/chat_page.dart';
import 'package:flutter_application_1/screens/replay/replay_page.dart';
import 'package:flutter_application_1/screens/timeline/timeline_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeTwin',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/chat': (context) => const ChatPage(),
        '/timeline': (context) => const TimelinePage(),
        '/replay': (context) => const ReplayPage(),
        '/settings': (context) => const SettingsPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
