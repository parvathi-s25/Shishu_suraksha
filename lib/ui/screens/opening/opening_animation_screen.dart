import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';

class OpeningAnimationScreen extends StatefulWidget {
  const OpeningAnimationScreen({super.key});

  @override
  State<OpeningAnimationScreen> createState() => _OpeningAnimationScreenState();
}

class _OpeningAnimationScreenState extends State<OpeningAnimationScreen> {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    // Simulate 3-second animation sequence
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simulating the merged logos effect with a row of logos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Image.asset('assets/images/logo.png', width: 80, height: 80),
                 // In a real reconstruction we'd need the specific AP/WomenChild logos if available, 
                 // but 'logo.png' is safe for now if others are missing.
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Shishu Suraksha",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
