import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/modules/vision/models/vision_result_model.dart';
import 'package:shishu_suraksha/modules/vision/screens/acuity_test_screen.dart';
import 'package:shishu_suraksha/modules/vision/screens/strabismus_test_screen.dart';
import 'package:shishu_suraksha/modules/vision/screens/pupil_reflex_test_screen.dart';
import 'package:shishu_suraksha/modules/vision/screens/color_vision_test_screen.dart';
import 'package:shishu_suraksha/modules/vision/screens/field_of_vision_test_screen.dart';

import 'package:uuid/uuid.dart';

class VisionHomeScreen extends StatefulWidget {
  final String childId;
  const VisionHomeScreen({super.key, required this.childId});

  @override
  State<VisionHomeScreen> createState() => _VisionHomeScreenState();
}

class _VisionHomeScreenState extends State<VisionHomeScreen> {
  // Results
  AcuityResult? _acuityResult;
  StrabismusResult? _strabismusResult;
  PupilReflexResult? _pupilResult;
  ColorVisionResult? _colorResult;
  FieldOfVisionResult? _fieldResult;
  RefractionResult? _refractionResult;

  // Progress
  bool get _isAcuityDone => _acuityResult != null;
  bool get _isStrabismusDone => _strabismusResult != null;
  bool get _isPupilDone => _pupilResult != null;
  bool get _isColorDone => _colorResult != null;
  bool get _isFieldDone => _fieldResult != null;
  bool get _isRefractionDone => _refractionResult != null;

  bool get _allTestsCompleted =>
      _isAcuityDone &&
      _isStrabismusDone &&
      _isPupilDone &&
      _isColorDone &&
      _isFieldDone &&
      _isRefractionDone;

