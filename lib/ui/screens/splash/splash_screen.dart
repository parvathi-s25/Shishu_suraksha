import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/language_dropdown.dart';
import '../../widgets/cropped_logo.dart';
import 'splash_animation_controller.dart';

import 'package:shishu_suraksha/l10n/app_localizations.dart';
import 'package:shishu_suraksha/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashAnimationController anim;
  String selectedLanguage = "English";

  final Map<String, String> _languageMap = {
    "English": "en",
    "తెలుగు": "te",
    "हिंदी": "hi",
    "தமிழ்": "ta",
    "മലയാളം": "ml",
    "ಕನ್ನಡ": "kn",
    "বাংলা": "bn",
    "মराठी": "mr",
    "ગુજરાતી": "gu",
    "ਪੰਜਾਬੀ": "pa",
    "ଓଡ଼ିଆ": "or",
  };

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // FULL-SCREEN BACKGROUND IMAGE (bg1.png as requested)
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg1.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback color if image missing
                return Container(color: const Color(0xFFFFF8F0));
              },
            ),
          ),

          // SOFT BLUR OVERLAY (Glassmorphism base)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),

          // MAIN CONTENT
          AnimatedBuilder(
            animation: anim.controller,
            builder: (context, _) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO + TAGLINE CONTAINER
                        Transform.translate(
                          offset: Offset(0, anim.moveUp.value),
                          child: Column(
                            children: [
                              // TRIANGULAR LOGO FORMATION
                              Opacity(
                                opacity: anim.logoFadeIn.value,
                                child: Column(
                                  children: [
                                    // Top Logo: AP
                                    _buildBorderlessLogo(
                                      'assets/logos/AP.png',
                                      140, // Uniform size
                                      scale: 1.25,
                                    ),
                                    const SizedBox(height: 20), // Adjusted vertical gap
                                    // Bottom Row: WDCW and RTIH
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildBorderlessLogo(
                                          'assets/logos/WDCW.png',
                                          140, // Uniform size
                                          scale: 1.25,
                                        ),
                                        const SizedBox(width: 40), // Adjusted horizontal gap
                                        _buildBorderlessLogo(
                                          'assets/logos/RTIH.png',
                                          140, // Uniform size
                                          scale: 1.25,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // TAGLINE (CLOSER TO LOGO)
                              Opacity(
                                opacity: anim.taglineFadeIn.value,
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

                        if (anim.controller.value > 0.6)
                          const SizedBox(height: 40), 

                        // GLASSMORPHISM CARD - LANGUAGE DROPDOWN
                        if (anim.controller.value > 0.6)
                          Opacity(
                            opacity: ((anim.controller.value - 0.6) * 5).clamp(0.0, 1.0),
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
                                          AppLocalizations.of(context)!.selectLanguage,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF005F66),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        LanguageDropdown(
                                          onLanguageChanged: (lang) {
                                            setState(() {
                                              selectedLanguage = lang;
                                            });
                                            // Trigger global locale change
                                            String code = _languageMap[lang] ?? "en";
                                            MyApp.setLocale(context, Locale(code));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: anim.controller.value > 0.6 ? 20 : 80), // Reduced gap

                        // GLASSMORPHISM CARD - GET STARTED BUTTON
                        if (anim.controller.value > 0.6)
                          Opacity(
                            opacity: ((anim.controller.value - 0.6) * 5)
                                .clamp(0.0, 1.0),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () {
                                          String code = _languageMap[selectedLanguage] ?? "en";
                                          
                                          Navigator.pushNamed(
                                            context,
                                            "/auth",
                                            arguments: code,
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF005F66),
                                                Color(0xFF008C96)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF005F66)
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            AppLocalizations.of(context)!.getStarted,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
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

  Widget _buildBorderlessLogo(String path, double size, {double scale = 1.25}) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            path,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

