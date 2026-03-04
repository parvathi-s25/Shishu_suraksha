// Quick Start Example Screen - Test Module 1 (Pose Detection)
// Copy this to screens/assessment/pose_assessment_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:async';

import '../../core/services/frame_processor.dart';
import '../../core/services/database_service.dart';
import '../../modules/pose_detection/pose_module.dart';
import '../../core/models/assessment_models.dart';

class PoseAssessmentScreen extends StatefulWidget {
  final CameraDescription camera;

  const PoseAssessmentScreen({required this.camera});

  @override
  State<PoseAssessmentScreen> createState() => _PoseAssessmentScreenState();
}

class _PoseAssessmentScreenState extends State<PoseAssessmentScreen> {
  late CameraController _cameraController;
  late FrameProcessor _frameProcessor;
  late PoseDetectionModule _poseModule;
  
  PoseResult? _latestResult;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Initialize camera
      _cameraController = CameraController(
        widget.camera,
        ResolutionPreset.medium,
      );
      await _cameraController.initialize();

      // Initialize ML Kit detectors
      final poseDetector = PoseDetector(
        options: PoseDetectorOptions(),
      );
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(),
      );

      // Initialize frame processor
      _frameProcessor = FrameProcessor(
        poseDetector: poseDetector,
        faceDetector: faceDetector,
        throttleFrames: 3, // ~10 FPS
      );

      // Initialize module
      _poseModule = PoseDetectionModule(
        frameProcessor: _frameProcessor,
        database: DatabaseService(),
      );

      // Start processing frames
      _cameraController.startImageStream(_processFrame);

      setState(() {});
    } catch (e) {
      print('Camera initialization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing || !_frameProcessor.shouldProcessFrame()) {
      return;
    }

    _isProcessing = true;

    try {
      final result = await _poseModule.processPoseFrame(image);
      
      if (result != null) {
        setState(() {
          _latestResult = result;
        });
      }
    } catch (e) {
      print('Frame processing error: $e');
    }

    _isProcessing = false;
  }

  Future<void> _completePoseAssessment() async {
    if (_latestResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get a valid reading first')),
      );
      return;
    }

    // Save to database
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    await _poseModule.completePoseAssessment(sessionId, _latestResult!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pose assessment saved! Score: ${_latestResult!.score.toStringAsFixed(0)}/100'),
      ),
    );

    // Navigate back or to next module
    if (mounted) {
      Navigator.pop(context, _latestResult);
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _frameProcessor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pose Assessment')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stand Fully in Frame'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Camera view
          Expanded(
            child: CameraPreview(_cameraController),
          ),

          // Result panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: _latestResult == null
                ? const Center(
                    child: Text(
                      'Waiting for pose detection...',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Score
                      Text(
                        'Score: ${_latestResult!.score.toStringAsFixed(0)}/100',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Landmarks count
                      Text(
                        'Landmarks detected: ${_latestResult!.landmarkCount}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),

                      const SizedBox(height: 8),

                      // Issues
                      if (_latestResult!.issues.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Issues Found:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              ..._latestResult!.issues
                                  .map((issue) => Text(
                                        '• $issue',
                                        style: const TextStyle(color: Colors.red),
                                      ))
                                  .toList(),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '✓ Good posture detected!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _DetailCard(
                            label: 'Shoulder Slope',
                            value: '${_latestResult!.shoulderSlope.toStringAsFixed(1)}°',
                          ),
                          _DetailCard(
                            label: 'Spine Dev',
                            value: '${_latestResult!.spineDeviation.toStringAsFixed(1)}°',
                          ),
                          _DetailCard(
                            label: 'Hip Slope',
                            value: '${_latestResult!.hipSlope.toStringAsFixed(1)}°',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Complete button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _completePoseAssessment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Complete Pose Assessment',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String label;
  final String value;

  const _DetailCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