  void _navigateToTest(Widget screen, Function(dynamic) onResult) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result != null) {
      setState(() {
        onResult(result);
      });
    }
  }

  void _runRefractionEstimation() {
      // Simulate Refraction Estimation based on Acuity
      // In a real scenario, this might be a separate ML model or detailed questionnaire
      setState(() {
          double estimatedOD = 0.0;
          double estimatedOS = 0.0;
          
          // Simple heuristic logic
          if (_acuityResult != null) {
             if (_acuityResult!.rightEyeScore.contains("6/60")) estimatedOD = -2.5;
             if (_acuityResult!.rightEyeScore.contains("6/36")) estimatedOD = -1.5;
             
             if (_acuityResult!.leftEyeScore.contains("6/60")) estimatedOS = -2.5;
             if (_acuityResult!.leftEyeScore.contains("6/36")) estimatedOS = -1.5;
          }
          
          _refractionResult = RefractionResult(
             estimatedSphereOD: estimatedOD,
             estimatedSphereOS: estimatedOS,
             riskLabel: (estimatedOD < -1 || estimatedOS < -1) ? 'Myopia Risk' : 'Low Risk'
          );
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Refraction Risk Estimated from Acuity Data'))
      );
  }

  void _finishAssessment() {
    double totalScore = 0;
    
    // Weighted Scoring Logic
    // 1. Acuity (40%)
    if (_acuityResult != null && !_acuityResult!.rightEyeScore.contains("6/60")) totalScore += 40;
    
    // 2. Strabismus (15%)
    if (_strabismusResult != null && !_strabismusResult!.isAbnormal) totalScore += 15;
    
    // 3. Pupil (15%)
    if (_pupilResult != null && _pupilResult!.isNormal) totalScore += 15;
    
    // 4. Color (10%)
    if (_colorResult != null && _colorResult!.type == 'Normal') totalScore += 10;
    
    // 5. Field (10%)
    if (_fieldResult != null && _fieldResult!.locationDeficits == 'None') totalScore += 10;
    
    // 6. Refraction (10%)
    if (_refractionResult != null && _refractionResult!.riskLabel == 'Low Risk') totalScore += 10;

    final resultModel = VisionResultModel(
      id: const Uuid().v4(),
      childId: widget.childId,
      conductedBy: 'Teacher', // TODO: Get actual user
      timestamp: DateTime.now(),
      acuityResult: _acuityResult,
      strabismusResult: _strabismusResult,
      pupilResult: _pupilResult,
      colorResult: _colorResult,
      fieldResult: _fieldResult,
      refractionResult: _refractionResult,
      riskScore: (100 - totalScore), // Risk is inverse of health score
      riskLabel: totalScore > 80 ? 'Low Risk' : (totalScore > 50 ? 'Moderate Risk' : 'High Risk'),
    );

    Navigator.pop(context, resultModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Screening'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            
            const Text(
               "Screening Modules",
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            _buildTestCard(
              title: "Visual Acuity",
              desc: "Distance vision check (Snellen)",
              icon: Icons.text_fields,
              isDone: _isAcuityDone,
              onTap: () => _navigateToTest(const AcuityTestScreen(), (res) => _acuityResult = res as AcuityResult),
            ),
            
            _buildTestCard(
              title: "Eye Alignment",
              desc: "Strabismus & Head Tilt Detection",
              icon: Icons.remove_red_eye,
              isDone: _isStrabismusDone,
              onTap: () => _navigateToTest(const StrabismusTestScreen(), (res) => _strabismusResult = res as StrabismusResult),
            ),
            
            _buildTestCard(
              title: "Pupil Light Reflex",
              desc: "Response to flash stimulation",
              icon: Icons.flash_on,
              isDone: _isPupilDone,
              onTap: () => _navigateToTest(const PupilReflexTestScreen(), (res) => _pupilResult = res as PupilReflexResult),
            ),
            
            _buildTestCard(
              title: "Color Vision",
              desc: "Ishihara Color Plates",
              icon: Icons.palette,
              isDone: _isColorDone,
              onTap: () => _navigateToTest(const ColorVisionTestScreen(), (res) => _colorResult = res as ColorVisionResult),
            ),
            
             _buildTestCard(
              title: "Field of Vision",
              desc: "Peripheral vision sensitivity",
              icon: Icons.wifi_tethering,
              isDone: _isFieldDone,
              onTap: () => _navigateToTest(const FieldOfVisionTestScreen(), (res) => _fieldResult = res as FieldOfVisionResult),
            ),
            
             _buildTestCard(
              title: "Refraction Risk",
              desc: "Myopia/Hyperopia Estimation",
              icon: Icons.blur_on,
              isDone: _isRefractionDone,
              onTap: _runRefractionEstimation,
              isAuto: true,
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                  onPressed: _allTestsCompleted ? _finishAssessment : null,
                  style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     backgroundColor: _allTestsCompleted ? AppColors.primary : Colors.grey,
                  ),
                  child: const Text(
                      "Finish Vision Screening", 
                      style: TextStyle(fontSize: 18, color: Colors.white)
                  ),
               ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
           const Icon(Icons.medical_services, color: Colors.white, size: 40),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                    "Comprehensive Vision Test",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                 ),
                 Text(
                    "Completed: ${_countCompleted()}/6",
                    style: const TextStyle(color: Colors.white70),
                 ),
               ],
             ),
           ),
           CircularProgressIndicator(
              value: _countCompleted() / 6.0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
           )
        ],
      ),
    );
  }
  
  int _countCompleted() {
     int count = 0;
     if (_isAcuityDone) count++;
     if (_isStrabismusDone) count++;
     if (_isPupilDone) count++;
     if (_isColorDone) count++;
     if (_isFieldDone) count++;
     if (_isRefractionDone) count++;
     return count;
  }

  Widget _buildTestCard({
    required String title,
    required String desc,
    required IconData icon,
    required bool isDone,
    required VoidCallback onTap,
    bool isAuto = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
           backgroundColor: isDone ? Colors.green.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
           child: Icon(isDone ? Icons.check : icon, color: isDone ? Colors.green : AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: isDone 
             ? const Icon(Icons.check_circle, color: Colors.green)
             : (isAuto 
                 ? const Icon(Icons.auto_awesome, color: Colors.amber)
                 : const Icon(Icons.chevron_right)
               ),
        onTap: onTap,
      ),
    );
  }
}
