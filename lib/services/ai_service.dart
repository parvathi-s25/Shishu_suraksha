import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";
  
  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  Future<String> generateResponse(String prompt, String language) async {
    if (_apiKey.isEmpty) {
      return "Error: API Key not found. Please check your .env file.";
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are ShishuSuraksha AI, a helpful assistant for Anganwadi teachers in India. "
                         "You help with child growth monitoring, malnutrition reports, and ECD (Early Childhood Development). "
                         "The user is interacting in $language. Please respond strictly in $language. "
                         "Keep responses concise, empathetic, and professional."
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].trim();
      } else {
        print("Groq API Error: ${response.body}");
        return "Sorry, I am having trouble connecting to my brain. Please try again later.";
      }
    } catch (e) {
      print("AI Service Exception: $e");
      return "Something went wrong. Please check your internet connection.";
    }
  }
}
