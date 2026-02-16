
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechAssessmentScreen extends StatefulWidget {
  const SpeechAssessmentScreen({Key? key}) : super(key: key);

  @override
  State<SpeechAssessmentScreen> createState() => _SpeechAssessmentScreenState();
}

class _SpeechAssessmentScreenState extends State<SpeechAssessmentScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Press the button to start speaking...";
  String _analysis = "";
  
  // Test sentence for child to repeat
  final String _targetSentence = "My name is Rahul and I like to play cricket";

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
           _text = "Listening...";
           _analysis = "";
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _analyzeSpeech();
    }
  }
  
  void _analyzeSpeech() {
    if (_text.isEmpty || _text == "Listening...") {
        setState(() => _analysis = "No speech detected.");
        return;
    }

    // Simple analysis logic
    final wordCount = _text.split(' ').length;
    
    // Similarity check (Naive)
    int matches = 0;
    final targetWords = _targetSentence.toLowerCase().split(' ');
    final spokenWords = _text.toLowerCase().split(' ');
    
    for (var word in targetWords) {
        if (spokenWords.contains(word)) matches++;
    }
    
    double similarity =  targetWords.isEmpty ? 0 : (matches / targetWords.length);
    
    setState(() {
      _analysis = "Analysis Result:\n"
          "Word Count: $wordCount\n"
          "Fluency Score: ${(similarity * 100).toStringAsFixed(1)}%\n"
          "${similarity > 0.7 ? 'Speech is clear' : 'Speech articulation may need attention'}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech & Fluency Check")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Ask the child to repeat:",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              _targetSentence,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _text,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_analysis.isNotEmpty)
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.blue[50], 
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.blue[200]!)
                 ),
                 child: Text(
                   _analysis,
                   style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                 ),
               ),
            const SizedBox(height: 30),
            FloatingActionButton(
              onPressed: _listen,
              backgroundColor: _isListening ? Colors.red : Colors.teal,
              child: Icon(_isListening ? Icons.mic_off : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}
