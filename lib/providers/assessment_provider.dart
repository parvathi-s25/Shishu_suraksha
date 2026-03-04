import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/assessment_models.dart';
import '../core/services/database_service.dart';
import '../core/data/models/child_model.dart';
import '../core/services/data_service.dart';

final assessmentProvider = ChangeNotifierProvider((ref) => AssessmentProvider());

class AssessmentProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final DataService _dataService = DataService();

  AssessmentSession? _currentSession;
  final AssessmentState _state = AssessmentState();
  bool _isSaving = false;

  AssessmentSession? get currentSession => _currentSession;
  AssessmentState get state => _state;
  bool get isSaving => _isSaving;

  void startSession(ChildModel child) {
    _currentSession = AssessmentSession(
      id: 'SESS_${child.id}_${DateTime.now().millisecondsSinceEpoch}',
      childId: child.id,
      createdAt: DateTime.now(),
    );
    _state.reset();
    _dbService.createSession(_currentSession!);
    notifyListeners();
  }

  void completePose(PoseResult result) {
    if (_currentSession == null) return;
    _currentSession!.poseResult = result;
    _state.poseDone = true;
    _dbService.savePoseResult(_currentSession!.id, result);
    notifyListeners();
  }

  void completeDistance(DistanceCheckResult result) {
    if (_currentSession == null) return;
    _currentSession!.distanceResult = result;
    _state.distanceCheckDone = true;
    _dbService.saveDistanceResult(_currentSession!.id, result);
    notifyListeners();
  }

  void completeAlignment(EyeAlignmentResult result) {
    if (_currentSession == null) return;
    _currentSession!.alignmentResult = result;
    _state.eyeAlignmentDone = true;
    _dbService.saveAlignmentResult(_currentSession!.id, result);
    notifyListeners();
  }

  void completePupil(PupilReflexResult result) {
    if (_currentSession == null) return;
    _currentSession!.pupilResult = result;
    _state.pupilReflexDone = true;
    _dbService.savePupilResult(_currentSession!.id, result);
    notifyListeners();
  }

  void completeColorVision(ColorVisionResult result) {
    if (_currentSession == null) return;
    _currentSession!.colorVisionResult = result;
    _state.colorVisionDone = true;
    _dbService.saveColorVisionResult(_currentSession!.id, result);
    notifyListeners();
  }

  void completeRefraction(RefractionRiskResult result) {
    if (_currentSession == null) return;
    _currentSession!.refractionResult = result;
    _state.refractionRiskDone = true;
    _dbService.saveRefractionResult(_currentSession!.id, result);
    notifyListeners();
  }

  void completeMotor(PoseMotorResult result) {
    if (_currentSession == null) return;
    _currentSession!.motorResult = result;
    _state.motorAssessmentDone = true;
    _dbService.saveMotorResult(_currentSession!.id, result);
    _dataService.addAssessment();
    notifyListeners();
  }

  void completeSpeech(dynamic result) {
    if (_currentSession == null) return;
    _currentSession!.speechResult = result;
    _state.speechAssessmentDone = true;
    // _dbService.saveSpeechResult(...) // Add to DB later
    _dataService.addAssessment();
    notifyListeners();
  }

  void completeCognitive(dynamic result) {
    if (_currentSession == null) return;
    _currentSession!.cognitiveResult = result;
    _state.cognitiveAssessmentDone = true;
    _dataService.addAssessment();
    notifyListeners();
  }

  void completeSocialEmotional(dynamic result) {
    if (_currentSession == null) return;
    _currentSession!.socialEmotionalResult = result;
    _state.socialEmotionalDone = true;
    _dataService.addAssessment();
    notifyListeners();
  }

  Future<void> finishSession() async {
    if (_currentSession == null) return;
    _isSaving = true;
    notifyListeners();

    _currentSession!.completedAt = DateTime.now();
    await _dbService.completeSession(_currentSession!.id);
    
    _isSaving = false;
    notifyListeners();
  }

  double getProgress() {
    int total = 10;
    int done = 0;
    if (_state.poseDone) done++;
    if (_state.distanceCheckDone) done++;
    if (_state.eyeAlignmentDone) done++;
    if (_state.pupilReflexDone) done++;
    if (_state.colorVisionDone) done++;
    if (_state.refractionRiskDone) done++;
    if (_state.motorAssessmentDone) done++;
    if (_state.speechAssessmentDone) done++;
    if (_state.cognitiveAssessmentDone) done++;
    if (_state.socialEmotionalDone) done++;
    return done / total;
  }

  double getOverallScore() {
    if (_currentSession == null) return 0;
    return _currentSession!.calculateDevelopmentScore();
  }

  void reset() {
    _currentSession = null;
    _state.reset();
    notifyListeners();
  }
}
