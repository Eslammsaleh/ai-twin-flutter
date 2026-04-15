import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Theme & Providers
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/twin_provider.dart';

// Screens
import 'screens/settings/settings_page.dart';
import 'screens/chat/chat_page.dart';
import 'screens/replay/replay_page.dart';
import 'screens/timeline/timeline_page.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

// Auth
import 'screens/auth/auth_gate.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/auth/sign_up_page.dart';

// NEW: AI Video Integration
import 'api.dart';
import 'video_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TwinProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeTwin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),

        // Auth
        '/auth': (context) => const AuthGate(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),

        // App
        '/home': (context) => const AIVideoHomeScreen(),
        '/chat': (context) => const ChatPage(),
        '/timeline': (context) => const TimelinePage(),
        '/replay': (context) => const ReplayPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

//
// 🔥 NEW HOME SCREEN (AI VIDEO GENERATOR SCREEN)
//
class AIVideoHomeScreen extends StatefulWidget {
  const AIVideoHomeScreen({super.key});

  @override
  State<AIVideoHomeScreen> createState() => _AIVideoHomeScreenState();
}

class _AIVideoHomeScreenState extends State<AIVideoHomeScreen> {
  String? videoUrl;
  String? promptText;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Video Generator")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);

                      final data = await generateVideo("ولد حزين ثم يبتسم");

                      setState(() {
                        videoUrl = data["video_url"];
                        promptText = data["prompt"];
                        loading = false;
                      });
                    },
              child: Text(loading ? "Processing..." : "Generate Video"),
            ),

            const SizedBox(height: 20),

            if (promptText != null)
              Text(
                promptText!,
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 20),

            if (videoUrl != null)
              Expanded(child: VideoWidget(videoUrl: videoUrl!)),
          ],
        ),
      ),
    );
  }
}