import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/modules/vision/services/distance_estimator.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:shishu_suraksha/modules/vision/widgets/vision_camera_view.dart';
import '../models/vision_result_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AcuityTestScreen extends StatefulWidget {
  const AcuityTestScreen({super.key});

  @override
  State<AcuityTestScreen> createState() => _AcuityTestScreenState();
}

class _AcuityTestScreenState extends State<AcuityTestScreen> {
  // Game State
  int _currentLevel = 0; // 0 to 5 correspond to 6/60, 6/36, 6/24, 6/18, 6/12, 6/9, 6/6
  int _score = 0;
  int _questionsAsked = 0;
  final int _maxQuestions = 5;
   String _currentDirection = 'right'; // up, down, left, right
   // Letter mode
   bool _useLetters = false;
   String _currentLetter = 'E';
   List<String> _letterChoices = [];
  
  // Logic
  final List<String> _directions = ['up', 'down', 'left', 'right'];
  final Random _random = Random();
   final List<String> _letters = ['C','D','E','F','L','O','P','T','Z'];
  
  // Voice Control
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastCommand = "";
  
  // Distance Logic
  final DistanceEstimator _distanceEstimator = DistanceEstimator();
  bool _isDistanceCorrect = false;
  double _currentDistanceCm = 0.0;
  static const double TARGET_DISTANCE_CM = 150.0; // 1.5 meters for simplified mobile test (usually 3m/6m)
  static const double TOLERANCE_CM = 30.0;
  
  // UI State
  bool _showCameraPreview = true; // Show camera initially to set distance
  bool _testStarted = false;
  bool _testCompleted = false;

  @override
  void dispose() {
    _distanceEstimator.close();
    _stopListening();
    super.dispose();
  }
  
  void _initSpeech() async {
    bool available = await _speech.initialize(
        onError: (val) => print('onError: $val'),
        onStatus: (val) => print('onStatus: $val'),
    );
    if (available) {
       _startListening();
    }
  }
  
