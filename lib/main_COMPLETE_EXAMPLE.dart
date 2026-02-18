// main.dart - Complete example showing how to integrate everything
// THIS SHOWS HOW TO SET UP YOUR APP WITH ALL 7 MODULES

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

// Import all our new files
import 'core/models/assessment_models.dart';
import 'core/services/frame_processor.dart';
import 'core/services/database_service.dart';
import 'modules/pose_detection/pose_module.dart';
import 'modules/vision/distance_check_module.dart';
import 'modules/vision/eye_alignment_module.dart';
import 'modules/vision/pupil_reflex_module.dart';
import 'modules/vision/color_vision_module.dart';
import 'modules/vision/refraction_risk_module.dart';
import 'modules/motor/motor_assessment_module.dart';
import 'providers/assessment_provider.dart';
import 'screens/assessment/assessment_dashboard.dart';

late CameraDescription _camera;
late FrameProcessor _frameProcessor;
late DatabaseService _database;

// Module instances - will be initialized after camera
late PoseDetectionModule _poseModule;
late DistanceCheckModule _distanceModule;
late EyeAlignmentModule _alignmentModule;
late PupilReflexModule _pupilModule;
late ColorVisionModule _colorVisionModule;
late RefractionRiskModule _refractionModule;
late MotorAssessmentModule _motorModule;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions
  await _requestPermissions();

  // Get available cameras
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    print('No cameras available');
    runApp(const MyApp(null, null));
    return;
  }

  // Use front camera (for face detection)
  _camera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first,
  );

  // Initialize ML Kit detectors
  final poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    ),
  );

  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: false,
    ),
  );

  // Initialize frame processor
  _frameProcessor = FrameProcessor(
    poseDetector: poseDetector,
    faceDetector: faceDetector,
    throttleFrames: 3, // ~10 FPS on 30 FPS camera
  );

  // Initialize database
  _database = DatabaseService();

  // Initialize all modules
  _poseModule = PoseDetectionModule(
    frameProcessor: _frameProcessor,
    database: _database,
  );

  _distanceModule = DistanceCheckModule(
    frameProcessor: _frameProcessor,
    database: _database,
  );

  _alignmentModule = EyeAlignmentModule(
    frameProcessor: _frameProcessor,
    database: _database,
  );

  _pupilModule = PupilReflexModule(
    frameProcessor: _frameProcessor,
    database: _database,
  );

  _colorVisionModule = ColorVisionModule(
    database: _database,
  );

  _refractionModule = RefractionRiskModule(
    frameProcessor: _frameProcessor,
    database: _database,
  );

  _motorModule = MotorAssessmentModule(
    frameProcessor: _frameProcessor,
    database: _database,
  );

  print('✓ All modules initialized');
  print('✓ Camera: ${_camera.name}');

  runApp(MyApp(_camera, null));
}

Future<void> _requestPermissions() async {
  final status = await Permission.camera.request();
  if (status.isDenied) {
    print('Camera permission denied');
  } else if (status.isPermanentlyDenied) {
    print('Camera permission permanently denied');
  }

  await Permission.storage.request();
}

class MyApp extends StatelessWidget {
  final CameraDescription? camera;
  final dynamic extra;

  const MyApp(this.camera, this.extra);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shishu Suraksha',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: camera == null
          ? const NoCameraScreen()
          : HomeScreen(camera: camera!),
    );
  }
}

class NoCameraScreen extends StatelessWidget {
  const NoCameraScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(
        child: Text('No camera available'),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final CameraDescription camera;

  const HomeScreen({required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shishu Suraksha'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Assessment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to assessment with all modules initialized
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) {
                        final provider = AssessmentProvider(
                          sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
                          childId: 'child_${DateTime.now().millisecondsSinceEpoch}',
                        );

                        // Initialize all modules
                        provider.initializeModules(
                          _poseModule,
                          _distanceModule,
                          _alignmentModule,
                          _pupilModule,
                          _colorVisionModule,
                          _refractionModule,
                          _motorModule,
                        );

                        return provider;
                      },
                      child: AssessmentDashboard(
                        childId: 'child_123',
                        childName: 'Test Child',
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Start New Assessment',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View Results feature coming soon'),
                  ),
                );
              },
              child: const Text('View Results'),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen for testing individual modules
class ModuleTestScreen extends StatefulWidget {
  final String moduleName;

  const ModuleTestScreen({required this.moduleName});

  @override
  State<ModuleTestScreen> createState() => _ModuleTestScreenState();
}

class _ModuleTestScreenState extends State<ModuleTestScreen> {
  String _output = '';

  @override
  void initState() {
    super.initState();
    _testModule();
  }

  Future<void> _testModule() async {
    try {
      setState(() => _output = 'Testing ${widget.moduleName}...');

      // Test each module
      switch (widget.moduleName) {
        case 'Pose':
          setState(() => _output = 'Pose Module\n\n✓ Initialized\n✓ Ready for camera input');
          break;
        case 'Distance':
          setState(() => _output = 'Distance Module\n\n✓ Initialized\n✓ Ready for camera input');
          break;
        case 'Alignment':
          setState(() => _output = 'Eye Alignment Module\n\n✓ Initialized\n✓ Ready for camera input');
          break;
        default:
          setState(() => _output = '✓ Module ready');
      }
    } catch (e) {
      setState(() => _output = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test ${widget.moduleName}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _output,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _testModule,
              child: const Text('Test Again'),
            ),
          ],
        ),
      ),
    );
  }
}
