// Complete Assessment Dashboard - Shows all 7 modules integrated
// Reference implementation for main assessment flow
// Path: lib/screens/assessment/assessment_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../providers/assessment_provider.dart';
import '../../core/models/assessment_models.dart';

class AssessmentDashboard extends StatefulWidget {
  final String childId;
  final String childName;

  const AssessmentDashboard({
    required this.childId,
    required this.childName,
  });

  @override
  State<AssessmentDashboard> createState() => _AssessmentDashboardState();
}

class _AssessmentDashboardState extends State<AssessmentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment: ${widget.childName}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with child info
                _buildHeader(provider),

                const SizedBox(height: 24),

                // Progress indicator
                _buildProgressIndicator(provider),

                const SizedBox(height: 24),

                // Module grid (all 7 modules)
                _buildModuleGrid(provider),

                const SizedBox(height: 24),

                // Overall score (only if some completed)
                if (provider.getCompletionPercentage() > 0)
                  _buildOverallScore(provider),

                const SizedBox(height: 24),

                // Status text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    provider.status,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Finish button
                _buildFinishButton(provider),

                const SizedBox(height: 16),

                // Reset button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Assessment?'),
                          content: const Text(
                              'This will clear all results for this session.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.reset(
                                  'session_${DateTime.now().millisecondsSinceEpoch}',
                                  widget.childId,
                                );
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Reset',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Reset Assessment'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AssessmentProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            child: Text(
              widget.childName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.childName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Session: ${provider.currentSession.id.substring(0, 8)}...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AssessmentProvider provider) {
    final progress = provider.getCompletionPercentage() / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${provider.getCompletionPercentage().toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleGrid(AssessmentProvider provider) {
    final modules = [
      _ModuleItem(
        icon: Icons.person,
        title: 'Pose Detection',
        isDone: provider.assessmentState.poseDone,
        score: provider.currentSession.poseResult?.score,
      ),
      _ModuleItem(
        icon: Icons.straighten,
        title: 'Distance Check',
        isDone: provider.assessmentState.distanceCheckDone,
        score: provider.currentSession.distanceResult?.score,
      ),
      _ModuleItem(
        icon: Icons.visibility,
        title: 'Eye Alignment',
        isDone: provider.assessmentState.eyeAlignmentDone,
        score: provider.currentSession.alignmentResult?.score,
      ),
      _ModuleItem(
        icon: Icons.lightbulb,
        title: 'Pupil Reflex',
        isDone: provider.assessmentState.pupilReflexDone,
        score: provider.currentSession.pupilResult?.score,
      ),
      _ModuleItem(
        icon: Icons.palette,
        title: 'Color Vision',
        isDone: provider.assessmentState.colorVisionDone,
        score: provider.currentSession.colorVisionResult?.score,
      ),
      _ModuleItem(
        icon: Icons.remove_red_eye,
        title: 'Refraction Risk',
        isDone: provider.assessmentState.refractionRiskDone,
        score: provider.currentSession.refractionResult?.score,
      ),
      _ModuleItem(
        icon: Icons.directions_run,
        title: 'Motor Assessment',
        isDone: provider.assessmentState.motorAssessmentDone,
        score: provider.currentSession.motorResult?.overallMotorScore,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        return _ModuleCard(
          module: modules[index],
          onTap: () => _onModuleTap(context, index, provider),
        );
      },
    );
  }

  void _onModuleTap(BuildContext context, int moduleIndex, AssessmentProvider provider) {
    // Route to appropriate module screen
    switch (moduleIndex) {
      case 0:
        // Pose Detection
        _showAlert(context, 'Pose Detection', 'Navigate to PoseAssessmentScreen');
        break;
      case 1:
        // Distance Check
        _showAlert(context, 'Distance Check', 'Navigate to DistanceCheckScreen');
        break;
      case 2:
        // Eye Alignment
        _showAlert(context, 'Eye Alignment', 'Navigate to EyeAlignmentScreen');
        break;
      case 3:
        // Pupil Reflex
        _showAlert(context, 'Pupil Reflex', 'Navigate to PupilReflexScreen');
        break;
      case 4:
        // Color Vision
        _showAlert(context, 'Color Vision', 'Navigate to ColorVisionScreen');
        break;
      case 5:
        // Refraction Risk
        _showAlert(context, 'Refraction Risk', 'Navigate to RefractionRiskScreen');
        break;
      case 6:
        // Motor Assessment
        _showAlert(context, 'Motor Assessment', 'Navigate to MotorAssessmentScreen');
        break;
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  Widget _buildOverallScore(AssessmentProvider provider) {
    final score = provider.getOverallScore();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.orange,
            child: Text(
              '${score.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Development Score',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreInterpretation(score),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreInterpretation(double score) {
    if (score >= 85) return 'Excellent development';
    if (score >= 70) return 'Good development';
    if (score >= 50) return 'Average - monitor';
    return 'Below average - refer';
  }

  Widget _buildFinishButton(AssessmentProvider provider) {
    final isComplete = provider.assessmentState.allComplete;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isComplete
            ? () => _completeAssessment(context, provider)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isComplete
              ? 'Complete Assessment'
              : 'Complete ${(7 - _getCompletedCount(provider)).toStringAsFixed(0)} more modules',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isComplete ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  int _getCompletedCount(AssessmentProvider provider) {
    int count = 0;
    if (provider.assessmentState.poseDone) count++;
    if (provider.assessmentState.distanceCheckDone) count++;
    if (provider.assessmentState.eyeAlignmentDone) count++;
    if (provider.assessmentState.pupilReflexDone) count++;
    if (provider.assessmentState.colorVisionDone) count++;
    if (provider.assessmentState.refractionRiskDone) count++;
    if (provider.assessmentState.motorAssessmentDone) count++;
    return count;
  }

  Future<void> _completeAssessment(
    BuildContext context,
    AssessmentProvider provider,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Complete Assessment?'),
        content: const Text(
          'Are you sure? This will finalize all results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.completeAllAssessments();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assessment completed successfully!')),
                );
                // Show results screen or navigate back
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Complete',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleItem {
  final IconData icon;
  final String title;
  final bool isDone;
  final double? score;

  _ModuleItem({
    required this.icon,
    required this.title,
    required this.isDone,
    this.score,
  });
}

class _ModuleCard extends StatelessWidget {
  final _ModuleItem module;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: module.isDone ? Colors.green[50] : Colors.grey[100],
          border: Border.all(
            color: module.isDone ? Colors.green : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    module.icon,
                    size: 32,
                    color: module.isDone ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: module.isDone ? Colors.green : Colors.grey[700],
                    ),
                  ),
                  if (module.score != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${module.score!.toStringAsFixed(0)}/100',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (module.isDone)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
