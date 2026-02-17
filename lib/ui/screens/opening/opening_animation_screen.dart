import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../../widgets/language_dropdown.dart';
import '../../widgets/cropped_logo.dart';
import '../../screens/splash/splash_screen.dart';

/// 5-Phase Splash Animation
///
/// Phase 1 (0.00–0.15): Three government logos fade in, triangular formation
/// Phase 2 (0.15–0.30): Hold — dignified display
/// Phase 3 (0.30–0.55): Logos merge toward center with glow + particles
/// Phase 4 (0.55–0.75): Final ShishuSuraksha logo appears with tagline
/// Phase 5 (0.75–1.00): Language selection + Get Started slide in
class OpeningAnimationScreen extends StatefulWidget {
  const OpeningAnimationScreen({super.key});

  @override
  State<OpeningAnimationScreen> createState() => _OpeningAnimationScreenState();
}

class _OpeningAnimationScreenState extends State<OpeningAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  // Phase 1: Logo fade-in
  late Animation<double> _logosFadeIn;
  late Animation<double> _logosScale;

  // Phase 3: Merge animations
  late Animation<double> _mergeProgress;
  late Animation<double> _logosFadeOut;
  late Animation<double> _glowIntensity;

  // Phase 4: Final logo
  late Animation<double> _finalLogoFadeIn;
  late Animation<double> _finalLogoScale;
  late Animation<double> _taglineFadeIn;

  // Phase 5: UI
  late Animation<double> _uiFadeIn;
  late Animation<Offset> _uiSlideUp;

  String selectedLanguage = "English";

  final Map<String, String> _languageMap = {
    "English": "en",
    "తెలుగు": "te",
    "हिंदी": "hi",
    "தமிழ்": "ta",
    "മലയാളം": "ml",
    "ಕನ್ನಡ": "kn",
    "বাংলা": "bn",
    "मराठी": "mr",
    "ગુજરાતી": "gu",
    "ਪੰਜਾਬੀ": "pa",
    "ଓଡ଼ିଆ": "or",
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 6500),
      vsync: this,
    );

    // Phase 1 (0.00–0.15): Logos appear
    _logosFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeOut),
      ),
    );
    _logosScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeOutBack),
      ),
    );

    // Phase 3 (0.30–0.55): Merge
    _mergeProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.55, curve: Curves.easeInOutCubic),
      ),
    );
    _logosFadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.55, curve: Curves.easeIn),
      ),
    );
    _glowIntensity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.55, curve: Curves.easeInOut),
      ),
    );

    // Phase 4 (0.55–0.75): Final logo
    _finalLogoFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.70, curve: Curves.easeOut),
      ),
    );
    _finalLogoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.72, curve: Curves.easeOutBack),
      ),
    );
    _taglineFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.78, curve: Curves.easeOut),
      ),
    );

    // Phase 5 (0.75–1.0): UI
    _uiFadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.95, curve: Curves.easeOut),
      ),
    );
    _uiSlideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height * 0.35;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Background gradient
              Positioned.fill(child: _buildBackground()),

              // Particle effect during merge
              if (_controller.value > 0.30 && _controller.value < 0.65)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParticlePainter(
                      progress: _mergeProgress.value,
                      centerX: centerX,
                      centerY: centerY,
                      glowIntensity: _glowIntensity.value,
                    ),
                  ),
                ),

              // Glow effect at center during merge
              if (_controller.value > 0.35 && _controller.value < 0.65)
                Positioned(
                  left: centerX - 60,
                  top: centerY - 60,
                  child: Opacity(
                    opacity: _glowIntensity.value * 0.7,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF009688)
                                .withOpacity(0.4 * _glowIntensity.value),
                            blurRadius: 60 * _glowIntensity.value,
                            spreadRadius: 20 * _glowIntensity.value,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFF9800)
                                .withOpacity(0.2 * _glowIntensity.value),
                            blurRadius: 40 * _glowIntensity.value,
                            spreadRadius: 10 * _glowIntensity.value,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Three government logos (Phase 1-3)
              if (_controller.value < 0.58)
                ..._buildGovernmentLogos(centerX, centerY, screenSize),

              // Final logo + tagline (Phase 4-5)
              if (_controller.value > 0.53) _buildFinalLogo(centerX, screenSize),

              // Language + Get Started UI (Phase 5)
              if (_controller.value > 0.76) _buildUISection(screenSize),

            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    final bgOpacity = (_controller.value * 1.5).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color.lerp(Colors.white, const Color(0xFFF5FFFE), bgOpacity)!,
            Color.lerp(Colors.white, const Color(0xFFFFF9F0), bgOpacity)!,
            Color.lerp(Colors.white, const Color(0xFFF0F9F8), bgOpacity)!,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }

  List<Widget> _buildGovernmentLogos(
      double centerX, double centerY, Size screenSize) {
    final logoSize = screenSize.width * 0.28;

    // Triangular positions
    // AP Government: top center
    final apStartX = centerX - logoSize / 2;
    final apStartY = centerY - logoSize * 1.3;
    // WDCW: bottom left
    final wdcwStartX = centerX - logoSize * 1.4;
    final wdcwStartY = centerY + logoSize * 0.2;
    // RTIH: bottom right
    final rtihStartX = centerX + logoSize * 0.4;
    final rtihStartY = centerY + logoSize * 0.2;

    // Merge target: center
    final mergeX = centerX - logoSize / 2;
    final mergeY = centerY - logoSize / 2;

    final mergeT = _mergeProgress.value;
    final currentOpacity =
        (_logosFadeIn.value * _logosFadeOut.value).clamp(0.0, 1.0);
    final scale = _logosScale.value * (1.0 - mergeT * 0.5);

    return [
      // AP Government Logo — top center
      _buildAnimatedLogo(
        'assets/logos/AP.png',
        lerpDouble(apStartX, mergeX, mergeT)!,
        lerpDouble(apStartY, mergeY, mergeT)!,
        logoSize,
        currentOpacity,
        scale,
        'Government of\nAndhra Pradesh',
      ),
      // WDCW — bottom left
      _buildAnimatedLogo(
        'assets/logos/WDCW.png',
        lerpDouble(wdcwStartX, mergeX, mergeT)!,
        lerpDouble(wdcwStartY, mergeY, mergeT)!,
        logoSize,
        currentOpacity,
        scale,
        'Dept. of Women Dev.\n& Child Welfare',
      ),
      // RTIH — bottom right
      _buildAnimatedLogo(
        'assets/logos/RTIH.png',
        lerpDouble(rtihStartX, mergeX, mergeT)!,
        lerpDouble(rtihStartY, mergeY, mergeT)!,
        logoSize,
        currentOpacity,
        scale,
        'RTIH',
      ),
    ];
  }

  Widget _buildAnimatedLogo(
    String assetPath,
    double x,
    double y,
    double size,
    double opacity,
    double scale,
    String label,
  ) {
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF009688).withOpacity(0.12),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE0F2F1),
                        child: Icon(Icons.account_balance,
                            size: size * 0.4, color: const Color(0xFF009688)),
                      );
                    },
                  ),
                ),
              ),
              if (_mergeProgress.value < 0.3) ...[
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalLogo(double centerX, Size screenSize) {
    final logoWidth = screenSize.width * 0.55;

    return Positioned(
      top: screenSize.height * 0.12,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: _finalLogoFadeIn.value,
        child: Transform.scale(
          scale: _finalLogoScale.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subtle glow behind logo
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF009688)
                          .withOpacity(0.15 * _finalLogoFadeIn.value),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: CroppedLogo(width: logoWidth),
              ),

              const SizedBox(height: 8),

              // Tagline
              Opacity(
                opacity: _taglineFadeIn.value,
                child: const Text(
                  "మీ బిడ్డ భద్రత మా బాధ్యత",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF005F66),
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUISection(Size screenSize) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _uiSlideUp,
        child: FadeTransition(
          opacity: _uiFadeIn,
          child: Container(
            padding: EdgeInsets.only(
              left: 28,
              right: 28,
              bottom: MediaQuery.of(context).padding.bottom + 30,
              top: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.85),
                  Colors.white.withOpacity(0.95),
                ],
                stops: const [0.0, 0.2, 1.0],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language selection card
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final t = AppLocalizations.of(context);
                              return Text(
                                t?.selectLanguage ?? 'Select Language',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF005F66),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          LanguageDropdown(
                            onLanguageChanged: (lang) {
                              setState(() {
                                selectedLanguage = lang;
                              });
                              String code = _languageMap[lang] ?? "en";
                              MyApp.setLocale(context, Locale(code));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Get Started button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      String code = _languageMap[selectedLanguage] ?? "en";
                      Navigator.pushReplacementNamed(
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
                            Color(0xFF008C96),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF005F66).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Builder(
                        builder: (context) {
                          final t = AppLocalizations.of(context);
                          return Text(
                            t?.getStarted ?? 'Get Started',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for particle fusion effect during the merge phase
class _ParticlePainter extends CustomPainter {
  final double progress;
  final double centerX;
  final double centerY;
  final double glowIntensity;

  _ParticlePainter({
    required this.progress,
    required this.centerX,
    required this.centerY,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for deterministic particles
    final particleCount = 30;

    for (int i = 0; i < particleCount; i++) {
      // Generate start positions in a ring around the logos
      final angle = (i / particleCount) * 2 * pi + random.nextDouble() * 0.5;
      final startRadius = 80 + random.nextDouble() * 60;
      final startX = centerX + cos(angle) * startRadius;
      final startY = centerY + sin(angle) * startRadius;

      // Particles converge to center
      final t = (progress * (1.0 + random.nextDouble() * 0.3)).clamp(0.0, 1.0);
      final currentX = lerpDouble(startX, centerX, t)!;
      final currentY = lerpDouble(startY, centerY, t)!;

      // Particle opacity — fade in then out
      final particleOpacity =
          (sin(t * pi) * glowIntensity * 0.7).clamp(0.0, 1.0);

      // Size shrinks as it approaches center
      final particleSize = (3.0 + random.nextDouble() * 3.0) * (1.0 - t * 0.6);

      // Color alternates between teal and orange
      final color = i % 3 == 0
          ? Color(0xFF009688).withOpacity(particleOpacity)
          : i % 3 == 1
              ? Color(0xFFFF9800).withOpacity(particleOpacity * 0.8)
              : Color(0xFF4DB6AC).withOpacity(particleOpacity * 0.6);

      final paint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(currentX, currentY),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
