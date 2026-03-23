import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'assessment_report_screen.dart';
import 'dart:async';

class AssessmentScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const AssessmentScreen({Key? key, required this.child}) : super(key: key);

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  // Step Management
  int _currentStep = 0; // 0: Hearing, 1: Speaking, 2: Screening

  // Hearing Test State
  bool _isPlayingAudio = false;
  bool _audioCompleted = false;
  int? _selectedMcqOption;

  // Speaking Test State
  bool _isRecording = false;
  bool _recordingCompleted = false;

  // Screening Test State
  XFile? _selectedImage;
  XFile? _selectedVideo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assessment: ${widget.child['name']}"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, "Hearing"),
                  _buildLine(),
                  _buildStepIndicator(1, "Speaking"),
                  _buildLine(),
                  _buildStepIndicator(2, "Screening"),
                ],
              ),
              const SizedBox(height: 30),

              // Step Content
              if (_currentStep == 0) _buildHearingTest(),
              if (_currentStep == 1) _buildSpeakingTest(),
              if (_currentStep == 2) _buildScreeningTest(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? Colors.teal : Colors.grey[300],
          child: Text("${step + 1}", style: const TextStyle(fontSize: 12, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.teal : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildLine() {
    return Container(width: 40, height: 2, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 4));
  }

  // --- Step 1: Hearing Test ---
  Widget _buildHearingTest() {
    return Column(
      children: [
        const Text("Hearing Test", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Ensure the surroundings are quiet.", textAlign: TextAlign.center),
        const SizedBox(height: 30),

        ElevatedButton.icon(
          onPressed: _isPlayingAudio ? null : _startHearingAudio,
          icon: Icon(_isPlayingAudio ? Icons.volume_up : Icons.play_arrow),
          label: Text(_isPlayingAudio ? "Playing Test Audio..." : "Start Test (Play Audio)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
        
        if (_isPlayingAudio)
           const Padding(
             padding: EdgeInsets.only(top: 20),
             child: LinearProgressIndicator(color: Colors.teal),
           ),

        if (_audioCompleted) ...[
          const SizedBox(height: 30),
          const Text("Did the child startle or turn head?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildMcqOption(0, "Yes, immediately"),
          _buildMcqOption(1, "Yes, delayed"),
          _buildMcqOption(2, "No response"),
          
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _selectedMcqOption != null ? () => setState(() => _currentStep = 1) : null,
            child: const Text("Next"),
          ),
        ],
      ],
    );
  }

  void _startHearingAudio() {
    setState(() => _isPlayingAudio = true);
    // Simulate audio
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
          _audioCompleted = true;
        });
      }
    });
  }

  Widget _buildMcqOption(int value, String text) {
    return RadioListTile<int>(
      title: Text(text),
      value: value,
      groupValue: _selectedMcqOption,
      activeColor: Colors.teal,
      onChanged: (val) {
        setState(() => _selectedMcqOption = val);
      },
    );
  }

  // --- Step 2: Speaking Test ---
  Widget _buildSpeakingTest() {
    return Column(
      children: [
        const Text("Speaking Test", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Encourage the child to make sounds.", textAlign: TextAlign.center),
        const SizedBox(height: 30),

        if (!_recordingCompleted)
          GestureDetector(
            onTap: _toggleRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : Colors.teal,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          
        const SizedBox(height: 10),
        Text(
          _isRecording ? "Recording... Tap to Stop" : (_recordingCompleted ? "Recording Saved" : "Tap Mic to Start Recording"),
          style: TextStyle(color: _isRecording ? Colors.red : Colors.grey),
        ),

        if (_recordingCompleted) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {}, // Mock Playback
              icon: const Icon(Icons.play_arrow),
              label: const Text("Playback Recording"),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => setState(() => _currentStep = 2),
            child: const Text("Next"),
          ),
        ],
      ],
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      // Stop
      setState(() {
        _isRecording = false;
        _recordingCompleted = true;
      });
    } else {
      // Start
      setState(() => _isRecording = true);
    }
  }

  // --- Step 3: Screening Test ---
  Widget _buildScreeningTest() {
    return Column(
      children: [
        const Text("Screening Test", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("Upload visualization of the child performing tasks.", textAlign: TextAlign.center),
        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMediaButton(Icons.image, "Image", ImageSource.gallery, isVideo: false),
            const SizedBox(width: 16),
            _buildMediaButton(Icons.videocam, "Video", ImageSource.gallery, isVideo: true),
            const SizedBox(width: 16),
            _buildMediaButton(Icons.camera_alt, "Camera", ImageSource.camera, isVideo: false),
          ],
        ),
        
        const SizedBox(height: 20),
        
        if (_selectedImage != null)
           Column(children: [
             const Icon(Icons.check_circle, color: Colors.green, size: 40),
             const Text("Image Captured"),
             const SizedBox(height: 10),
             Image.network(_selectedImage!.path, height: 100),
           ]),
           
        if (_selectedVideo != null)
           const Column(children: [
             Icon(Icons.check_circle, color: Colors.green, size: 40),
             Text("Video Selected"),
           ]),

        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
               // Finish
               Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(builder: (context) => AssessmentReportScreen(child: widget.child)),
               );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Finish Assessment", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButton(IconData icon, String label, ImageSource source, {required bool isVideo}) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            final picker = ImagePicker();
            XFile? file;
            if (isVideo) {
              file = await picker.pickVideo(source: source);
              if (file != null) setState(() => _selectedVideo = file);
            } else {
              file = await picker.pickImage(source: source);
              if (file != null) setState(() => _selectedImage = file);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
