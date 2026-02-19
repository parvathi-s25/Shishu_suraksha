import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vision_result_model.dart';

// ────────────────────────────────────────────
// Ishihara-style dot-pattern painter
// Jittered hex-grid + analytical digit masks
// ────────────────────────────────────────────
class _IshiharaPainter extends CustomPainter {
  final String hiddenNumber;
  final Color numberDotColor;
  final Color bgDotColor;
  final double opacity;

  _IshiharaPainter({
    required this.hiddenNumber,
    required this.numberDotColor,
    required this.bgDotColor,
    this.opacity = 1.0,
  });

  bool _digitMask(String c, double x, double y) {
    bool rect(double x0, double y0, double x1, double y1) =>
        x >= x0 && x <= x1 && y >= y0 && y <= y1;
    bool arc(double cx, double cy, double r0, double r1, double a0, double a1) {
      final dx = x - cx, dy = y - cy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < r0 || dist > r1) return false;
      final a = atan2(dy, dx);
      return a >= a0 && a <= a1;
    }
    switch (c) {
      case '0': return arc(0, 0, 0.48, 0.92, -pi, pi);
      case '1': return rect(-0.14, -1.0, 0.14, 1.0) || rect(-0.5, -1.0, 0.14, -0.65);
      case '2': return arc(0, -0.35, 0.4, 0.84, -pi, 0) ||
            rect(-0.84, -0.15, 0.84, 0.25) || rect(-0.84, 0.52, 0.84, 1.0);
      case '3': return arc(0, -0.35, 0.36, 0.86, -pi * 0.88, pi * 0.14) ||
            arc(0, 0.35, 0.36, 0.86, -pi * 0.14, pi * 0.88);
      case '4': return rect(-0.74, -1.0, -0.3, 0.18) ||
            rect(-0.74, 0.02, 0.78, 0.38) || rect(0.26, -1.0, 0.74, 1.0);
      case '5': return rect(-0.74, -1.0, 0.74, -0.52) || rect(-0.74, -0.52, -0.26, 0.12) ||
            arc(0.1, 0.4, 0.36, 0.84, -pi * 0.8, pi * 0.96) ||
            rect(-0.74, -0.52, 0.74, -0.26);
      case '6': return arc(0, 0.34, 0.36, 0.88, -pi, pi) || rect(-0.88, -1.0, -0.36, 0.42);
      case '7': return rect(-0.74, -1.0, 0.74, -0.56) || rect(0.1, -0.56, 0.74, 1.0);
      case '8': return arc(0, -0.38, 0.26, 0.76, -pi, pi) ||
            arc(0, 0.38, 0.26, 0.76, -pi, pi);
      case '9': return arc(0, -0.34, 0.36, 0.88, -pi, pi) || rect(0.36, -0.34, 0.9, 1.0);
      default: return sqrt(x * x + y * y) < 0.54;
    }
  }

  bool _isInNumber(double px, double py, Offset center, double radius) {
    final count = hiddenNumber.length;
    for (int d = 0; d < count; d++) {
      final xOff = count == 1 ? 0.0 : (d - (count - 1) / 2.0) * 1.15;
      final nx = (px - center.dx) / (radius * 0.5) - xOff;
      final ny = (py - center.dy) / (radius * 0.56);
      if (_digitMask(hiddenNumber[d], nx, ny)) return true;
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(hiddenNumber.hashCode ^ 0xBEEF);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    const spacing = 13.5;
    int rowIdx = 0;
    for (double row = center.dy - radius; row <= center.dy + radius; row += spacing * 0.87) {
      final xOff = rowIdx.isOdd ? spacing / 2 : 0.0;
      for (double col = center.dx - radius + xOff; col <= center.dx + radius; col += spacing) {
        final jx = col + (rng.nextDouble() - 0.5) * spacing * 0.44;
        final jy = row + (rng.nextDouble() - 0.5) * spacing * 0.44;
        final ddx = jx - center.dx;
        final ddy = jy - center.dy;
        if (ddx * ddx + ddy * ddy > radius * radius) continue;

        final dotR = 3.8 + rng.nextDouble() * 3.6;
        final base = _isInNumber(jx, jy, center, radius) ? numberDotColor : bgDotColor;
        final lum = 0.78 + rng.nextDouble() * 0.44;
        canvas.drawCircle(
          Offset(jx, jy),
          dotR,
          Paint()
            ..color = Color.fromARGB(
              (255 * opacity).round(),
              (base.red * lum).clamp(0, 255).round(),
              (base.green * lum).clamp(0, 255).round(),
              (base.blue * lum).clamp(0, 255).round(),
            ),
        );
      }
      rowIdx++;
    }

    canvas.restore();
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = Colors.white.withOpacity(0.12 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _IshiharaPainter old) =>
      old.hiddenNumber != hiddenNumber || old.opacity != opacity;
}

// ────────────────────────────────────────────
// Color Vision Test Screen
// ────────────────────────────────────────────
class ColorVisionTestScreen extends StatefulWidget {
  const ColorVisionTestScreen({super.key});

  @override
  State<ColorVisionTestScreen> createState() => _ColorVisionTestScreenState();
}

class _ColorVisionTestScreenState extends State<ColorVisionTestScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  bool _showResults = false;
  String? _deficiencyType;

  final TextEditingController _controller = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;

  // Plate data: number, numberDotColor, bgDotColor, deficiency type it tests
  final List<Map<String, dynamic>> _plates = [
    {'number': '12', 'numColor': const Color(0xFFE65100), 'bgColor': const Color(0xFF558B2F), 'type': 'demo'},
    {'number': '8',  'numColor': const Color(0xFFD32F2F), 'bgColor': const Color(0xFF388E3C), 'type': 'rg'},
    {'number': '29', 'numColor': const Color(0xFFC62828), 'bgColor': const Color(0xFF2E7D32), 'type': 'rg'},
    {'number': '5',  'numColor': const Color(0xFF6A1B9A), 'bgColor': const Color(0xFFE65100), 'type': 'rg'},
    {'number': '3',  'numColor': const Color(0xFFFF8F00), 'bgColor': const Color(0xFFF9A825), 'type': 'by'},
    {'number': '74', 'numColor': const Color(0xFF1565C0), 'bgColor': const Color(0xFFFFB300), 'type': 'by'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _resultController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _resultAnimation = CurvedAnimation(parent: _resultController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _resultController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitAnswer() {
    final plate = _plates[_currentIndex];
    if (_controller.text.trim() == plate['number']) {
      _score++;
    }
    _controller.clear();

    if (_currentIndex < _plates.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() => _currentIndex++);
        _fadeController.forward();
      });
    } else {
      _calculateResult();
    }
  }

  void _calculateResult() {
    // Count per type
    int rgCorrect = 0, rgTotal = 0;
    int byCorrect = 0, byTotal = 0;

    for (int i = 0; i < _plates.length; i++) {
      final type = _plates[i]['type'];
      if (type == 'rg') {
        rgTotal++;
        // Re-check this plate's answer (already counted in _score, but we need per-type)
      } else if (type == 'by') {
        byTotal++;
      }
    }

    // Simple classification
    if (_score >= _plates.length - 1) {
      _deficiencyType = 'Normal';
    } else if (_score <= 2) {
      _deficiencyType = 'Red-Green Deficiency';
    } else {
      _deficiencyType = 'Possible Color Weakness';
    }

    setState(() => _showResults = true);
    _resultController.forward();
  }

  void _submitResult() {
    final result = ColorVisionResult(
      score: _score,
      totalPlates: _plates.length,
      type: _deficiencyType ?? 'Unknown',
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Color Vision Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _showResults ? _buildResultsScreen() : _buildTestScreen(),
    );
  }

  // ──────── Test Screen ────────
  Widget _buildTestScreen() {
    final plate = _plates[_currentIndex];
    final progress = (_currentIndex + 1) / _plates.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Progress bar
            Row(
              children: [
                Text(
                  'Plate ${_currentIndex + 1}/${_plates.length}',
                  style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.black.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation(Colors.cyan),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ishihara plate
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, _) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: 0.9 + 0.1 * _fadeAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (plate['numColor'] as Color).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: _IshiharaPainter(
                            hiddenNumber: plate['number'] as String,
                            numberDotColor: plate['numColor'] as Color,
                            bgDotColor: plate['bgColor'] as Color,
                            opacity: _fadeAnimation.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Instruction
            Text(
              plate['type'] == 'demo'
                  ? 'Demo Plate — What number do you see?'
                  : 'What number do you see?',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (plate['type'] == 'demo')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Most people see "${plate['number']}"',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),

            const SizedBox(height: 20),

            // Input field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: '?',
                  hintStyle: TextStyle(color: Colors.black26, fontSize: 28),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: (_) => _submitAnswer(),
              ),
            ),

            const SizedBox(height: 24),

            // Next / Finish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: Text(
                  _currentIndex == _plates.length - 1 ? 'FINISH' : 'NEXT PLATE',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              'Tap "Can\'t see" if the number is not visible',
              style: TextStyle(color: Colors.black38, fontSize: 12),
            ),
            TextButton(
              onPressed: () {
                _controller.clear();
                _submitAnswer();
              },
              child: Text(
                "Can't see a number",
                style: TextStyle(color: Colors.orangeAccent.withOpacity(0.7), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────── Results Screen ────────
  Widget _buildResultsScreen() {
    final isNormal = _deficiencyType == 'Normal';
    final statusColor = isNormal ? Colors.greenAccent : Colors.orangeAccent;
    final scorePercent = (_score / _plates.length * 100);

    return SafeArea(
      child: AnimatedBuilder(
        animation: _resultAnimation,
        builder: (context, _) {
          final t = _resultAnimation.value.clamp(0.0, 1.0);
          return Opacity(
            opacity: t,
            child: Transform.scale(
              scale: 0.85 + 0.15 * t,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Score ring
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: _score / _plates.length,
                              strokeWidth: 10,
                              backgroundColor: Colors.black.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation(statusColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_score/${_plates.length}',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${scorePercent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNormal ? Icons.check_circle_rounded : Icons.warning_rounded,
                            color: statusColor,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _deficiencyType ?? 'Unknown',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Detail cards
                    _buildDetailCard('Plates Correct', '$_score / ${_plates.length}',
                        statusColor, Icons.grid_view_rounded),
                    const SizedBox(height: 12),
                    _buildDetailCard('Classification', _deficiencyType ?? '-',
                        statusColor, Icons.palette),
                    const SizedBox(height: 12),
                    _buildDetailCard('Accuracy', '${scorePercent.toStringAsFixed(0)}%',
                        scorePercent >= 80 ? Colors.greenAccent : Colors.orangeAccent,
                        Icons.analytics),

                    const SizedBox(height: 20),

                    // Recommendation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.black38, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isNormal
                                  ? 'Color vision appears normal. Regular screening recommended.'
                                  : 'A possible color deficiency was detected. Consult an ophthalmologist for confirmation.',
                              style: TextStyle(color: Colors.black87, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Submit Result',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: TextStyle(color: Colors.black54, fontSize: 14)),
          ),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
