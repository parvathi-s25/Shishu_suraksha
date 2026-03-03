import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/child_model.dart';
import '../../../core/data/models/assessment_models.dart' as motor_models;
import '../../../core/models/assessment_models.dart';
import '../../../core/data/services/motor_skills_assessment_service.dart';
import '../../../app/theme/colors.dart';
import '../../../providers/assessment_provider.dart';
import 'assessment_result_screen.dart';

/// Motor Skills Assessment Screen - Record motor test results
/// 
/// Guides Anganwadi worker through motor assessment tests and records scores:
/// - Jump test (height, arm swing, landing stability)
/// - Balance test (duration, wobble count)
/// - Walk test (gait symmetry, coordination)
/// - Throw/catch test (coordination, accuracy)
class MotorSkillsAssessmentScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const MotorSkillsAssessmentScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<MotorSkillsAssessmentScreen> createState() =>
      _MotorSkillsAssessmentScreenState();
}

class _MotorSkillsAssessmentScreenState
    extends ConsumerState<MotorSkillsAssessmentScreen> {
  late PageController _pageController;
  int _currentTest = 0;

  // Test data controllers
  late TextEditingController _jumpHeightController;
  late TextEditingController _armSwingController;
  late TextEditingController _landingStabilityController;
  late TextEditingController _balanceDurationController;
  late TextEditingController _wobbleCountController;
  late TextEditingController _gaitSymmetryController;
  late TextEditingController _coordinationController;
  late TextEditingController _successfulCatchesController;

  // Store final scores
  double? _jumpScore;
  double? _balanceScore;
  double? _walkScore;
  double? _throwCatchScore;
  double? _overallScore;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _jumpHeightController = TextEditingController();
    _armSwingController = TextEditingController();
    _landingStabilityController = TextEditingController();
    _balanceDurationController = TextEditingController();
    _wobbleCountController = TextEditingController();
    _gaitSymmetryController = TextEditingController();
    _coordinationController = TextEditingController();
    _successfulCatchesController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _jumpHeightController.dispose();
    _armSwingController.dispose();
    _landingStabilityController.dispose();
    _balanceDurationController.dispose();
    _wobbleCountController.dispose();
    _gaitSymmetryController.dispose();
    _coordinationController.dispose();
    _successfulCatchesController.dispose();
    super.dispose();
  }

  void _calculateMotorScores() {
    final service = MotorSkillsAssessmentService();

    // Parse jump test data
    final jumpHeight = double.tryParse(_jumpHeightController.text) ?? 0;
    final armSwing = double.tryParse(_armSwingController.text) ?? 0;
    final landing = double.tryParse(_landingStabilityController.text) ?? 0;

    _jumpScore = service.analyzeJumpTest(
      jumpHeight: jumpHeight,
      armSwingQuality: armSwing,
      landingStability: landing,
      ageMonths: widget.child.ageMonths,
    );

    // Parse balance test data
    final balanceDuration = double.tryParse(_balanceDurationController.text) ?? 0;
    final wobbleCount = int.tryParse(_wobbleCountController.text) ?? 0;

    _balanceScore = service.analyzeBalanceTest(
      durationSeconds: balanceDuration,
      wobbleCount: wobbleCount,
      ageMonths: widget.child.ageMonths,
    );

    // Parse walk test data
    final gaitSymmetry = double.tryParse(_gaitSymmetryController.text) ?? 0;
    final coordination = double.tryParse(_coordinationController.text) ?? 0;

    _walkScore = service.analyzeWalkTest(
      gaitSymmetry: gaitSymmetry,
      stepCoordination: coordination,
      ageMonths: widget.child.ageMonths,
    );

    // Parse throw/catch data
    final successfulCatches = int.tryParse(_successfulCatchesController.text) ?? 0;
    _throwCatchScore = service.analyzeThrowCatchTest(
      successfulCatches: successfulCatches,
      totalAttempts: 10,
      ageMonths: widget.child.ageMonths,
    );

    // Calculate overall motor score
    _overallScore = service.calculateOverallMotorScore(
      jumpScore: _jumpScore!,
      balanceScore: _balanceScore!,
      walkScore: _walkScore!,
      throwCatchScore: _throwCatchScore!,
    );
  }

  void _saveAssessmentAndContinue() {
    _calculateMotorScores();

    // Create motor assessment result for provider
    final motorResult = PoseMotorResult(
      balanceScore: _balanceScore!,
      symmetryScore: _walkScore!,
      walkSymmetryScore: _walkScore!,
      overallMotorScore: _overallScore!,
      timestamp: DateTime.now(),
    );

    // Save to provider
    ref.read(assessmentProvider).completeMotor(motorResult);

    // Navigate to result screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentResultScreen(
          child: widget.child,
          motorAssessment: motor_models.MotorSkillsAssessment(
             jumpHeightCm: double.tryParse(_jumpHeightController.text) ?? 0,
             jumpScore: _jumpScore!,
             armSwingQuality: double.tryParse(_armSwingController.text) ?? 0,
             landingStability: double.tryParse(_landingStabilityController.text) ?? 0,
             balanceStabilityScore: _balanceScore!,
             balanceDurationSeconds: double.tryParse(_balanceDurationController.text) ?? 0,
             wobbleCount: int.tryParse(_wobbleCountController.text) ?? 0,
             gaitSymmetryScore: _walkScore!,
             stepCoordinationScore: double.tryParse(_coordinationController.text) ?? 0,
             throwCatchScore: _throwCatchScore!,
             developmentalAgeMonths: MotorSkillsAssessmentService().calculateDevelopmentalAge(_overallScore!),
             recordedAt: DateTime.now(),
          ),
          overallScore: _overallScore!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Skills Assessment'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swipe
        children: [
          _buildJumpTestPage(),
          _buildBalanceTestPage(),
          _buildWalkTestPage(),
          _buildThrowCatchTestPage(),
          _buildReviewPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildJumpTestPage() {
    final ageMonths = widget.child.ageMonths;
    String expectedHeight = 'Not applicable';

    if (ageMonths >= 18 && ageMonths < 24) expectedHeight = '15-20 cm';
    if (ageMonths >= 24 && ageMonths < 36) expectedHeight = '20-30 cm';
    if (ageMonths >= 36 && ageMonths < 48) expectedHeight = '30-40 cm';
    if (ageMonths >= 48) expectedHeight = '40-50 cm';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestHeader(
            number: 1,
            title: 'Jump Test',
            description: 'Measures jumping ability and coordination',
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Age-Appropriate Expectation',
            content: expectedHeight,
          ),
          const SizedBox(height: 16),
          _buildInstructionsCard([
            'Stand behind the child',
            'Encourage them to jump as high as possible',
            'Use a measuring tape or mark on wall',
            'Record the height in centimeters',
            'Repeat 3 times and record best attempt',
          ]),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _jumpHeightController,
            label: 'Jump Height (cm)',
            hint: 'e.g., 25',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _armSwingController,
            label: 'Arm Swing Quality (0-100)',
            hint: 'Rate: 0=Poor, 50=Medium, 100=Excellent',
            icon: Icons.pan_tool,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _landingStabilityController,
            label: 'Landing Stability (0-100)',
            hint: 'Rate: 0=Unstable, 50=Moderate, 100=Very Stable',
            icon: Icons.foundation,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _validateAndMoveNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Next Test →'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTestPage() {
    final ageMonths = widget.child.ageMonths;
    String expectedDuration = 'Not applicable';

    if (ageMonths >= 18 && ageMonths < 24) expectedDuration = '5-10 seconds';
    if (ageMonths >= 24 && ageMonths < 36) expectedDuration = '10-20 seconds';
    if (ageMonths >= 36 && ageMonths < 48) expectedDuration = '20-60 seconds';
    if (ageMonths >= 48) expectedDuration = '60-120 seconds';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestHeader(
            number: 2,
            title: 'Balance Test',
            description: 'Single-leg standing duration and stability',
          ),
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Age-Appropriate Expectation',
            content: expectedDuration,
          ),
          const SizedBox(height: 16),
          _buildInstructionsCard([
            'Ask child to stand on one leg',
            'Child can use their arms for balance',
            'Start timer when child begins',
            'Count how many times they lose balance',
            'Stop when they cannot continue',
          ]),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _balanceDurationController,
            label: 'Balance Duration (seconds)',
            hint: 'e.g., 45',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _wobbleCountController,
            label: 'Wobble Count',
            hint: 'Number of times they lose balance',
            icon: Icons.swipe,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('← Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _validateAndMoveNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Next Test →'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalkTestPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestHeader(
            number: 3,
            title: 'Walk Test',
            description: 'Gait coordination and symmetry',
          ),
          const SizedBox(height: 20),
          _buildInstructionsCard([
            'Draw or mark a straight line on the ground',
            'Ask child to walk along the line',
            'Observe left-right movement',
            'Note if steps are even and coordinated',
            'Record observations about gait',
          ]),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _gaitSymmetryController,
            label: 'Gait Symmetry (0-100)',
            hint: 'Rate: 0=Very asymmetric, 100=Perfectly symmetric',
            icon: Icons.compare_arrows,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _coordinationController,
            label: 'Step Coordination (0-100)',
            hint: 'Rate: 0=Poor, 50=Moderate, 100=Excellent',
            icon: Icons.anchor,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('← Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _validateAndMoveNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Next Test →'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThrowCatchTestPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestHeader(
            number: 4,
            title: 'Throw & Catch Test',
            description: 'Eye-hand coordination',
          ),
          const SizedBox(height: 20),
          _buildInstructionsCard([
            'Use a soft ball or cloth ball',
            'Gently throw to child at chest level',
            'Child attempts to catch it',
            'Repeat 10 times',
            'Count successful catches',
          ]),
          const SizedBox(height: 24),
          _buildInputField(
            controller: _successfulCatchesController,
            label: 'Successful Catches (out of 10)',
            hint: 'e.g., 7',
            icon: Icons.catching_pokemon,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('← Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _validateAndMoveNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Review →'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    _calculateMotorScores();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assessment Summary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _buildScoreCard(
            'Jump Test',
            '${_jumpScore?.toStringAsFixed(1) ?? 'N/A'}/100',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildScoreCard(
            'Balance Test',
            '${_balanceScore?.toStringAsFixed(1) ?? 'N/A'}/100',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildScoreCard(
            'Walk Test',
            '${_walkScore?.toStringAsFixed(1) ?? 'N/A'}/100',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildScoreCard(
            'Throw & Catch Test',
            '${_throwCatchScore?.toStringAsFixed(1) ?? 'N/A'}/100',
            Colors.purple,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Motor Score',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_overallScore?.toStringAsFixed(1) ?? 'N/A'}/100',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getRiskLevel(_overallScore ?? 0),
                  style: TextStyle(
                    color: _getRiskColor(_overallScore ?? 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveAssessmentAndContinue,
              icon: const Icon(Icons.check_circle),
              label: const Text('Save & Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestHeader({
    required int number,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(List<String> instructions) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...instructions.map((instruction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        instruction,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildScoreCard(String title, String score, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                score,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRiskLevel(double score) {
    if (score >= 75) return '✓ Good Development';
    if (score >= 50) return '⚠️ Needs Practice';
    return '🔴 Needs Intervention';
  }

  Color _getRiskColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  void _validateAndMoveNext() {
    if (_currentTest == 0) {
      if (_jumpHeightController.text.isEmpty ||
          _armSwingController.text.isEmpty ||
          _landingStabilityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }
    }

    if (_pageController.page!.toInt() < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentTest++);
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Text(
        'Test ${_currentTest + 1} of 5',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