  void _startListening() {
    _speech.listen(
      onResult: (val) {
         if (val.recognizedWords.isNotEmpty) {
            String word = val.recognizedWords.toLowerCase().trim().split(' ').last; // Get last word
            if (_directions.contains(word)) {
               setState(() => _lastCommand = word);
               _checkAnswer(word);
               // Restart listening after command? STT sometimes closes session.
               // For continuous: listen loop. BUT _checkAnswer changes state.
               // Let's rely on standard session.
            }
         }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
    setState(() => _isListening = true);
  }
  
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  bool _isProcessing = false;

  void _processImage(InputImage inputImage) async {
    if (_testCompleted || _isProcessing) return;
    
    _isProcessing = true;
    
    try {
      final distance = await _distanceEstimator.estimateDistance(inputImage);
      if (distance != null && mounted) {
        setState(() {
           _currentDistanceCm = distance;
           _isDistanceCorrect = (distance >= TARGET_DISTANCE_CM - TOLERANCE_CM && 
                                 distance <= TARGET_DISTANCE_CM + TOLERANCE_CM);
        });
      }
    } catch (e) {
      debugPrint("Error in distance estimation: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _startGame() {
    if (!_isDistanceCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please maintain correct distance (approx 1.5m)')),
      );
      return;
    }
    
    // Init Voice
    _initSpeech();
    
    setState(() {
      _testStarted = true;
      _showCameraPreview = false; // Hide camera to focus on letters
         _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_questionsAsked >= _maxQuestions) {
      _finishTest();
      return;
    }
    
    setState(() {
         if (_useLetters) {
            _currentLetter = _letters[_random.nextInt(_letters.length)];
            // generate choices including correct one
            final choices = <String>{_currentLetter};
            while (choices.length < 4) choices.add(_letters[_random.nextInt(_letters.length)]);
            _letterChoices = choices.toList()..shuffle();
         } else {
            _currentDirection = _directions[_random.nextInt(_directions.length)];
         }
      _questionsAsked++;
      _lastCommand = ""; // Reset command display
    });
  }

   void _checkAnswer(String answer) {
      if (_useLetters) {
         if (answer.toUpperCase() == _currentLetter) {
            _score++;
            if (_currentLevel < 6) _currentLevel++;
         } else {
            if (_currentLevel > 0) _currentLevel--;
         }
      } else {
         if (answer == _currentDirection) {
            _score++;
            if (_currentLevel < 6) _currentLevel++; 
         } else {
            if (_currentLevel > 0) _currentLevel--;
         }
      }
      _nextQuestion();
   }
  
  void _finishTest() {
    _stopListening();
    setState(() {
      _testCompleted = true;
    });
    // Here we would save results to Firebase
  }

  // Snellen Size Calculation
  double _getLetterSize() {
     // Base size for 6/60 at 1.5m
     // 6/6 letter height is 5 arcmin.
     // Mobile screen PPI varies, let's use logical pixels.
     // Level 0 (Big) -> Level 6 (Smallest)
     const double baseSize = 200.0;
     List<double> scales = [1.0, 0.6, 0.4, 0.3, 0.2, 0.15, 0.1];
     return baseSize * scales[min(_currentLevel, scales.length - 1)]; 
  }

  IconData _getIconForDirection(String dir) {
    // We use a rotatable E icon or similar. 
    // Actually, simpler to rotate a widget.
    return Icons.e_mobiledata; // Placeholder, standard is 'E'
  }

  double _getRotationAngle(String dir) {
    switch (dir) {
      case 'up': return -pi / 2;
      case 'down': return pi / 2;
      case 'left': return pi;
      case 'right': return 0;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Visual Acuity Test'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
           if (_isListening)
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: Icon(Icons.mic, color: Colors.red),
             )
        ],
      ),
      body: _testCompleted ? _buildResultScreen() : _buildTestEnvironment(),
    );
  }

  Widget _buildTestEnvironment() {
    if (!_testStarted) {
      return Stack(
        children: [
          // Small Camera Preview
          Positioned.fill(
            child: VisionCameraView(
              title: 'Distance Check',
              initialDirection: CameraLensDirection.front,
              onImage: _processImage,
            ),
          ),
          // Overlay
          Positioned.fill(
             child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                      Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                         ),
                         child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Text(
                                  'Distance: ${_currentDistanceCm.toStringAsFixed(0)} cm',
                                  style: TextStyle(
                                     fontSize: 24,
                                     fontWeight: FontWeight.bold,
                                     color: _isDistanceCorrect ? Colors.green : Colors.red,
                                  ),
                               ),
                               const SizedBox(height: 8),
                               const Text('Target: 150 cm (±30cm)'),
                               const SizedBox(height: 16),
                               if (_isDistanceCorrect)
                                  ElevatedButton(
                                     onPressed: _startGame,
                                     style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                     ),
                                     child: const Text('START TEST', style: TextStyle(fontSize: 18)),
                                  )
                               else
                                  const Text(
                                     'Move closer or further to start',
                                     style: TextStyle(color: Colors.grey),
                                  ),
                            ],
                         ),
                      )
                   ],
                ),
             ),
          ),
        ],
      );
    }
    
    // Testing Phase
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
            // Mode toggle
            Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  const Text('Mode:'),
                  const SizedBox(width: 8),
                  ChoiceChip(
                     label: const Text('Tumbling E'),
                     selected: !_useLetters,
                     onSelected: (v) => setState(() => _useLetters = !v),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                     label: const Text('Letters'),
                     selected: _useLetters,
                     onSelected: (v) => setState(() => _useLetters = v),
                  ),
               ],
            ),
            const SizedBox(height: 12),
         const Text(
           "Which way is the 'E' pointing?",
           style: TextStyle(fontSize: 18, color: Colors.grey),
         ),
         const SizedBox(height: 40),
         
             // Optotype (E or Letter)
             if (!_useLetters)
                Transform.rotate(
                     angle: _getRotationAngle(_currentDirection),
                     child: Text(
                         'E',
                         style: TextStyle(
                              fontSize: _getLetterSize(),
                              fontWeight: FontWeight.w900,
                              height: 1,
                              fontFamily: 'Roboto',
                         ),
                     ),
                )
             else
                Text(
                   _currentLetter,
                   style: TextStyle(
                      fontSize: _getLetterSize(),
                      fontWeight: FontWeight.w900,
                      height: 1,
                      fontFamily: 'Roboto',
                   ),
                ),
         
         const Spacer(),
         
             // Controls
             if (!_useLetters)
                GridView.count(
                     shrinkWrap: true,
                     crossAxisCount: 3,
                     padding: const EdgeInsets.all(24),
                     children: [
                         const SizedBox(),
                         _buildAnswerBtn('up', Icons.arrow_upward),
                         const SizedBox(),
                         _buildAnswerBtn('left', Icons.arrow_back),
                         const SizedBox(),
                         _buildAnswerBtn('right', Icons.arrow_forward),
                         const SizedBox(),
                         _buildAnswerBtn('down', Icons.arrow_downward),
                         const SizedBox(),
                     ],
                )
             else
                Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
                   child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: _letterChoices.map((c) => ElevatedButton(
                         onPressed: () => _checkAnswer(c),
                         child: Text(c, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      )).toList(),
                   ),
                ),
         const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAnswerBtn(String dir, IconData icon) {
     return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
           onTap: () => _checkAnswer(dir),
           borderRadius: BorderRadius.circular(12),
           child: Center(
              child: Icon(icon, size: 32, color: AppColors.primary),
           ),
        ),
     );
  }

  Widget _buildResultScreen() {
     return Center(
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                 'Test Complete!',
                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                 'Visual Acuity Score: $_score / $_maxQuestions',
                 style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                 'Recommended Level: 6/${[60, 36, 24, 18, 12, 9, 6][min(_currentLevel, 6)]}',
                 style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                 onPressed: () {
                    final result = AcuityResult(
                       leftEyeScore: "6/${[60, 36, 24, 18, 12, 9, 6][min(_currentLevel, 6)]}", // Simplified logic
                       rightEyeScore: "6/${[60, 36, 24, 18, 12, 9, 6][min(_currentLevel, 6)]}", 
                       distanceCm: 150.0,
                    );
                    Navigator.pop(context, result);
                 },
                 child: const Text('Finish Test'),
              ),
           ],
        ),
     );
  }
}
