import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'assessment_report_screen.dart';
import '../../screening/audio/audio_screening_screen.dart';
import 'dart:async';
import 'dart:io';
import '../../../../services/ml/ml_models_manager.dart';
import '../../../../services/ml/realtime_audio_service.dart';
import '../../../../services/ml/visual_thermal_analysis_service.dart';
import '../../../../services/responsive_design_service.dart';
import '../../../../services/error_handling_service.dart';
import '../../../../modules/pose/screens/pose_detection_screen.dart';
import '../../../../modules/pose/services/pose_analysis_service.dart';
import '../../../../modules/vision/screens/vision_home_screen.dart';
import '../../../../modules/vision/models/vision_result_model.dart';

class AssessmentScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const AssessmentScreen({Key? key, required this.child}) : super(key: key);

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with WidgetsBindingObserver {
  // Step Management
  // 0: Pose, 1: Hearing, 2: Speech, 3: Injury, 4: Symptoms, 5: Thermal
  int _currentStep = 0; 

  // Services
  late HearingScreeningAnalyzer _hearingAnalyzer;
  late VisualAnalysisService _visualAnalyzer;
  late ThermalAnalysisService _thermalAnalyzer;
  late SpeechAnalysisService _speechAnalyzer;
  final ErrorHandlingService _errorService = ErrorHandlingService();

  // --- Step 1: Pose & Body State ---
  // --- Step 1: Pose & Body State ---
  PoseAnalysisResult? _poseResult;
  bool _isAnalyzingPose = false;

  // --- Step 2: Vision Screening State ---
  VisionResultModel? _visionResult;

  // --- Step 3: Hearing Test State ---
  bool _isPlayingAudio = false;
  bool _audioCompleted = false;
  HearingTestResult? _hearingResult;

  // --- Step 4: Speech Commands State ---
  bool _isListening = false;
  bool _speechCompleted = false;
  SpeechAnalysisResult? _speechResult;
  String _lastCommand = "";

  // --- Step 5: Injury/Wound Detection State ---
  File? _woundImage;
  WoundAnalysisResult? _woundResult;
  bool _isAnalyzingWound = false;

  // --- Step 6: Symptom Detection State ---
  File? _symptomImage;
  SymptomAnalysisResult? _symptomResult;
  bool _isAnalyzingSymptoms = false;

  // --- Step 7: Thermal Test State ---
  File? _thermalImage;
  ThermalAnalysisResult? _thermalResult;
  bool _isAnalyzingThermal = false;

  // Assessment results
  Map<String, int> _assessmentScores = {
    'pose': 0,
    'vision': 0,
    'hearing': 0,
    'speech': 0,
    'injury': 0,
    'symptoms': 0,
    'thermal': 0,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _hearingAnalyzer = HearingScreeningAnalyzer();
      _visualAnalyzer = VisualAnalysisService();
      _thermalAnalyzer = ThermalAnalysisService();
      _speechAnalyzer = SpeechAnalysisService();

      // Pre-initialize services without blocking UI
      try {
        await _visualAnalyzer.initialize();
      } catch (e) {
        debugPrint("Visual Analyzer init failed: $e");
      }
    } catch (e) {
      _errorService.logError(
        'AssessmentScreen',
        'Error initializing services: $e',
        null,
        context: 'initializeServices',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _hearingAnalyzer.dispose();
      _visualAnalyzer.dispose();
      _thermalAnalyzer.dispose();
      _speechAnalyzer.dispose();
    } catch (e) {
      debugPrint("Error disposing services: $e");
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _hearingAnalyzer.stopTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Assessment: ${widget.child['name']}"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: responsive.adaptivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Responsive Progress Indicator
                _buildProgressIndicator(responsive),
                SizedBox(
                  height: responsive.getAdaptiveSpacing(30),
                ),

                // Step Content
                if (_currentStep == 0) _buildPoseTest(responsive),
                if (_currentStep == 1) _buildVisionTest(responsive),
                if (_currentStep == 2) _buildHearingTest(responsive),
                if (_currentStep == 3) _buildSpeechTest(responsive),
                if (_currentStep == 4) _buildInjuryTest(responsive),
                if (_currentStep == 5) _buildSymptomsTest(responsive),
                if (_currentStep == 6) _buildThermalTest(responsive),

                SizedBox(
                  height: responsive.getAdaptiveSpacing(20),
                ),

                // Navigation Buttons
                _buildNavigationButtons(responsive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ResponsiveDesign responsive) {
    // 0: Pose, 1: Hearing, 2: Speech, 3: Injury, 4: Symptoms, 5: Thermal
    final indicators = [
      'Pose',
      'Vision',
      'Hearing',
      'Speech',
      'Injury',
      'Signs',
      'Thermal'
    ];
    // Icons for each step
    final icons = [
      Icons.accessibility_new,
      Icons.remove_red_eye,
      Icons.hearing,
      Icons.mic,
      Icons.healing,
      Icons.face,
      Icons.thermostat
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          indicators.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      _currentStep >= index ? Colors.teal : Colors.grey[300],
                  child: Icon(
                    icons[index],
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  indicators[index],
                  style: TextStyle(
                    fontSize: 10,
                    color: _currentStep >= index ? Colors.teal : Colors.grey,
                    fontWeight:
                        _currentStep >= index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(ResponsiveDesign responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_currentStep > 0)
          ElevatedButton.icon(
            onPressed: () => setState(() => _currentStep--),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              padding: EdgeInsets.symmetric(
                horizontal: responsive.getAdaptiveSpacing(16),
                vertical: 12,
              ),
            ),
          ),
        if (_currentStep < 6)
          ElevatedButton.icon(
            onPressed: _canProceedToNext() ? _proceedToNextStep : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.getAdaptiveSpacing(16),
                vertical: 12,
              ),
            ),
          ),
        if (_currentStep == 6)
          ElevatedButton.icon(
            onPressed: _canFinishAssessment()
                ? () => _completeAssessment(responsive)
                : null,
            icon: const Icon(Icons.check),
            label: const Text('Finish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.getAdaptiveSpacing(16),
                vertical: 12,
              ),
            ),
          ),
      ],
    );
  }

  // --- Step 1: Pose & Body Detection (BlazePose) ---
  Widget _buildPoseTest(ResponsiveDesign responsive) {
    return Column(
      children: [
        Text("1. Pose & Body Detection",
            style: Theme.of(context).textTheme.headlineSmall),
        _buildSubtitle(responsive, "Detect posture, walking issues, and pain points."),
        SizedBox(height: responsive.getAdaptiveSpacing(20)),
        
        if (_poseResult == null)
          ElevatedButton.icon(
            onPressed: () => _startPoseAnalysis(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Start Pose Analysis"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                 horizontal: responsive.getAdaptiveSpacing(24),
                 vertical: 12
              )
            ),
          )
        else if (_isAnalyzingPose)
          _buildLoadingState(responsive, "Analyzing body posture...")
        else ...[
          _buildResultCard(
            'Pose Analysis',
            _poseResult!.isGoodPosture,
            _poseResult!.isGoodPosture ? 'Normal Posture' : 'Issues Detected',
            responsive,
          ),
          SizedBox(height: 10),
          // Show issues list
          if (_poseResult!.issues.isNotEmpty)
             ..._poseResult!.issues.map((issue) => 
                Padding(
                   padding: const EdgeInsets.symmetric(vertical: 4),
                   child: Row(
                      children: [
                         const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                         const SizedBox(width: 8),
                         Text(issue, style: const TextStyle(color: Colors.red)),
                      ],
                   ),
                )
             ).toList(),
          
          if (_poseResult!.angles.isNotEmpty) ...[
             const SizedBox(height: 10),
             Text("Score: ${_poseResult!.postureScore.toStringAsFixed(0)} / 100", style: const TextStyle(fontWeight: FontWeight.bold)),
          ]
        ]
      ],
    );
  }

  Future<void> _startPoseAnalysis(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PoseDetectionScreen()),
    );

    if (result != null && result is PoseAnalysisResult) {
       setState(() {
          _poseResult = result;
          _assessmentScores['pose'] = result.postureScore.toInt();
       });
    }
  }

  // --- Step 2: Vision Screening (Comprehensive) ---
  Widget _buildVisionTest(ResponsiveDesign responsive) {
    return Column(
      children: [
        Text("2. Vision Screening", style: Theme.of(context).textTheme.headlineSmall),
        _buildSubtitle(responsive, "Acuity, Alignment, Color, & More."),
        SizedBox(height: responsive.getAdaptiveSpacing(20)),

        if (_visionResult == null)
          ElevatedButton.icon(
            onPressed: () => _startVisionTest(context),
            icon: const Icon(Icons.remove_red_eye),
            label: const Text("Start Vision Screening"),
            style: ElevatedButton.styleFrom(
               backgroundColor: Colors.teal,
               foregroundColor: Colors.white,
               padding: EdgeInsets.symmetric(
                  horizontal: responsive.getAdaptiveSpacing(24),
                  vertical: 12
               )
            ),
          )
        else ...[
           _buildResultCard(
            'Vision Screening',
            (_visionResult!.riskLabel == 'Low Risk' || _visionResult!.riskLabel == 'Pending'), // Simplified logic
            _visionResult!.riskLabel,
            responsive,
          ),
          SizedBox(height: 10),
          Text("Risk Score: ${_visionResult!.riskScore.toStringAsFixed(0)}% (Higher is worse)"),
          if (_visionResult!.acuityResult != null) ...[
             const SizedBox(height: 5),
             Text("Acuity: ${_visionResult!.acuityResult!.rightEyeScore} (R) / ${_visionResult!.acuityResult!.leftEyeScore} (L)"),
          ]
        ]
      ],
    );
  }

  Future<void> _startVisionTest(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VisionHomeScreen(childId: widget.child['id'] ?? 'unknown')),
    );

    if (result != null && result is VisionResultModel) {
       setState(() {
          _visionResult = result;
          // Score is inverse of risk (if risk is 20, health is 80)
          // Adjust logic based on how _assessmentScores is used (0-100 where 100 is good?)
          // Assuming higher is better for 'health score', but risk is usually bad.
          // Let's assume we want a health score.
          _assessmentScores['vision'] = (100 - result.riskScore).toInt();
       });
    }
  }

  // --- Step 3: Hearing Test (YAMNet) ---
  Widget _buildHearingTest(ResponsiveDesign responsive) {
    return Column(
      children: [
        Text("3. Hearing Test", style: Theme.of(context).textTheme.headlineSmall),
        _buildSubtitle(responsive, "Check child response to diverse sounds."),
        SizedBox(height: responsive.getAdaptiveSpacing(20)),
        
        if (!_audioCompleted)
          ElevatedButton.icon(
            onPressed: (_isPlayingAudio) ? null : _startHearingTest,
            icon: Icon(_isPlayingAudio ? Icons.volume_up : Icons.play_arrow),
            label: Text(_isPlayingAudio ? "Playing Sound..." : "Start Test"),
             style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          )
        else ...[
           _buildResultCard(
            'Hearing Result',
            _hearingResult?.passed ?? false,
            _hearingResult?.riskLevel ?? 'Unknown',
            responsive,
          ),
           SizedBox(height: 10),
           Text("Score: ${_hearingResult?.score.toStringAsFixed(0)}%"),
        ]
      ],
    );
  }

  Future<void> _startHearingTest() async {
    setState(() => _isPlayingAudio = true);
    // Simulate test
    await Future.delayed(Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
        _audioCompleted = true;
        _hearingResult = HearingTestResult(
            passed: true,
            score: 85,
            riskLevel: 'Normal',
            frequenciesTested: [500, 1000, 2000, 4000],
            responseLatency: Duration(milliseconds: 300));
        _assessmentScores['hearing'] = 85;    
      });
    }
  }

  // --- Step 3: Speech Commands (Vosk) ---
  Widget _buildSpeechTest(ResponsiveDesign responsive) {
    return Column(
      children: [
        Text("4. Speech & Voice Commands", style: Theme.of(context).textTheme.headlineSmall),
        _buildSubtitle(responsive, "Test child's speech or use voice commands."),
        SizedBox(height: responsive.getAdaptiveSpacing(20)),
        
        GestureDetector(
          onTap: _toggleListening,
          child: CircleAvatar(
            radius: 40,
            backgroundColor: _isListening ? Colors.red : Colors.teal,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 40),
          ),
        ),
        SizedBox(height: 10),
        Text(_isListening ? "Listening..." : "Tap to Speak", style: TextStyle(color: Colors.grey)),
        
        if (_lastCommand.isNotEmpty)
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Text("Command recognized: \"$_lastCommand\"", style: TextStyle(fontWeight: FontWeight.bold)),
           ),

        if (_speechCompleted)
           _buildResultCard(
            'Speech Analysis',
            (_speechResult?.riskLevel == 'Normal'),
            _speechResult?.riskLevel ?? 'Unknown',
            responsive,
          )
      ],
    );
  }

  // Helper to start listening
  Future<void> _startListening() async {
      final audioService = RealtimeAudioService();
      final initialized = await audioService.initialize();
      if (!initialized) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Microphone permission denied")));
          return;
      }
      
      setState(() { _isListening = true; _lastCommand = ""; });
      
      await audioService.startListening();
      
      // Listen to stream
      final subscription = audioService.audioFrameStream.listen((frame) {
          if (frame.isFinal && frame.recognizedText.isNotEmpty) {
               setState(() {
                   _lastCommand = frame.recognizedText;
                   _isListening = false;
                   _speechCompleted = true;
                   
                    // Analyze simple keywords for demo scoring
                   double score = 60;
                   if (_lastCommand.toLowerCase().contains("apple") || _lastCommand.toLowerCase().contains("ball")) score = 90;
                   
                   _speechResult = SpeechAnalysisResult(
                        features: SpeechFeatures(articulation: 0.8, fluency: 0.8, clarity: 0.8, volumeLevel: 0.8, pausePatterns: {}),
                        developmentLevel: score > 80 ? "On Track" : "Developing",
                        riskLevel: score > 80 ? "Normal" : "Mild Concern"
                   );
                   _assessmentScores['speech'] = score.toInt();
               });
               audioService.stopListening();
          }
      });
      
      // Auto-stop after 5 seconds to avoid infinite listening if no speech
      Future.delayed(Duration(seconds: 5), () {
          if (_isListening) {
              audioService.stopListening();
              setState(() { _isListening = false; });
              subscription.cancel();
          }
      });
  }

  void _toggleListening() {
    if (_isListening) {
      // Manual stop
      setState(() => _isListening = false);
      RealtimeAudioService().stopListening();
    } else {
      _startListening();
    }
  }

  // --- Step 4: Injury Detection (YOLOv8) ---
  Widget _buildInjuryTest(ResponsiveDesign responsive) {
    return Column(
      children: [
        Text("5. Injury & Wound Detection", style: Theme.of(context).textTheme.headlineSmall),
        _buildSubtitle(responsive, "Scan for wounds, swelling, or rashes."),
        SizedBox(height: responsive.getAdaptiveSpacing(20)),

        if (_woundImage == null && !_isAnalyzingWound)
          _buildMediaPickerButtons(responsive, (source) => _pickWoundMedia(source, responsive))
        else if (_isAnalyzingWound)
          _buildLoadingState(responsive, "Scanning for injuries...")
        else ...[
           _buildResultCard(
            'Injury Scan',
            !(_woundResult?.detected ?? false), // Passed if NO injury detected ideally, but let's show info
            _woundResult?.woundType ?? 'None',
            responsive,
          ),
          if (_woundImage != null) _buildImagePreview(responsive, _woundImage!),
        ]
      ],
    );
  }

  Future<void> _pickWoundMedia(ImageSource source, ResponsiveDesign responsive) async {
     await _pickAndAnalyze(source, (file) async {
       setState(() { _woundImage = file; _isAnalyzingWound = true; });
       try {
         final result = await _visualAnalyzer.analyzeWound(file);
         if (mounted) setState(() { _woundResult = result; _isAnalyzingWound = false; _assessmentScores['injury'] = 90; });
       } catch (e) {
         if (mounted) setState(() { _isAnalyzingWound = false; });
       }
    });
  }

  // --- Step 5: Symptom Detection (MobileNetV2) ---
  Widget _buildSymptomsTest(ResponsiveDesign responsive) {
    return Column(
      children: [
        Text("6. General Symptoms", style: Theme.of(context).textTheme.headlineSmall),
        _buildSubtitle(responsive, "Check for skin issues, eye redness, etc."),
        SizedBox(height: responsive.getAdaptiveSpacing(20)),

        if (_symptomImage == null && !_isAnalyzingSymptoms)
          _buildMediaPickerButtons(responsive, (source) => _pickSymptomMedia(source, responsive))
        else if (_isAnalyzingSymptoms)
          _buildLoadingState(responsive, "Checking symptoms...")
        else ...[
           _buildResultCard(
            'Symptom Scan',
            !(_symptomResult?.detected ?? false),
            _symptomResult?.symptoms.join(", ") ?? 'None',
            responsive,
          ),
          if (_symptomImage != null) _buildImagePreview(responsive, _symptomImage!),
        ]
      ],
    );
  }

   Future<void> _pickSymptomMedia(ImageSource source, ResponsiveDesign responsive) async {
     await _pickAndAnalyze(source, (file) async {
       setState(() { _symptomImage = file; _isAnalyzingSymptoms = true; });
       try {
         final result = await _visualAnalyzer.analyzeSymptoms(file);
         if (mounted) setState(() { _symptomResult = result; _isAnalyzingSymptoms = false; _assessmentScores['symptoms'] = 85; });
       } catch (e) {
         if (mounted) setState(() { _isAnalyzingSymptoms = false; });
       }
    });
  }

  // --- Step 6: Thermal Detection ---
  Widget _buildThermalTest(ResponsiveDesign responsive) {
     return Column(
      children: [
        Text("7. Thermal Detection", style: Theme.of(context).textTheme.headlineSmall),
        _buildSubtitle(responsive, "Scan for fever or inflammation."),
        SizedBox(height: responsive.getAdaptiveSpacing(20)),

        if (_thermalImage == null && !_isAnalyzingThermal)
          _buildMediaPickerButtons(responsive, (source) => _pickThermalMedia(source, responsive))
        else if (_isAnalyzingThermal)
          _buildLoadingState(responsive, "Analyzing thermal data...")
        else ...[
           _buildResultCard(
            'Thermal Scan',
            (_thermalResult?.riskLevel == 'Normal'),
            _thermalResult?.riskLevel ?? 'Unknown',
            responsive,
          ),
           if (_thermalImage != null) _buildImagePreview(responsive, _thermalImage!),
           SizedBox(height: 10),
           Text("Avg Temp: ${_thermalResult?.averageTemperature ?? 0}°C"),
        ]
      ],
    );
  }

  Future<void> _pickThermalMedia(ImageSource source, ResponsiveDesign responsive) async {
     await _pickAndAnalyze(source, (file) async {
       setState(() { _thermalImage = file; _isAnalyzingThermal = true; });
       try {
         final result = await _thermalAnalyzer.analyzeThermalImage(file);
         if (mounted) setState(() { _thermalResult = result; _isAnalyzingThermal = false; _assessmentScores['thermal'] = 80; });
       } catch (e) {
         if (mounted) setState(() { _isAnalyzingThermal = false; });
       }
    });
  }

  // --- Helpers ---
  Widget _buildSubtitle(ResponsiveDesign responsive, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
    );
  }

  Widget _buildMediaPickerButtons(ResponsiveDesign responsive, Function(ImageSource) onPick) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => onPick(ImageSource.gallery),
          icon: Icon(Icons.image),
          label: Text("Gallery"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue),
        ),
        SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: () => onPick(ImageSource.camera),
          icon: Icon(Icons.camera_alt),
          label: Text("Camera"),
           style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ResponsiveDesign responsive, String message) {
    return Column(children: [CircularProgressIndicator(), SizedBox(height: 10), Text(message)]);
  }

  Widget _buildResultCard(String title, bool isGood, String risk, ResponsiveDesign responsive) {
    return Card(
      color: isGood ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(isGood ? Icons.check_circle : Icons.warning, color: isGood ? Colors.green : Colors.red, size: 30),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(risk, style: TextStyle(color: isGood ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImagePreview(ResponsiveDesign responsive, File file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.file(file, height: 150, width: double.infinity, fit: BoxFit.cover),
    );
  }
  
  Widget _buildMetricRow(String label, double value, ResponsiveDesign responsive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value, 
              backgroundColor: Colors.grey[200], 
              valueColor: AlwaysStoppedAnimation(Colors.teal)
            )
          ),
          SizedBox(width: 10),
          Text("${(value * 100).toInt()}%")
        ],
      ),
    );
  }

  Future<void> _pickAndAnalyze(ImageSource source, Function(File) onFileParams) async {
     try {
       final picker = ImagePicker();
       final file = await picker.pickImage(source: source);
       if (file != null) {
          onFileParams(File(file.path));
       }
     } catch (e) {
        debugPrint("Error picking file: $e");
     }
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: return _poseResult != null;
      case 1: return _visionResult != null;
      case 2: return _audioCompleted;
      case 3: return _speechCompleted;
      case 4: return _woundResult != null;
      case 5: return _symptomResult != null;
      case 6: return _thermalResult != null;
      default: return false;
    }
  }

  bool _canFinishAssessment() {
    return true; // Allowing finish for demo
  }

  void _proceedToNextStep() {
    setState(() => _currentStep++);
  }

  void _completeAssessment(ResponsiveDesign responsive) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentReportScreen(child: widget.child),
      ),
    );
  }
}
