// Assessment state provider using Provider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/assessment_models.dart';
import '../core/services/database_service.dart';
import '../modules/pose_detection/pose_module.dart';
import '../modules/vision/distance_check_module.dart';
import '../modules/vision/eye_alignment_module.dart';
import '../modules/vision/pupil_reflex_module.dart';
import '../modules/vision/color_vision_module.dart';
import '../modules/vision/refraction_risk_module.dart';
import '../modules/motor/motor_assessment_module.dart';

class AssessmentProvider extends ChangeNotifier {
  late AssessmentSession currentSession;
  final AssessmentState assessmentState = AssessmentState();
  
  // Modules
  late PoseDetectionModule poseModule;
  late DistanceCheckModule distanceModule;
  late EyeAlignmentModule alignmentModule;
  late PupilReflexModule pupilModule;
  late ColorVisionModule colorvisionModule;
  late RefractionRiskModule refractionModule;
  late MotorAssessmentModule motorModule;

  // Database
  final DatabaseService database = DatabaseService();

  // Status tracking
  String _status = '';
  String get status => _status;

  AssessmentProvider({
    required String sessionId,
    required String childId,
  }) {
    _initializeSession(sessionId, childId);
  }

  void _initializeSession(String sessionId, String childId) {
    currentSession = AssessmentSession(
      id: sessionId,
      childId: childId,
      createdAt: DateTime.now(),
    );
  }

  /// Initialize all modules (call after FrameProcessor is ready)
  void initializeModules(
    PoseDetectionModule pose,
    DistanceCheckModule distance,
    EyeAlignmentModule alignment,
    PupilReflexModule pupil,
    ColorVisionModule colorvision,
    RefractionRiskModule refraction,
    MotorAssessmentModule motor,
  ) {
    poseModule = pose;
    distanceModule = distance;
    alignmentModule = alignment;
    pupilModule = pupil;
    colorvisionModule = colorvision;
    refractionModule = refraction;
    motorModule = motor;
  }

  /// Mark pose assessment complete
  Future<void> completePose(PoseResult result) async {
    currentSession.poseResult = result;
    assessmentState.poseDone = true;
    _status = 'Pose assessment complete: ${result.score.toStringAsFixed(0)}/100';
    await database.savePoseResult(currentSession.id, result);
    notifyListeners();
  }

  /// Mark distance check complete
  Future<void> completeDistance(DistanceCheckResult result) async {
    currentSession.distanceResult = result;
    assessmentState.distanceCheckDone = true;
    _status = 'Distance check complete: ${result.status}';
    await database.saveDistanceResult(currentSession.id, result);
    notifyListeners();
  }

  /// Mark alignment assessment complete
  Future<void> completeAlignment(EyeAlignmentResult result) async {
    currentSession.alignmentResult = result;
    assessmentState.eyeAlignmentDone = true;
    _status = 'Eye alignment check complete: ${result.status}';
    await database.saveAlignmentResult(currentSession.id, result);
    notifyListeners();
  }

  /// Mark pupil reflex complete
  Future<void> completePupil(PupilReflexResult result) async {
    currentSession.pupilResult = result;
    assessmentState.pupilReflexDone = true;
    _status = 'Pupil reflex complete: ${result.status}';
    await database.savePupilResult(currentSession.id, result);
    notifyListeners();
  }

  /// Mark color vision complete
  Future<void> completeColorVision(ColorVisionResult result) async {
    currentSession.colorVisionResult = result;
    assessmentState.colorVisionDone = true;
    _status = 'Color vision complete: ${result.accuracy.toStringAsFixed(1)}% accuracy';
    await database.saveColorVisionResult(currentSession.id, result);
    notifyListeners();
  }

  /// Mark refraction risk complete
  Future<void> completeRefraction(RefractionRiskResult result) async {
    currentSession.refractionResult = result;
    assessmentState.refractionRiskDone = true;
    _status = 'Refraction risk assessment complete: ${result.riskLevel}';
    await database.saveRefractionResult(currentSession.id, result);
    notifyListeners();
  }

  /// Mark motor assessment complete
  Future<void> completeMotor(MotorAssessmentResult result) async {
    currentSession.motorResult = result;
    assessmentState.motorAssessmentDone = true;
    _status = 'Motor assessment complete: ${result.overallMotorScore.toStringAsFixed(0)}/100';
    await database.saveMotorResult(currentSession.id, result);
    notifyListeners();
  }

  /// Complete entire assessment
  Future<void> completeAllAssessments() async {
    if (!assessmentState.allComplete) {
      _status = 'Cannot complete: not all assessments done';
      notifyListeners();
      return;
    }

    currentSession.completedAt = DateTime.now();
    await database.createSession(currentSession);
    await database.completeSession(currentSession.id);
    _status = 'Assessment complete!';
    notifyListeners();
  }

  /// Get overall development score
  double getOverallScore() {
    return currentSession.calculateDevelopmentScore();
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    int completed = 0;
    if (assessmentState.poseDone) completed++;
    if (assessmentState.distanceCheckDone) completed++;
    if (assessmentState.eyeAlignmentDone) completed++;
    if (assessmentState.pupilReflexDone) completed++;
    if (assessmentState.colorVisionDone) completed++;
    if (assessmentState.refractionRiskDone) completed++;
    if (assessmentState.motorAssessmentDone) completed++;

    return (completed / 7) * 100;
  }

  /// Reset for new session
  void reset(String newSessionId, String childId) {
    assessmentState.reset();
    _initializeSession(newSessionId, childId);
    _status = 'New assessment session started';
    notifyListeners();
  }

  @override
  void dispose() {
    database.close();
    super.dispose();
  }
}
