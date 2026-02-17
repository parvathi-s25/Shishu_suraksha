import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shishu_suraksha/core/data/models/assessment_result_models.dart';
import 'dart:async';
import 'dart:math';
import 'package:shishu_suraksha/core/services/ai/speech_model_service.dart';
import '../../../core/data/models/child_model.dart';
import 'assessment_result_screen.dart';

/// Simulated Speech & Language Assessment Screen
class SpeechAssessmentScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const SpeechAssessmentScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<SpeechAssessmentScreen> createState() => _SpeechAssessmentScreenState();
}

class _SpeechAssessmentScreenState extends ConsumerState<SpeechAssessmentScreen> {
  late PageController _pageController;
  int _currentTest = 0;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  // Analysis Results (Simulated)
  double _clarityScore = 0;
  double _vocabularyScore = 0;
  double _sentenceScore = 0;
  double _fluencyScore = 0;
  
  // Input Controllers
  final _wordsCountController = TextEditingController();
  final _sentenceLengthController = TextEditingController();
  final SpeechModelService _speechModel = SpeechModelService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _wordsCountController.dispose();
    _sentenceLengthController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordingDuration = 0;
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordingDuration++);
        });
      } else {
        _recordingTimer?.cancel();
        _simulateAnalysis();
      }
    });
  }

  Future<void> _simulateAnalysis() async {
    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Use the service to simulate analysis
      final results = await _speechModel.analyzeAudio("dummy_path");
      
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loader

      setState(() {
        _clarityScore = (results['confidence'] as double) * 100;
        _fluencyScore = (results['fluency_score'] as double) * 10;
        
        // Randomize others based on clarity for coherence
        final random = Random();
        if (_currentTest == 1) _vocabularyScore = _clarityScore - 10 + random.nextInt(20);
        if (_currentTest == 2) _sentenceScore = _clarityScore - 5 + random.nextInt(15);
        
        // Clamp scores
        _vocabularyScore = _vocabularyScore.clamp(0, 100);
        _sentenceScore = _sentenceScore.clamp(0, 100);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Analysis Complete: ${results['word_count']} words detected')),
        );
      });
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: $e')),
      );
    }
  }

  void _calculateFinalScores() {
    // If manual input is provided, override simulated scores
    if (_wordsCountController.text.isNotEmpty) {
      int words = int.tryParse(_wordsCountController.text) ?? 0;
      // Simple logic: expected words = age * 10 (very rough approximation for simulation)
      int expected = widget.child.ageMonths * 5; 
      _vocabularyScore = (words / expected * 100).clamp(0, 100).toDouble();
    }
    
    // Fluency is average of others for now
    _fluencyScore = (_clarityScore + _sentenceScore) / 2;
  }

  void _finishAssessment() {
    _calculateFinalScores();
    
    final result = SpeechAssessmentResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: widget.child.id,
      date: DateTime.now(),
      clarityScore: _clarityScore,
      vocabularyScore: _vocabularyScore,
      sentenceScore: _sentenceScore,
      fluencyScore: _fluencyScore,
      totalScore: (_clarityScore + _vocabularyScore + _sentenceScore + _fluencyScore) / 4,
      developmentalAgeMonths: widget.child.ageMonths, // Placeholder
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentResultScreen(
          child: widget.child,
          speechAssessment: result,
          overallSpeechScore: result.totalScore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech Assessment')),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWordClarityTest(),
                _buildVocabularyTest(),
                _buildSentenceTest(),
                _buildReviewPage(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildRecordingInterface(String instruction) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(instruction, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: _toggleRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? Colors.red : Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : Colors.blue).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_isRecording)
          Text(
            'Recording... $_recordingDuration s',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        if (!_isRecording && _clarityScore > 0)
          const Text(
            'Analysis Complete ✓',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
          ),
      ],
    );
  }

  Widget _buildWordClarityTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 1: Word Clarity', 'Analyze pronunciation and articulation'),
          Expanded(child: _buildRecordingInterface('Ask the child to name specific objects.\nRecord their response for analysis.')),
        ],
      ),
    );
  }

  Widget _buildVocabularyTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader('Test 2: Vocabulary', 'Estimate vocabulary size'),
            const SizedBox(height: 20),
            const Text('Show picture cards and ask the child to name them.'),
            const SizedBox(height: 20),
             TextField(
              controller: _wordsCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of words correctly named',
                border: OutlineInputBorder(),
                suffixText: 'words',
              ),
            ),
            const SizedBox(height: 20),
            _buildRecordingInterface('Optional: Record session for AI analysis'),
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceTest() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader('Test 3: Sentence Formation', 'Analyze grammar and complexity'),
          Expanded(child: _buildRecordingInterface('Engage in conversation.\nRecord a 1-minute sample speech.')),
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
          _buildScoreRow('Clarity', _clarityScore),
          _buildScoreRow('Vocabulary', _vocabularyScore),
          _buildScoreRow('Sentences', _sentenceScore),
          _buildScoreRow('Fluency', _fluencyScore),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
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
