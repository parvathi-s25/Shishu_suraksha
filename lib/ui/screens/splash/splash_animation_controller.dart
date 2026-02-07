import 'package:flutter/material.dart';

class SplashAnimationController {
  late AnimationController controller;

  late Animation<double> logoFadeIn;
  late Animation<double> logoFadeOut;
  late Animation<double> taglineFadeIn;
  late Animation<double> logoTaglineFadeIn;
  late Animation<double> moveUp;

  SplashAnimationController(TickerProvider vsync) {
    controller = AnimationController(
      duration: const Duration(milliseconds: 7000),
      vsync: vsync,
    );

    // Step 1: Logo fade-in (0–1.5s)
    logoFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.214, curve: Curves.easeIn),
      ),
    );

    // Step 2: Logo fade-out (1.5–2.5s)
    logoFadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.214, 0.357, curve: Curves.easeOut),
      ),
    );

    // Step 3: Tagline fade-in (2.5–3.5s)
    taglineFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.357, 0.5, curve: Curves.easeIn),
      ),
    );

    // Step 4: Logo + tagline fade-in together (3.5–4.5s)
    logoTaglineFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.5, 0.643, curve: Curves.easeIn),
      ),
    );

    // Step 5: Move up (4.5–6.0s)
    moveUp = Tween<double>(begin: 0, end: -80).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.643, 0.857, curve: Curves.easeInOut),
      ),
    );
  }

  void start() => controller.forward();
  void dispose() => controller.dispose();
}
