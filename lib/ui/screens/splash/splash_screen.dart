import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/language_dropdown.dart';
import 'splash_animation_controller.dart';
import '../auth/authentication_screen.dart';
import '../permissions/permission_request_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashAnimationController anim;
  String selectedLanguage = 'English'; // Track selected language

  @override
  void initState() {
    super.initState();
    anim = SplashAnimationController(this);
    anim.start();
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FULL-SCREEN BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg1.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFFFFF8F0));
              },
            ),
          ),

          // SOFT BLUR OVERLAY
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.white.withOpacity(0.22),
              ),
            ),
          ),

          // MAIN CONTENT
          AnimatedBuilder(
            animation: anim.controller,
            builder: (context, _) {
              return Center(
                child: SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // LOGO + TAGLINE CONTAINER (CENTERED)
                        Transform.translate(
                          offset: Offset(0, anim.moveUp.value),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // LOGO (30% LARGER - 220 * 1.3 = 286)
                              Opacity(
                                opacity: (anim.logoFadeIn.value -
                                    anim.logoFadeOut.value +
                                    anim.logoTaglineFadeIn.value).clamp(0.0, 1.0),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 286,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 286,
                                      height: 286,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.child_care,
                                        size: 100,
                                        color: const Color(0xFF4FB7A7),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 4),

                              // TAGLINE (CLOSER TO LOGO, DEEP TEAL)
                              Opacity(
                                opacity: (anim.taglineFadeIn.value +
                                    anim.logoTaglineFadeIn.value).clamp(0.0, 1.0),
                                child: const Text(
                                  "మీ బిడ్డ భద్రత మా బాధ్యత",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 23,
                                    color: Color(0xFF005F66),
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // GLASSMORPHISM CARD - LANGUAGE DROPDOWN
                        if (anim.controller.value > 0.643)
                          Opacity(
                            opacity: ((anim.controller.value - 0.643) * 3).clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Select Language",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: const Color(0xFF005F66),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        LanguageDropdown(
                                          onLanguageChanged: (language) {
                                            setState(() {
                                              selectedLanguage = language;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: anim.controller.value > 0.643 ? 40 : 120),

                        // GLASSMORPHISM CARD - GET STARTED BUTTON
                        if (anim.controller.value > 0.643)
                          Opacity(
                            opacity: ((anim.controller.value - 0.643) * 3).clamp(0.0, 1.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: double.infinity,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) => PermissionRequestScreen(
                                                  selectedLanguage: selectedLanguage,
                                                ),
                                              ),
                                            );
                                        },
                                        child: const Center(
                                          child: Text(
                                            "Get Started",
                                            style: TextStyle(
                                              color: Color(0xFF005F66),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
