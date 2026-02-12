import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'splash_screen.dart';

class OpeningAnimationScreen extends StatefulWidget {
  const OpeningAnimationScreen({super.key});

  @override
  State<OpeningAnimationScreen> createState() => _OpeningAnimationScreenState();
}

class _OpeningAnimationScreenState extends State<OpeningAnimationScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/intro.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = const Duration(seconds: 3) // Enforce 3 seconds
              ..forward().then((value) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const SplashScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(seconds: 1), // Smooth 1s fade
                  ),
                );
              });
          },
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
