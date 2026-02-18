import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vision_result_model.dart';

class FieldOfVisionTestScreen extends StatefulWidget {
  const FieldOfVisionTestScreen({super.key});

  @override
  State<FieldOfVisionTestScreen> createState() => _FieldOfVisionTestScreenState();
}

class _FieldOfVisionTestScreenState extends State<FieldOfVisionTestScreen> {
  bool _isPlaying = false;
  int _score = 0;
  int _totalStimuli = 10;
  int _stimuliShown = 0;
  
  // Stimulus State
  Timer? _gameTimer;
  Alignment _stimulusAlignment = Alignment.center;
  bool _showStimulus = false;
  DateTime? _stimulusShowTime;
  List<double> _reactionTimes = [];

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _stimuliShown = 0;
      _reactionTimes.clear();
    });
    _scheduleNextStimulus();
  }

  void _scheduleNextStimulus() {
    if (_stimuliShown >= _totalStimuli) {
      _finishGame();
      return;
    }

    // Random delay between 1-3 seconds
    int delay = Random().nextInt(2000) + 1000;
    _gameTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      _showRandomStimulus();
    });
  }

  void _showRandomStimulus() {
    // Pick a random alignment on the edge (Peripheral)
    // defined by x,y in -1 to 1 range.
    // We want to avoid center (-0.3 to 0.3)
    
    double x = (Random().nextDouble() * 2 - 1);
    double y = (Random().nextDouble() * 2 - 1);
    
    // Push to edge if too central
    if (x.abs() < 0.5 && y.abs() < 0.5) {
       if (Random().nextBool()) {
         x = x > 0 ? 0.8 : -0.8;
       } else {
         y = y > 0 ? 0.8 : -0.8;
       }
    }
    
    setState(() {
      _stimulusAlignment = Alignment(x, y);
      _showStimulus = true;
      _stimulusShowTime = DateTime.now();
      _stimuliShown++;
    });

    // Auto-hide after 1.5s if missed
    Timer(const Duration(milliseconds: 1500), () {
       if (_showStimulus && mounted) {
          setState(() => _showStimulus = false);
          _scheduleNextStimulus(); // Missed
       }
    });
  }

  void _onTap() {
    if (!_isPlaying) return;
    
    if (_showStimulus) {
      // Correct!
      final reactionTime = DateTime.now().difference(_stimulusShowTime!).inMilliseconds;
      _reactionTimes.add(reactionTime.toDouble());
      
      setState(() {
        _score++;
        _showStimulus = false; 
      });
      _scheduleNextStimulus();
    } else {
      // False positive? For now ignore.
    }
  }
  
  void _finishGame() {
    setState(() => _isPlaying = false);
    double avgReaction = _reactionTimes.isEmpty ? 0 : _reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Field of Vision Result'),
        content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
              Text('Dectected: $_score / $_totalStimuli'),
              Text('Avg Reaction: ${avgReaction.toStringAsFixed(0)} ms'),
              const SizedBox(height: 10),
              Text(
                 _score >= 8 ? 'Normal Field' : 'Possible Deficit',
                 style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _score >= 8 ? Colors.green : Colors.orange,
                 ),
              )
           ],
        ),
        actions: [
           TextButton(
              onPressed: () {
                 final result = FieldOfVisionResult(
                    detectedStimuli: _score,
                    totalStimuli: _totalStimuli,
                    averageReactionTimeMs: avgReaction,
                    locationDeficits: _score < 8 ? 'General' : 'None',
                 );
                 Navigator.pop(context); // Close dialog
                 Navigator.pop(context, result); // Return result
              },
              child: const Text('Finish'),
           )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: InkWell(
        onTap: _onTap, // Tap anywhere to acknowledge seeing the dot
        child: Stack(
          children: [
             // Central Focus Point
             const Center(
                child: Icon(Icons.add, color: Colors.white54, size: 40),
             ),
             const Center(
                child: Padding(
                   padding: EdgeInsets.only(top: 60),
                   child: Text("Keep eyes on the Cross.\nTap screen when you see a white dot.", 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white30)
                   ),
                ),
             ),
             
             // Stimulus
             if (_showStimulus)
                Align(
                   alignment: _stimulusAlignment,
                   child: Container(
                      width: 20, 
                      height: 20,
                      decoration: const BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         boxShadow: [BoxShadow(color: Colors.white, blurRadius: 10)],
                      ),
                   ),
                ),
                
             // Start Overlay
             if (!_isPlaying)
                Container(
                   color: Colors.black87,
                   child: Center(
                      child: ElevatedButton.icon(
                         onPressed: _startGame,
                         icon: const Icon(Icons.play_arrow),
                         label: const Text('Start Field Test'),
                         style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                         ),
                      ),
                   ),
                ),
                
             // Score HUD
             if (_isPlaying)
                Positioned(
                   top: 40,
                   right: 20,
                   child: Text(
                      '$_score / $_totalStimuli',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                   ),
                ),
          ],
        ),
      ),
    );
  }
}
