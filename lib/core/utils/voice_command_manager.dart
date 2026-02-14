import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../ui/screens/dashboard/tabs/assessment_screen.dart';
import '../../ui/screens/screening/visual/visual_screening_screen.dart';
import '../../ui/screens/screening/audio/audio_screening_screen.dart';
import '../../screening/injury/injury_screening_screen.dart';
import '../../screening/symptoms/symptom_screening_screen.dart';

class VoiceCommandManager {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Function(String)? onStatusChanged;
  Function(String)? onErrorChanged;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    return await _speech.initialize(
      onStatus: (status) {
        if (onStatusChanged != null) onStatusChanged!(status);
        if (status == 'notListening' || status == 'done') {
          _isListening = false;
        }
      },
      onError: (errorNotification) {
        if (onErrorChanged != null) onErrorChanged!(errorNotification.errorMsg);
        _isListening = false;
      },
    );
  }

  void listen(BuildContext context, {required Function(String) onResult}) async {
    if (!_isListening) {
      bool available = await initialize();
      if (available) {
        _isListening = true;
        _speech.listen(
          onResult: (val) {
             if (val.finalResult) {
               _handleCommand(context, val.recognizedWords);
               onResult(val.recognizedWords);
               _isListening = false;
             }
          },
        );
      }
    } else {
      _isListening = false;
      _speech.stop();
    }
  }

  void stop() {
    _speech.stop();
    _isListening = false;
  }

  void _handleCommand(BuildContext context, String command) {
    debugPrint("Voice Command: $command");
    final cmd = command.toLowerCase();

    if (cmd.contains("start") || cmd.contains("assessment")) {
       // Navigate to Assessment (assuming we need to pick a child first, but for demo we can go to assessment tab if possible,
       // or just show a snackbar that assessment started)
       // Since AssessmentScreen requires a child map, we might need to mock it or ask user to select.
       // For now, let's navigate to Visual Screening as a direct action example.
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const VisualScreeningScreen()),
       );
    } else if (cmd.contains("visual") || cmd.contains("camera")) {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const VisualScreeningScreen()),
       );
    } else if (cmd.contains("hearing") || cmd.contains("audio")) {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const AudioScreeningScreen()),
       );
    } else if (cmd.contains("injury") || cmd.contains("wound") || cmd.contains("cut")) {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const InjuryScreeningScreen()),
       );
    } else if (cmd.contains("symptom") || cmd.contains("skin") || cmd.contains("disease")) {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const SymptomScreeningScreen()),
       );
    } else if (cmd.contains("back")) {
       if (Navigator.canPop(context)) {
         Navigator.pop(context);
       }
    }
  }
}
