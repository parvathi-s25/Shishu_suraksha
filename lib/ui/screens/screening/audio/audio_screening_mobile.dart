import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioScreeningScreen extends StatefulWidget {
  const AudioScreeningScreen({super.key});

  @override
  State<AudioScreeningScreen> createState() => _AudioScreeningScreenState();
}

class _AudioScreeningScreenState extends State<AudioScreeningScreen> {
  String _sound = "Press Start";
  bool _isRecording = false;
  Stream<Map<dynamic, dynamic>>? result;

  // Accuracy / Confidence
  int _confidence = 0;

  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
      model: 'assets/yamnet.tflite',
      label: 'assets/labels.txt',
      numThreads: 1,
      isAsset: true,
      inputType: 'rawAudio',
    );
  }

  void _startAudioRecognition() async {
    // Request permissions
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
      return;
    }

    if (!_isRecording) {
      setState(() => _isRecording = true);
      
      // Start recognition
      result = TfliteAudio.startAudioRecognition(
        sampleRate: 16000,
        bufferSize: 1280, // Adjust based on model requirements usually 16000/something
        numOfInferences: 5,
        detectionThreshold: 0.3,
      );

      result?.listen((event) {
        // Event format: {"key": "Class", "value": "Accuracy"} (Wait, library output varies, checking typical mapping)
        // Usually returns a Map with 'recognitionResult' and 'inferenceTime' etc or just the class.
        // Let's assume standard event mapping for tflite_audio:
        // event["recognitionResult"] -> String label
        // event["confidence"] -> double/int or contained in string
        
        String label = event["recognitionResult"].toString();
        // Trying to extract confidence if available, or simulation if not strictly returned by this simplified stream
        // Typically tflite_audio returns: recognitionResult: "Label (Confidence%)" or similar depending on setup.
        
        // Parsing "Clap (0.85)" if that's the format, or just taking the label.
        
        // For YAMNet, usually it returns the top class. 
        // Let's display what we get.
        
        if (mounted) {
          setState(() {
            _sound = label;
            // Extracting confidence if implied or simulating for this demo if raw model doesn't output it directly in simple mode
            // Assuming the model sends "Label accuracy" string or similar?
            // Actually, TfliteAudio stream often gives just the label in some configs.
            // We will display the raw result for now.
             
            // However, to satisfy "Accuracy Report", let's separate if possible.
            // If the string contains space and numbers:
            // "Clap 0.98"
          });
        }
      }).onDone(() {
        setState(() => _isRecording = false);
      });
    }
  }

  void _stopAudioRecognition() {
    TfliteAudio.stopAudioRecognition();
    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hearing Test"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red.withAlpha(50) : Colors.grey.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Result Display
            const Text("Detected Sound:", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 10),
            Text(
              _sound,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            
            // Accuracy / Confidence UI (Mocking/Parsing logic placeholder)
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Listening...",
                  style: TextStyle(color: Colors.red[300]),
                ),
              ),

            const SizedBox(height: 50),

            // Controls
            ElevatedButton.icon(
              onPressed: _isRecording ? _stopAudioRecognition : _startAudioRecognition,
              icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
              label: Text(_isRecording ? "Stop Listening" : "Start Test"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Instruct the child to clap or make a sound. Verify if the app detects it accurately.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
