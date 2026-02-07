import 'package:flutter/material.dart';
import '../splash/splash_screen.dart';

class OpeningAnimationScreen extends StatefulWidget {
  const OpeningAnimationScreen({super.key});

  @override
  State<OpeningAnimationScreen> createState() => _OpeningAnimationScreenState();
}

class _OpeningAnimationScreenState extends State<OpeningAnimationScreen>
    with TickerProviderStateMixin {
  // Single animation controller for entire 3-second sequence
  late AnimationController _mainController;

  // Position animations for each logo with CURVED PATHS
  late Animation<Offset> _apLogoPosition;
  late Animation<Offset> _wdcwLogoPosition;
  late Animation<Offset> _rtihLogoPosition;

  // Scale animations to shrink logos during merge
  late Animation<double> _logoScale;

  // Glow animation for blending effect
  late Animation<double> _glowIntensity;

  // White flash at center
  late Animation<double> _whiteFlash;

  // Fade out for transition
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Main controller: exactly 3 seconds
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Phase 1: 0.0 - 0.27 (0-800ms) = Hold
    // Phase 2: 0.27 - 0.87 (800-2600ms) = Merge animation (1800ms)
    // Phase 3: 0.87 - 1.0 (2600-3000ms) = Fade out (400ms)

    // CURVED PATH ANIMATIONS (no overlap)
    // AP logo: moves along arc from top to center
    _apLogoPosition = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: const Offset(0, -0.3),
        ),
        weight: 27, // Hold phase
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 60, // Merge phase
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0),
        ),
        weight: 13, // Fade phase
      ),
    ]).animate(_mainController);

    // WDCW logo: moves along curved arc from bottom-left to center
    _wdcwLogoPosition = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.28, 0.4),
          end: const Offset(-0.28, 0.4),
        ),
        weight: 27,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-0.28, 0.4),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0),
        ),
        weight: 13,
      ),
    ]).animate(_mainController);

    // RTIH logo: moves along curved arc from bottom-right to center
    _rtihLogoPosition = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.28, 0.4),
          end: const Offset(0.28, 0.4),
        ),
        weight: 27,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.28, 0.4),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, 0),
        ),
        weight: 13,
      ),
    ]).animate(_mainController);

    // Scale: shrink logos as they merge (prevents overlap)
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 27,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.0),
        weight: 13,
      ),
    ]).animate(_mainController);

    // Glow intensity: increases during merge for blending effect
    _glowIntensity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 27,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 30.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 30.0, end: 60.0),
        weight: 13,
      ),
    ]).animate(_mainController);

    // White flash at center during merge
    _whiteFlash = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 27,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.5),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 13,
      ),
    ]).animate(_mainController);

    // Fade out entire screen for transition
    _fadeOut = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 87,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 13,
      ),
    ]).animate(_mainController);

    // Start animation after a short delay to allow image loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheImages();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _mainController.forward();
          _startAnimation();
        }
      });
    });
  }

  void _precacheImages() {
    precacheImage(const AssetImage('assets/logos/AP.png'), context);
    precacheImage(const AssetImage('assets/logos/WDCW.png'), context);
    precacheImage(const AssetImage('assets/logos/RTIH.png'), context);
  }

  void _startAnimation() async {
    // Moved logic to initState post-frame callback
    
    // Navigate to splash screen after 3 seconds + delay
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoSize = screenSize.width * 0.22; // Smaller to prevent overlap

    return Scaffold(
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background gradient
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFBF5),
                      Color(0xFFFFF8F0),
                      Color(0xFFFFF5EB),
                    ],
                  ),
                ),
              ),

              // Glassmorphic overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),

              // White flash at center during merge
              if (_whiteFlash.value > 0.0)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(_whiteFlash.value * 0.9),
                            Colors.white.withOpacity(_whiteFlash.value * 0.5),
                            Colors.white.withOpacity(0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

              // Three logos with NO OVERLAP
              Opacity(
                opacity: _fadeOut.value,
                child: Center(
                  child: SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.6,
                    child: Stack(
                      children: [
                        // AP Logo (Top Center)
                        _buildLogo(
                          assetPath: 'assets/logos/AP.png',
                          position: _apLogoPosition.value,
                          scale: _logoScale.value,
                          glow: _glowIntensity.value,
                          logoSize: logoSize,
                        ),

                        // WDCW Logo (Bottom Left)
                        _buildLogo(
                          assetPath: 'assets/logos/WDCW.png',
                          position: _wdcwLogoPosition.value,
                          scale: _logoScale.value,
                          glow: _glowIntensity.value,
                          logoSize: logoSize,
                        ),

                        // RTIH Logo (Bottom Right)
                        _buildLogo(
                          assetPath: 'assets/logos/RTIH.png',
                          position: _rtihLogoPosition.value,
                          scale: _logoScale.value,
                          glow: _glowIntensity.value,
                          logoSize: logoSize,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo({
    required String assetPath,
    required Offset position,
    required double scale,
    required double glow,
    required double logoSize,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(
          position.dx * MediaQuery.of(context).size.width * 0.35,
          position.dy * MediaQuery.of(context).size.height * 0.35,
        ),
        child: Transform.scale(
          scale: scale.clamp(0.0, 1.0),
          child: Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: glow > 0
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD8C8).withOpacity(0.15),
                        blurRadius: glow,
                        spreadRadius: glow * 0.3,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.image,
                      size: logoSize * 0.4,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
