import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTall = size.height / size.width > 2.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Image.asset(
                'assets/images/splash.png',
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: isTall ? BoxFit.fitHeight : BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }
}