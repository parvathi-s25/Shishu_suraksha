import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../core/data/models/child_model.dart';
import '../../../core/data/models/assessment_result_models.dart';
import 'assessment_result_screen.dart';

/// Simulated Social-Emotional Assessment Screen
class SocialEmotionalAssessmentScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const SocialEmotionalAssessmentScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<SocialEmotionalAssessmentScreen> createState() =>
      _SocialEmotionalAssessmentScreenState();
}

class _SocialEmotionalAssessmentScreenState extends ConsumerState<SocialEmotionalAssessmentScreen> {
  late PageController _pageController;
  int _currentTest = 0;

  // Analysis Results
  double _eyeContactScore = 0;
  double _socialInteractionScore = 0;
  double _emotionalRegulationScore = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _calculateFinalScores() {
    final random = Random();
    
    // Simulate scores if not set by interaction
    if (_eyeContactScore == 0) _eyeContactScore = 70 + random.nextInt(30).toDouble();
    if (_socialInteractionScore == 0) _socialInteractionScore = 65 + random.nextInt(35).toDouble();
    if (_emotionalRegulationScore == 0) _emotionalRegulationScore = 75 + random.nextInt(25).toDouble();
  }

  void _finishAssessment() {
    _calculateFinalScores();

    final result = SocialEmotionalAssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: widget.child.id,
      date: DateTime.now(),
      eyeContactScore: _eyeContactScore,
      socialInteractionScore: _socialInteractionScore,
      emotionalRegulationScore: _emotionalRegulationScore,
      totalScore: (_eyeContactScore + _socialInteractionScore + _emotionalRegulationScore) / 3,
      developmentalAgeMonths: widget.child.ageMonths,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentResultScreen(
          child: widget.child,
          socialEmotionalAssessment: result,
          overallSocialEmotionalScore: result.totalScore, // Pass to overall score
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social-Emotional Assessment')),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEyeContactTest(),
                _buildSocialInteractionTest(),
                _buildEmotionalRegulationTest(),
                _buildReviewPage(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEyeContactTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 1: Eye Contact', 'Observe and record eye-to-eye contact'),
          const SizedBox(height: 30),
          const Text(
            'Keep your face moving and see if the child follows your eyes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 50),
          const Icon(Icons.remove_red_eye, size: 100, color: Colors.blue),
          const SizedBox(height: 50),
          const Text('Rate quality of eye contact:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRatingButton('Poor', 30, Colors.red),
              _buildRatingButton('Fair', 60, Colors.orange),
              _buildRatingButton('Good', 90, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialInteractionTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 2: Social Interaction', 'How does the child interact?'),
          const SizedBox(height: 30),
          const Text(
            'Try to engage the child in a simple play or conversation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 50),
          const Icon(Icons.people, size: 100, color: Colors.teal),
          const SizedBox(height: 50),
          const Text('Rate interaction level:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRatingButton('Avoidant', 30, Colors.red, isInteraction: true),
              _buildRatingButton('Passive', 60, Colors.orange, isInteraction: true),
              _buildRatingButton('Active', 90, Colors.green, isInteraction: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalRegulationTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 3: Emotional Regulation', 'Response to emotions'),
          const SizedBox(height: 30),
          const Text(
            'Observe how the child reacts to a mirror or emotional prompts.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 50),
          const Icon(Icons.sentiment_satisfied, size: 100, color: Colors.amber),
          const SizedBox(height: 50),
          const Text('Rate emotional response:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRatingButton('Distressed', 30, Colors.red, isEmotion: true),
              _buildRatingButton('Neutral', 60, Colors.orange, isEmotion: true),
              _buildRatingButton('Responsive', 90, Colors.green, isEmotion: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton(String label, double score, Color color, {bool isInteraction = false, bool isEmotion = false}) {
    bool isSelected = false;
    if (isInteraction) {
      isSelected = _socialInteractionScore == score;
    } else if (isEmotion) {
      isSelected = _emotionalRegulationScore == score;
    } else {
      isSelected = _eyeContactScore == score;
    }

    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isInteraction) {
            _socialInteractionScore = score;
          } else if (isEmotion) {
            _emotionalRegulationScore = score;
          } else {
            _eyeContactScore = score;
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.white,
        foregroundColor: isSelected ? Colors.white : color,
        side: BorderSide(color: color),
      ),
      child: Text(label),
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
          _buildScoreRow('Eye Contact', _eyeContactScore),
          _buildScoreRow('Social Interaction', _socialInteractionScore),
          _buildScoreRow('Emotional Regulation', _emotionalRegulationScore),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Save & View Report', style: TextStyle(fontSize: 18, color: Colors.white)),
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
