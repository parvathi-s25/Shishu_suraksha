import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class AudioScreeningScreen extends StatefulWidget {
  const AudioScreeningScreen({super.key});

  @override
  State<AudioScreeningScreen> createState() => _AudioScreeningScreenState();
}

class _AudioScreeningScreenState extends State<AudioScreeningScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String _statusMessage = "Press Start to begin hearing test";
  String? _result;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _isRecording = true;
      _statusMessage = "Listening for response...";
      _result = null;
    });

    // Simulate analysis process
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _statusMessage = "Test Complete";
          // Simulate result
          _result = "NORMAL HEARING RESPONSE"; 
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hearing Screening"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Listening Icon
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: _isRecording 
                          ? Colors.red.withOpacity(0.1 + (_animationController.value * 0.2)) 
                          : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording ? Colors.red : Colors.grey[300]!,
                        width: _isRecording ? 4 : 2
                      )
                    ),
                    child: Icon(
                      _isRecording ? Icons.mic : Icons.hearing,
                      size: 80,
                      color: _isRecording ? Colors.red : Colors.indigo,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Status Text
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Result Display
              if (_result != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green)
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _result!,
                        style: const TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.green
                        ),
                      ),
                      const Text("Pass", style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              
              const Spacer(),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.indigo),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Ensure a quiet environment. Play the stimulus sound and observe child's response (head turn, eye widen).",
                        style: TextStyle(fontSize: 12, color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isRecording ? null : _startTest,
                  icon: Icon(_result == null ? Icons.play_arrow : Icons.refresh),
                  label: Text(_result == null ? "START TEST" : "RETEST"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
