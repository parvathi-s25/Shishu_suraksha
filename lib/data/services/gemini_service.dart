import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the Gemini Service
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class GeminiService {
  late final GenerativeModel _model;
  final String _apiKey = 'YOUR_API_KEY_HERE'; // TODO: Replace with secure storage or config

  bool _isInitialized = false;

  GeminiService() {
    _init();
  }

  void _init() {
    // We use gemini-pro for text-only chat
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
    _isInitialized = true;
  }

  Future<String> sendMessage(String message) async {
    if (!_isInitialized) throw Exception("Gemini not initialized");

    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      return response.text ?? "I'm having trouble understanding that. Please try again.";
    } catch (e) {
      return "Error connecting to AI: $e. (Did you set the API Key?)";
    }
  }

  Stream<GenerateContentResponse> streamMessage(String message) {
    if (!_isInitialized) throw Exception("Gemini not initialized");
    final content = [Content.text(message)];
    return _model.generateContentStream(content);
  }
}
