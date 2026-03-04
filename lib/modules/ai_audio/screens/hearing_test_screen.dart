
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../services/ml/realtime_audio_service.dart'; // Import for HearingTestResult

class HearingTestScreen extends StatefulWidget {
  const HearingTestScreen({Key? key}) : super(key: key);

  @override
  State<HearingTestScreen> createState() => _HearingTestScreenState();
}

class _HearingTestScreenState extends State<HearingTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Test Configuration
  final List<int> _frequencies = [500, 1000, 2000, 4000];
  final List<double> _testVolumes = [0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 1.0];
  
  // State
  int _currentFreqIndex = 0;
  int _currentVolIndex = 0;
  String _currentEar = 'Left'; // 'Left' or 'Right'
  
  bool _isTestActive = false;
  bool _isPlayingTone = false;
  bool _toneHeard = false;
  
  // Results: { 'Left': { 500: 0.2, ... }, 'Right': ... }
  final Map<String, Map<int, double>> _results = {
    'Left': {},
    'Right': {},
  };
  
  String _statusMessage = "Find a quiet place and wear headphones.";

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTone(int freq, double volume, String ear) async {
    if (!_isTestActive) return;

    setState(() {
      _isPlayingTone = true;
      _toneHeard = false;
    });

    // Generate 1 second sine wave
    final Uint8List wavBytes = _generateSineWave(freq, 1.0, volume);
    
    await _audioPlayer.setBalance(ear == 'Left' ? -1.0 : 1.0);
    await _audioPlayer.setVolume(1.0); // Source volume max, controlled by wave amplitude
    await _audioPlayer.play(BytesSource(wavBytes));

    // Wait for tone duration + reaction buffer
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!_isTestActive) return;

    setState(() {
      _isPlayingTone = false;
    });
    
    _evaluateResponse();
  }

  void _evaluateResponse() {
    if (_toneHeard) {
      // Threshold found
      _recordResult(_testVolumes[_currentVolIndex]);
      _nextFrequency();
    } else {
      // Not heard, increase volume
      if (_currentVolIndex < _testVolumes.length - 1) {
        _currentVolIndex++;
        _scheduleNextTone();
      } else {
        // Max volume reached, no response
        _recordResult(1.1); // 1.1 indicates > Max
        _nextFrequency();
      }
    }
  }

  void _recordResult(double threshold) {
    _results[_currentEar]![_frequencies[_currentFreqIndex]] = threshold;
  }

  void _nextFrequency() {
    if (_currentFreqIndex < _frequencies.length - 1) {
      _currentFreqIndex++;
      _currentVolIndex = 0;
      _scheduleNextTone();
    } else {
      // Done with this ear
      if (_currentEar == 'Left') {
        _startRightEar();
      } else {
        _finishTest();
      }
    }
  }

  void _startRightEar() {
    setState(() {
      _currentEar = 'Right';
      _currentFreqIndex = 0;
      _currentVolIndex = 0;
      _statusMessage = "Switching to Right Ear...";
    });
    Future.delayed(const Duration(seconds: 2), _scheduleNextTone);
  }

  void _scheduleNextTone() {
    if (!_isTestActive) return;
    
    // Random delay between tones to prevent rhythm guessing
    final delay = Random().nextInt(1000) + 500; 
    Future.delayed(Duration(milliseconds: delay), () {
      if (_isTestActive) {
        _playTone(_frequencies[_currentFreqIndex], _testVolumes[_currentVolIndex], _currentEar);
      }
    });
  }

  // --- WAV Generation Helper ---
  Uint8List _generateSineWave(int frequency, double durationSeconds, double volume) {
    const int sampleRate = 44100;
    final int numSamples = (durationSeconds * sampleRate).toInt();
    final int byteRate = sampleRate * 2; // 16-bit mono
    final int dataSize = numSamples * 2;
    final int totalSize = 36 + dataSize;
    
    final ByteData byteData = ByteData(totalSize + 8);
    
    // RIFF Header
    byteData.setUint8(0, 0x52); // R
    byteData.setUint8(1, 0x49); // I
    byteData.setUint8(2, 0x46); // F
    byteData.setUint8(3, 0x46); // F
    byteData.setUint32(4, totalSize, Endian.little);
    byteData.setUint8(8, 0x57); // W
    byteData.setUint8(9, 0x41); // A
    byteData.setUint8(10, 0x56); // V
    byteData.setUint8(11, 0x45); // E
    
    // fmt Chunk
    byteData.setUint8(12, 0x66); // f
    byteData.setUint8(13, 0x6D); // m
    byteData.setUint8(14, 0x74); // t
    byteData.setUint8(15, 0x20); // space
    byteData.setUint32(16, 16, Endian.little); // Chunk size
    byteData.setUint16(20, 1, Endian.little); // PCM
    byteData.setUint16(22, 1, Endian.little); // Mono
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, 2, Endian.little); // Block align
    byteData.setUint16(34, 16, Endian.little); // Bits per sample
    
    // data Chunk
    byteData.setUint8(36, 0x64); // d
    byteData.setUint8(37, 0x61); // a
    byteData.setUint8(38, 0x74); // t
    byteData.setUint8(39, 0x61); // a
    byteData.setUint32(40, dataSize, Endian.little);

    // Audio Data
    for (int i = 0; i < numSamples; i++) {
        double t = i / sampleRate;
        // Sine wave
        double sample = volume * sin(2 * pi * frequency * t);
        // Scale to 16-bit integer range
        int val = (sample * 32767).toInt();
        byteData.setInt16(44 + i * 2, val, Endian.little);
    }
    
    return byteData.buffer.asUint8List();
  }

  void _startTest() {
    setState(() {
      _isTestActive = true;
      _currentEar = 'Left';
      _currentFreqIndex = 0;
      _currentVolIndex = 0;
      _results['Left'] = {};
      _results['Right'] = {};
      _statusMessage = "Testing Left Ear...";
    });
    _scheduleNextTone();
  }

  void _stopTest() {
    setState(() {
      _isTestActive = false;
      _statusMessage = "Test Stopped.";
    });
    _audioPlayer.stop();
  }

  void _finishTest() {
    setState(() {
      _isTestActive = false;
      _statusMessage = "Measurement Complete";
    });
    _showResultsDialog();
  }

  // ... inside _HearingTestScreenState ...

  // Calculate generic score based on average threshold
  // Lower threshold is better (hearing at lower volume)
  // Simple logic: Average volume threshold. If < 0.3 (30%) -> Great.
  HearingTestResult _calculateResult() {
     // Averages
     List<double> leftVals = _results['Left']!.values.where((v) => v <= 1.0).toList();
     List<double> rightVals = _results['Right']!.values.where((v) => v <= 1.0).toList();
     
     double leftAvg = leftVals.isNotEmpty ? leftVals.reduce((a, b) => a + b) / leftVals.length : 1.0;
     double rightAvg = rightVals.isNotEmpty ? rightVals.reduce((a, b) => a + b) / rightVals.length : 1.0;
     
     double totalAvg = (leftAvg + rightAvg) / 2;
     
     // Score: Map 0.1 vol to 100, 1.0 vol to 0.
     double score = ((1.0 - totalAvg) * 100).clamp(0, 100);
     
     String risk = "Normal";
     if (score < 50) risk = "Moderate Concern";
     if (score < 25) risk = "High Concern";

     return HearingTestResult(
        passed: score > 70,
        score: score,
        riskLevel: risk,
        frequenciesTested: _frequencies,
        responseLatency: const Duration(seconds: 0) // Approximation
     );
  }

  void _showResultsDialog() {
    final result = _calculateResult();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Hearing Assessment Results"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Text("Audiogram (Thresholds)", style: TextStyle(fontWeight: FontWeight.bold)),
               const SizedBox(height: 10),
               ..._frequencies.map((freq) {
                 return Padding(
                   padding: const EdgeInsets.symmetric(vertical: 4),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("${freq}Hz"),
                       // Use Flexible/Expanded to prevent overflow
                       Flexible(
                         child: Text(
                           "L: ${_formatVol(_results['Left']?[freq])} | R: ${_formatVol(_results['Right']?[freq])}",
                           overflow: TextOverflow.ellipsis,
                           textAlign: TextAlign.end,
                         ),
                       ),
                     ],
                   ),
                 );
               }).toList(),
               const SizedBox(height: 20),
               Text("Score: ${result.score.toStringAsFixed(0)}% (${result.riskLevel})", 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
               const SizedBox(height: 5),
               const Text("Note: Lower % is better (heard at lower volume).", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, result); // Exit screen WITH RESULT
            },
            child: const Text("Done"),
          )
        ],
      )
    );
  }

  String _formatVol(double? vol) {
    if (vol == null) return "-";
    if (vol > 1.0) return ">100%";
    return "${(vol * 100).toInt()}%";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pure Tone Audiometry")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            
            // Status Icon
            Icon(
              _currentEar == 'Left' ? Icons.hearing : Icons.hearing_disabled, // Just a visual
              size: 80, 
              color: _isTestActive ? Colors.blue : Colors.grey
            ),
            const SizedBox(height: 20),
            
            Text(
              _isTestActive ? "Testing $_currentEar Ear" : _statusMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 10),
            if (_isTestActive)
              const LinearProgressIndicator(),

            const Spacer(),
            
            // Interaction Button
            if (_isTestActive)
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_isPlayingTone) {
                      setState(() => _toneHeard = true); // Will be picked up by _evaluateResponse usually
                      // But since _playTone waits 1.5s, we need to signal it.
                      // Actually _playTone logic is async. 
                      // Better approach: _toneHeard flag is checked in _evaluateResponse which is called AFTER play.
                      // IF user taps WHILE playing, we should register it immediately? 
                      // Current logic: wait for tone to finish then check flag. This is fine for simple test.
                    }
                  }, 
                  icon: const Icon(Icons.thumb_up, size: 32),
                  label: const Text("I HEAR IT!", style: TextStyle(fontSize: 24)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _startTest,
                  child: const Text("START HEARING TEST"),
                ),
              ),
              
             const SizedBox(height: 20),
             const Text(
               "Instructions: Press 'I HEAR IT' as soon as you hear a beep. The sounds will get quieter.",
               textAlign: TextAlign.center,
               style: TextStyle(color: Colors.grey),
             ),
             const Spacer(),
          ],
        ),
      ),
    );
  }
}
