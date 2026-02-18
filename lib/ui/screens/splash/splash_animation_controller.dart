import 'package:flutter/material.dart';

class SplashAnimationController {
  late AnimationController controller;

  late Animation<double> logoFadeIn;
  late Animation<double> taglineFadeIn;
  late Animation<double> moveUp;

  SplashAnimationController(TickerProvider vsync) {
    controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: vsync,
    );

    // Step 1: Logo fade-in (0–0.8s)
    logoFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.32, curve: Curves.easeIn),
      ),
    );

    // Step 2: Tagline fade-in (0.8–1.5s)
    taglineFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.32, 0.6, curve: Curves.easeIn),
      ),
    );

    // Step 3: Move up (1.5–2.5s)
    moveUp = Tween<double>(begin: 0, end: -40).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  void start() => controller.forward();
  void dispose() => controller.dispose();
}

