import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initOnboarding();
  }

  Future<void> _initOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;

    if (seen) {
      Navigator.pushReplacementNamed(context, '/auth');
      return;
    }

    setState(() => _isLoading = false);
  }

  void nextPage() async {
    if (currentIndex < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_seen', true);
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  Widget buildPage({
    required String image,
    required String title,
    required String subtitle,
    required String buttonText,
    bool isBoldTitle = false,
  }) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.asset(image, fit: BoxFit.cover),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight:
                          isBoldTitle ? FontWeight.bold : FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Subtitle
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),

                  const Spacer(),

                  // Button
                  Center(
                    child: GestureDetector(
                      onTap: nextPage,
                      child: Container(
                        width: 180,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.purpleAccent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: [
          buildPage(
            image: 'assets/images/onboarding_one.png',
            title: 'Turn Your Text\nInto Reality',
            subtitle:
                'Type any scenario, and let our AI\ntransform words into\nvivid scenes.',
            buttonText: 'Next',
          ),
          buildPage(
            image: 'assets/images/onboarding_two.png',
            title: 'Your Digital Twin:\nVoice & Likeness',
            subtitle:
                'Accurate cloning of characters, voices,\nand expressions. Lifelike video\nindistinguishable from reality.',
            buttonText: 'Next',
          ),
          buildPage(
            image: 'assets/images/onboarding_three.png',
            title: 'Bring Your Stories\nTo Life',
            subtitle:
                'Share high-quality videos and\nanimate the real world with\nunprecedented content.',
            buttonText: 'Get Started',
            isBoldTitle: true,
          ),
        ],
      ),
    );
  }
}