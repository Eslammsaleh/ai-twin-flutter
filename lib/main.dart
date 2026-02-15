import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'providers/twin_provider.dart';

import 'screens/home/home_screen.dart';
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
        '/home': (context) => const HomeScreen(),
        '/chat': (context) => const ChatPage(),
        '/timeline': (context) => const TimelinePage(),
        '/replay': (context) => const ReplayPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
