import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  void nextPage() {
    if (currentIndex < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
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
        /// Background Image
        SizedBox.expand(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),

        /// Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 🔝 TEXT AT TOP
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34, // 🔥 أكبر
                      fontWeight:
                          isBoldTitle ? FontWeight.bold : FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17, // 🔥 أكبر
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ),

                const Spacer(),

                /// Button (Center Bottom)
                Align(
                  alignment: Alignment.center,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          /// 1️⃣ Screen One
          buildPage(
            image: 'assets/images/onboarding_one.png',
            title: 'Turn Your Text\nInto Reality',
            subtitle:
                'Type any scenario, and let our AI\ntransform words into\nvivid scenes.',
            buttonText: 'Next',
          ),

          /// 2️⃣ Screen Two
          buildPage(
            image: 'assets/images/onboarding_two.png',
            title: 'Your Digital Twin:\nVoice & Likeness',
            subtitle:
                'Accurate cloning of characters, voices,\nand expressions. Lifelike video\nindistinguishable from reality.',
            buttonText: 'Next',
          ),

          /// 3️⃣ Screen Three
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
