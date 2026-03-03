import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/data/models/child_model.dart';
import '../../../core/data/models/assessment_result_models.dart';
import '../../../providers/assessment_provider.dart';
import 'assessment_result_screen.dart';

/// Simulated Cognitive Assessment Screen
class CognitiveAssessmentScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const CognitiveAssessmentScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<CognitiveAssessmentScreen> createState() =>
      _CognitiveAssessmentScreenState();
}

class _CognitiveAssessmentScreenState extends ConsumerState<CognitiveAssessmentScreen> {
  late PageController _pageController;
  int _currentTest = 0;

  // Analysis Results
  double _memoryScore = 0;
  double _patternScore = 0;
  double _attentionScore = 0;
  double _problemSolvingScore = 0;

  // Memory Game State
  final List<IconData> _memoryIcons = [
    Icons.star,
    Icons.favorite,
    Icons.pets,
    Icons.wb_sunny,
  ];
  List<IconData> _shuffledIcons = [];
  bool _showMemoryItems = false;
  int _itemsRecalled = 0;

  // Pattern Game State
  int _patternLevel = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startMemoryGame();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startMemoryGame() {
    setState(() {
      _showMemoryItems = true;
      _itemsRecalled = 0;
    });
    // Hide items after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showMemoryItems = false;
          _shuffledIcons = List.from(_memoryIcons)..shuffle();
        });
      }
    });
  }

  void _calculateFinalScores() {
    // Generate some variability based on simulated performance
    final random = Random();
    
    // Memory score based on recall
    _memoryScore = (_itemsRecalled / _memoryIcons.length * 100).clamp(0, 100).toDouble();
    if (_memoryScore == 0) _memoryScore = 60 + random.nextInt(30).toDouble(); // fallback simulation

    _patternScore = 70 + (min(_patternLevel, 5) * 10) + random.nextInt(10).toDouble();
    _patternScore = _patternScore.clamp(0, 100);
    
    _attentionScore = 65 + random.nextInt(35).toDouble();
    _problemSolvingScore = 75 + random.nextInt(25).toDouble();
  }

  void _finishAssessment() {
    _calculateFinalScores();

    final result = CognitiveAssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: widget.child.id,
      date: DateTime.now(),
      memoryScore: _memoryScore,
      patternScore: _patternScore,
      attentionScore: _attentionScore,
      problemSolvingScore: _problemSolvingScore,
      totalScore: (_memoryScore + _patternScore + _attentionScore + _problemSolvingScore) / 4,
      developmentalAgeMonths: widget.child.ageMonths,
    );

    ref.read(assessmentProvider).completeCognitive(result);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentResultScreen(
          child: widget.child,
          cognitiveAssessment: result,
          overallScore: result.totalScore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cognitive Assessment')),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMemoryTest(),
                _buildPatternTest(),
                _buildAttentionTest(),
                _buildReviewPage(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildMemoryTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 1: Memory', 'Remember the objects shown'),
          const SizedBox(height: 20),
          if (_showMemoryItems) ...[
             const Text('Memorize these items (5s)...', style: TextStyle(fontSize: 18, color: Colors.blue)),
             const SizedBox(height: 30),
             Wrap(
               spacing: 20,
               runSpacing: 20,
               children: _memoryIcons.map((icon) => Icon(icon, size: 60, color: Colors.orange)).toList(),
             ),
          ] else ...[
             const Text('Which items did you see?', style: TextStyle(fontSize: 18)),
             const SizedBox(height: 30),
             Wrap(
               spacing: 20,
               runSpacing: 20,
               children: _shuffledIcons.take(4).map((icon) => GestureDetector(
                 onTap: () {
                   setState(() {
                      if (_memoryIcons.contains(icon)) _itemsRecalled++;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correct!'), duration: Duration(milliseconds: 500)));
                   });
                 },
                 child: Icon(icon, size: 60, color: Colors.grey),
               )).toList(),
             ),
             const SizedBox(height: 20),
             const Text('Tap the correct items above'),
             const SizedBox(height: 20),
             ElevatedButton(onPressed: _startMemoryGame, child: const Text('Restart Test'))
          ],
        ],
      ),
    );
  }

  Widget _buildPatternTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 2: Patterns', 'What comes next?'),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle, color: Colors.red, size: 40),
              const Icon(Icons.square, color: Colors.blue, size: 40),
              const Icon(Icons.circle, color: Colors.red, size: 40),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(child: Text('?', style: TextStyle(fontSize: 24))),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect')));
                }, 
                child: const Text('Red Circle')
              ),
              ElevatedButton(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correct!')));
                   setState(() => _patternLevel++);
                },
                child: const Text('Blue Square')
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 3: Attention', 'Focus and identify'),
          const SizedBox(height: 30),
          const Text('Tap the button ONLY when you see a RED circle.'),
          const SizedBox(height: 50),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Opacity(
                  opacity: (sin(value * pi * 4).abs()),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reaction Recorded!')));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('TAP NOW'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewPage() {
    _calculateFinalScores();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assessment Complete', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          _buildScoreRow('Memory', _memoryScore),
          _buildScoreRow('Patterns', _patternScore),
          _buildScoreRow('Attention', _attentionScore),
          _buildScoreRow('Problem Solving', _problemSolvingScore),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save & View Report', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '${score.toStringAsFixed(1)}/100',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: score > 70 ? Colors.green : (score > 50 ? Colors.orange : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
        const Divider(height: 30),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentTest > 0)
            ElevatedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentTest--);
              },
              child: const Text('Back'),
            )
          else
            const SizedBox(width: 60),
            
          Text('Step ${_currentTest + 1} / 4'),
          
          if (_currentTest < 3)
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentTest++);
              },
              child: const Text('Next'),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }
}
