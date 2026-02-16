
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HearingTestScreen extends StatefulWidget {
  const HearingTestScreen({Key? key}) : super(key: key);

  @override
  State<HearingTestScreen> createState() => _HearingTestScreenState();
}

class _HearingTestScreenState extends State<HearingTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Mock frequencies for MVP
  final List<int> _frequencies = [500, 1000, 2000, 4000];
  int _currentFreqIndex = 0;
  bool _isPlaying = false;
  bool _waitingForResponse = false;
  DateTime? _soundStartTime;
  List<int> _reactionTimes = [];
  String _statusMessage = "Press Start to begin hearing test";
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTest() async {
    setState(() {
      _currentFreqIndex = 0;
      _reactionTimes = [];
      _statusMessage = "Listen specifically for the tone...";
      _isPlaying = true;
    });
    _playNextTone();
  }

  void _playNextTone() async {
    if (_currentFreqIndex >= _frequencies.length) {
      _finishTest();
      return;
    }

    setState(() {
      _waitingForResponse = false;
    });

    // Random delay 1-3 seconds
    final delay = Random().nextInt(2000) + 1000;
    await Future.delayed(Duration(milliseconds: delay));

    if (!mounted) return;

    // Play tone (Assuming assets exist, or handle error)
    // For MVP, we might simulate sound playing state if assets missing
    try {
      // In real app: await _audioPlayer.play(AssetSource('audio/tone_${_frequencies[_currentFreqIndex]}.mp3'));
      // Using a system sound or standard notification for demo if specific tones unavailable
      // await _audioPlayer.play(Source.url("https://...")); 
      
      // Simulating "Sound Played" state for logic verification
      setState(() {
        _soundStartTime = DateTime.now();
        _waitingForResponse = true;
        _statusMessage = "Sound Playing! Tap now!"; // Visual cue for dev/testing
      });

      // Stop sound after 1 sec
      await Future.delayed(const Duration(seconds: 1));
      // await _audioPlayer.stop();

    } catch (e) {
      print("Audio Error: $e");
    }
  }

  void _onTap() {
    if (_waitingForResponse && _soundStartTime != null) {
      final reactionTime = DateTime.now().difference(_soundStartTime!).inMilliseconds;
      _reactionTimes.add(reactionTime);
      
      setState(() {
        _statusMessage = "Good! Reaction: ${reactionTime}ms";
        _waitingForResponse = false;
        _currentFreqIndex++;
      });

      _playNextTone();
    }
  }

  void _finishTest() {
    setState(() {
      _isPlaying = false;
      int avgReaction = _reactionTimes.isEmpty ? 0 : (_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).round();
      _statusMessage = "Test Complete.\nAvg Reaction Time: ${avgReaction}ms\n"
          "${avgReaction < 1000 ? 'Normal Hearing Response' : 'Delayed Response Detected'}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hearing Screening")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hearing, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            if (!_isPlaying)
              ElevatedButton(
                onPressed: _startTest,
                child: const Text("Start Test"),
              )
            else
              GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _waitingForResponse ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: [
                       if (_waitingForResponse)
                         BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 20, spreadRadius: 10)
                    ]
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "TAP\nWhen Heard",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
