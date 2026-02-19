import 'dart:ui';
import 'package:flutter/material.dart';
import 'models/vision_result_model.dart';

class RefractionScreen extends StatefulWidget {
  const RefractionScreen({super.key});

  @override
  State<RefractionScreen> createState() => _RefractionScreenState();
}

class _RefractionScreenState extends State<RefractionScreen>
    with TickerProviderStateMixin {
  // Diopter values for each eye (-10 to +10 range, 0 = normal)
  double _dioptersOD = 0.0; // Right eye
  double _dioptersOS = 0.0; // Left eye
  bool _testingRightEye = true;
  bool _showResults = false;

  late AnimationController _resultController;
  late Animation<double> _resultAnimation;

  // Snellen letters for blur demo
  final List<Map<String, dynamic>> _letterRows = [
    {'letters': 'E', 'size': 64.0, 'acuity': '20/200'},
    {'letters': 'FP', 'size': 48.0, 'acuity': '20/100'},
    {'letters': 'TOZ', 'size': 36.0, 'acuity': '20/70'},
    {'letters': 'LPED', 'size': 28.0, 'acuity': '20/50'},
    {'letters': 'PECFD', 'size': 22.0, 'acuity': '20/40'},
    {'letters': 'EDFCZP', 'size': 18.0, 'acuity': '20/30'},
    {'letters': 'FELOPZD', 'size': 14.0, 'acuity': '20/20'},
  ];

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _resultAnimation = CurvedAnimation(parent: _resultController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  double get _currentDiopter => _testingRightEye ? _dioptersOD : _dioptersOS;

  String _getRiskLabel() {
    final maxDiopter = [_dioptersOD.abs(), _dioptersOS.abs()].reduce((a, b) => a > b ? a : b);
    if (maxDiopter > 6) return 'High Myopia Risk';
    if (maxDiopter > 3) return 'Moderate Myopia Risk';
    if (maxDiopter > 1) return 'Mild Refractive Error';
    return 'Low Risk';
  }

  Color _getRiskColor() {
    final label = _getRiskLabel();
    if (label.contains('High')) return Colors.redAccent;
    if (label.contains('Moderate')) return Colors.orangeAccent;
    if (label.contains('Mild')) return Colors.amber;
    return Colors.greenAccent;
  }

  void _finishTest() {
    setState(() => _showResults = true);
    _resultController.forward();
  }

  void _submitResult() {
    final result = RefractionResult(
      estimatedSphereOD: -_dioptersOD,
      estimatedSphereOS: -_dioptersOS,
      riskLabel: _getRiskLabel(),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Refraction Risk'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _showResults ? _buildResultsScreen() : _buildTestScreen(),
    );
  }

  Widget _buildTestScreen() {
    final blurSigma = _currentDiopter.abs() * 1.5;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Eye selector
            Row(
              children: [
                Expanded(child: _buildEyeTab('Right Eye (OD)', true)),
                const SizedBox(width: 12),
                Expanded(child: _buildEyeTab('Left Eye (OS)', false)),
              ],
            ),

            const SizedBox(height: 20),

            // Instruction
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.cyan, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Increase blur until the smallest readable line matches the child\'s sight. This estimates refractive error.',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Blurred Snellen chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Column(
                  children: _letterRows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            row['letters'] as String,
                            style: TextStyle(
                              fontSize: row['size'] as double,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              letterSpacing: 6,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Diopter slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _testingRightEye ? 'Right Eye Blur' : 'Left Eye Blur',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRiskColor().withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_currentDiopter.toStringAsFixed(1)} D',
                          style: TextStyle(
                            color: _getRiskColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getRiskColor(),
                      inactiveTrackColor: Colors.black.withOpacity(0.05),
                      thumbColor: _getRiskColor(),
                      overlayColor: _getRiskColor().withOpacity(0.12),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _currentDiopter,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      onChanged: (v) {
                        setState(() {
                          if (_testingRightEye) {
                            _dioptersOD = v;
                          } else {
                            _dioptersOS = v;
                          }
                        });
                      },
                    ),
                  ),
                  // Risk zone indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Normal', style: TextStyle(color: Colors.green.withOpacity(0.6), fontSize: 10)),
                      Text('Mild', style: TextStyle(color: Colors.amber.shade700.withOpacity(0.6), fontSize: 10)),
                      Text('Moderate', style: TextStyle(color: Colors.orange.withOpacity(0.6), fontSize: 10)),
                      Text('High', style: TextStyle(color: Colors.red.withOpacity(0.6), fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Diopter gauges side-by-side
            Row(
              children: [
                _buildDiopterGauge('OD (Right)', _dioptersOD),
                const SizedBox(width: 12),
                _buildDiopterGauge('OS (Left)', _dioptersOS),
              ],
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _finishTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getRiskColor(),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Text(
                  'FINISH TEST',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeTab(String label, bool isRight) {
    final isActive = _testingRightEye == isRight;
    return GestureDetector(
      onTap: () => setState(() => _testingRightEye = isRight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.cyan.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.cyan.withOpacity(0.5) : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            if (isActive) BoxShadow(color: Colors.cyan.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.cyan : Colors.black45,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDiopterGauge(String label, double value) {
    final norm = (value / 10.0).clamp(0.0, 1.0);
    final color = Color.lerp(Colors.greenAccent, Colors.redAccent, norm)!;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.black38, fontSize: 11)),
            const SizedBox(height: 6),
            Text(
              '${value.toStringAsFixed(1)} D',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: norm,
                backgroundColor: Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────── Results ────────
  Widget _buildResultsScreen() {
    final riskColor = _getRiskColor();
    final riskLabel = _getRiskLabel();
    final isLow = riskLabel.contains('Low');
    final maxD = [_dioptersOD.abs(), _dioptersOS.abs()].reduce((a, b) => a > b ? a : b);
    final score = ((10.0 - maxD) / 10.0 * 100).clamp(0.0, 100.0);

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
                              value: score / 100,
                              strokeWidth: 10,
                              backgroundColor: Colors.black.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation(riskColor),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                score.toStringAsFixed(0),
                                style: TextStyle(color: riskColor, fontSize: 42, fontWeight: FontWeight.bold),
                              ),
                              Text('Score', style: TextStyle(color: Colors.black45, fontSize: 14)),
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
                        color: riskColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: riskColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isLow ? Icons.check_circle_rounded : Icons.warning_rounded, color: riskColor, size: 22),
                          const SizedBox(width: 8),
                          Text(riskLabel, style: TextStyle(color: riskColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildResultDetailCard('Right Eye (OD)', '${_dioptersOD.toStringAsFixed(1)} D', riskColor, Icons.visibility),
                    const SizedBox(height: 12),
                    _buildResultDetailCard('Left Eye (OS)', '${_dioptersOS.toStringAsFixed(1)} D', riskColor, Icons.visibility),
                    const SizedBox(height: 12),
                    _buildResultDetailCard('Difference', '${(_dioptersOD - _dioptersOS).abs().toStringAsFixed(1)} D',
                        (_dioptersOD - _dioptersOS).abs() > 2 ? Colors.orangeAccent : Colors.greenAccent,
                        Icons.compare_arrows),

                    const SizedBox(height: 20),

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
                              isLow
                                  ? 'Refractive status appears normal. Regular screening recommended.'
                                  : 'Possible refractive error detected. Professional eye examination recommended.',
                              style: TextStyle(color: Colors.black87, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: riskColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: const Text('Submit Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildResultDetailCard(String title, String value, Color color, IconData icon) {
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
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: TextStyle(color: Colors.black54, fontSize: 14))),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
