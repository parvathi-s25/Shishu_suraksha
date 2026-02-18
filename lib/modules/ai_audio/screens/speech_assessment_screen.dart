
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechAssessmentScreen extends StatefulWidget {
  const SpeechAssessmentScreen({Key? key}) : super(key: key);

  @override
  State<SpeechAssessmentScreen> createState() => _SpeechAssessmentScreenState();
}

class _SpeechAssessmentScreenState extends State<SpeechAssessmentScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = "";
  double _confidence = 0.0;
  
  // Timer for WPM
  Timer? _timer;
  int _durationSeconds = 0;
  
  // Analysis
  double _wpm = 0.0;
  String _fluencyStatus = "Ready";

  // Test Material
  final String _targetPassage = 
      "The sun rises in the east and sets in the west. "
      "Birds fly in the sky and fish swim in the water. "
      "I like to play with my friends in the park.";

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
             print('onStatus: $val');
             if (val == 'done' || val == 'notListening') {
                 if (_isListening) _stopListening();
             }
        },
        onError: (val) => print('onError: $val'),
      );
      
      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = "";
          _confidence = 0.0;
          _durationSeconds = 0;
          _fluencyStatus = "Listening...";
        });
        
        _startTimer();
        
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
              if (result.hasConfidenceRating && result.confidence > 0) {
                _confidence = result.confidence;
              }
            });
          },
          localeId: "en_IN", // Indian English
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _timer?.cancel();
    _speech.stop();
    setState(() => _isListening = false);
    _analyzeFluency();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _durationSeconds++;
      });
    });
  }
  
  void _analyzeFluency() {
    if (_recognizedText.isEmpty) {
        setState(() => _fluencyStatus = "No speech detected.");
        return;
    }

    final wordCount = _recognizedText.trim().split(RegExp(r'\s+')).length;
    final minutes = _durationSeconds / 60.0;
    
    // WPM Calculation
    double wpm = (minutes > 0) ? (wordCount / minutes) : 0;
    
    // Accuracy (Similarity to target? Or just general fluency?)
    // For this module, we focus on Fluency (Speed + Confidence)
    
    String status = "Normal Fluency";
    Color statusColor = Colors.green;
    
    if (wpm < 60) {
        status = "Slow Speech/Disfluent";
        statusColor = Colors.orange;
    } else if (wpm > 180) {
        status = "Too Fast/Cluttered";
        statusColor = Colors.orange;
    }
    
    if (_confidence < 0.6) {
        status += " (Low Clarity)";
        statusColor = Colors.red;
    }

    setState(() {
      _wpm = wpm;
      _fluencyStatus = status;
    });
    
    _showResultDialog(status, statusColor);
  }

  void _showResultDialog(String status, Color color) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Fluency Analysis"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Words Per Minute: ${_wpm.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Confidence: ${(_confidence * 100).toStringAsFixed(1)}%"),
            const SizedBox(height: 8),
            Text("Duration: ${_durationSeconds}s"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Close"))],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech & Fluency")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Target Passage
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text("READ ALOUD", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(
                      _targetPassage,
                      style: const TextStyle(fontSize: 18, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Live Metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricCard("Duration", "${_durationSeconds}s", Icons.timer),
                _buildMetricCard("Confidence", "${(_confidence * 100).toInt()}%", Icons.check_circle),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Text Area
            Expanded(
              child: divContainer(
                child: SingleChildScrollView(
                  child: Text(
                    _recognizedText.isEmpty ? "Tap mic and start reading..." : _recognizedText,
                    style: TextStyle(
                        fontSize: 18, 
                        color: _recognizedText.isEmpty ? Colors.grey : Colors.black
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Control
            FloatingActionButton.extended(
              onPressed: _listen,
              backgroundColor: _isListening ? Colors.red : Colors.teal,
              icon: Icon(_isListening ? Icons.stop : Icons.mic),
              label: Text(_isListening ? "STOP LISTENING" : "START READING"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget divContainer({required Widget child}) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!)
        ),
        child: child
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)]
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
