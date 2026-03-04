import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import '../../services/ai_service.dart';

class VoiceAssistantWidget extends StatefulWidget {
  final VoidCallback onClose;

  const VoiceAssistantWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  _VoiceAssistantWidgetState createState() => _VoiceAssistantWidgetState();
}

class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget> {
  // TTS & STT
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;

  // State
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isMuted = false;
  String _selectedLanguage = 'te-IN'; // Changed to Telugu (India) as default
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat History
  final List<Map<String, dynamic>> _messages = [
    {'text': "నమస్కారం! నేను మీ శిశు సురక్ష సహాయకుడిని. ఈరోజు నేను మీకు ఎలా సహాయం చేయగలను?", 'isUser': false},
  ];

  // Language Options
  final Map<String, String> _languages = {
    'en-IN': 'English',
    'hi-IN': 'Hindi',
    'kn-IN': 'Kannada',
    'te-IN': 'Telugu',
    'ta-IN': 'Tamil',
  };

  @override
  void initState() {
    super.initState();
    _initTTS();
    _initSTT();
  }

  Future<void> _initTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Slower rate for clarity
    
    _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setErrorHandler((msg) => setState(() => _isSpeaking = false));
  }

  Future<void> _initSTT() async {
    _speech = stt.SpeechToText();
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (errorNotification) => debugPrint('STT Error: $errorNotification'),
      );
      if (!available) {
        debugPrint('Speech recognition not available on this device');
      }
    } catch (e) {
      debugPrint('Error initializing STT: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Actions ---

  Future<void> _speak(String text) async {
    if (_isMuted) return;
    await _flutterTts.setLanguage(_selectedLanguage);
    await _flutterTts.speak(text);
  }

  Future<void> _listen() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
      return;
    }

    // Check permission first
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission required for voice interaction")),
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('STT Status: $status');
        if (status == 'done' || status == 'notListening') {
           setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        debugPrint('STT Error: $errorNotification');
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _textController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            _handleSubmitted(_textController.text);
          }
        },
        localeId: _selectedLanguage,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition is not available right now.")),
      );
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final String userText = text.trim();
    _textController.clear();
    setState(() {
      _messages.add({'text': userText, 'isUser': true});
      _isListening = false;
    });
    _scrollToBottom();

    // Show typing indicator or similar vibe if needed
    // For now, call AI Service
    String response = await AIService().generateResponse(userText, _languages[_selectedLanguage] ?? 'Telugu');
    
    if (mounted) {
      setState(() {
        _messages.add({'text': response, 'isUser': false});
      });
      _scrollToBottom();
      _speak(response);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(child: _buildChatList()),
          const Divider(height: 1),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Bot Icon
          CircleAvatar(
            backgroundColor: Colors.teal.shade100,
            child: const Icon(Icons.smart_toy, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          
          // Title & Language
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Voice Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  isDense: true,
                  underline: const SizedBox(),
                  style: TextStyle(color: Colors.teal.shade700, fontSize: 12),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.teal),
                  items: _languages.entries.map((e) {
                    return DropdownMenuItem(value: e.key, child: Text(e.value));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLanguage = val);
                  },
                ),
              ],
            ),
          ),

          // Mute Toggle
          IconButton(
            icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, 
              color: _isMuted ? Colors.grey : Colors.teal),
            onPressed: () {
              setState(() => _isMuted = !_isMuted);
              _flutterTts.stop();
            },
            tooltip: _isMuted ? "Unmute Voice" : "Mute Voice",
          ),
          
          // Close
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isUser = msg['isUser'];
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? Colors.teal : Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            child: Text(
              msg['text'],
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _isListening ? "Listening..." : "Type or speak...",
                fillColor: Colors.grey.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8),
          
          // Mic Button
          GestureDetector(
            onLongPress: _listen, // Alternative interaction
            onTap: _listen,
            child: CircleAvatar(
              backgroundColor: _isListening ? Colors.redAccent : Colors.teal,
              radius: 24,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none, 
                color: Colors.white,
              ),
            ),
          ),
          
          if (_textController.text.isNotEmpty) ...[
             const SizedBox(width: 8),
             CircleAvatar(
               backgroundColor: Colors.teal,
               radius: 24,
               child: IconButton(
                 icon: const Icon(Icons.send, color: Colors.white, size: 20),
                 onPressed: () => _handleSubmitted(_textController.text),
               ),
             ),
          ]
        ],
      ),
    );
  }
}
