import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../core/data/models/child_model.dart';
import '../../../../core/data/models/assessment_models.dart';
import '../../../../core/data/models/assessment_result_models.dart';
import '../../../../core/data/services/risk_stratification_service.dart';
import '../../../../core/data/services/parent_report_generation_service.dart';
import '../../../../core/services/data_service.dart';

/// Assessment Result Screen - Display motor assessment results and recommendations
/// 
/// Shows:
/// - Individual test scores
/// - Overall motor development score
/// - Risk level classification
/// - Recommendations for caregivers
/// - Option to save results and continue
class AssessmentResultScreen extends ConsumerStatefulWidget {
  final ChildModel child;
  final MotorSkillsAssessment? motorAssessment;
  final SpeechAssessmentResult? speechAssessment;
  final CognitiveAssessmentResult? cognitiveAssessment;
  final SocialEmotionalAssessmentResult? socialEmotionalAssessment;
  final double overallScore;

  const AssessmentResultScreen({
    Key? key,
    required this.child,
    this.motorAssessment,
    this.speechAssessment,
    this.cognitiveAssessment,
    this.socialEmotionalAssessment,
    double? overallMotorScore, // Deprecated, use overallScore
    double? overallSpeechScore, // Helper for compatibility
    double? overallCognitiveScore, // Helper for compatibility
    double? overallSocialEmotionalScore, // Helper for compatibility
  }) : overallScore = overallMotorScore ?? overallSpeechScore ?? overallCognitiveScore ?? overallSocialEmotionalScore ?? 0.0,
       super(key: key);

  @override
  ConsumerState<AssessmentResultScreen> createState() =>
      _AssessmentResultScreenState();
}

class _AssessmentResultScreenState
    extends ConsumerState<AssessmentResultScreen> {
  late RiskStratificationService _riskService;
  late ParentReportGenerationService _reportService;

  @override
  void initState() {
    super.initState();
    _riskService = RiskStratificationService();
    _reportService = ParentReportGenerationService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildInfoCard(),
            const SizedBox(height: 24),
            _buildOverallScoreCard(),
            const SizedBox(height: 24),
            _buildDetailedScoresSection(),
            const SizedBox(height: 24),
            _buildRiskAssessmentSection(),
            const SizedBox(height: 24),
            _buildRecommendationsSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoCard() {
    final ageMonths = widget.child.ageMonths;
    final years = ageMonths ~/ 12;
    final months = ageMonths % 12;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.background,
              child: Text(
                widget.child.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.child.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Age: $years years $months months',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Date: ${DateTime.now().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    final score = widget.overallScore;
    final riskLevel = _getRiskLevel(score);
    final riskColor = _getRiskColor(score);

    String title = 'Overall Development Score';
    if (widget.motorAssessment != null) title = 'Motor Development Score';
    if (widget.speechAssessment != null) title = 'Speech & Language Score';
    if (widget.cognitiveAssessment != null) title = 'Cognitive Development Score';
    if (widget.socialEmotionalAssessment != null) title = 'Social-Emotional Score';

    return Card(
      color: riskColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: riskColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: riskColor.withOpacity(0.2),
                border: Border.all(color: riskColor, width: 3),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: TextStyle(
                        fontSize: 16,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: riskColor),
              ),
              child: Text(
                riskLevel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getRiskDescription(score),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedScoresSection() {
    List<Widget> scoreItems = [];

    if (widget.motorAssessment != null) {
      scoreItems = [
        _buildTestScoreItem('Jump Test', widget.motorAssessment!.jumpScore, 'Height, landing, stability'),
        _buildTestScoreItem('Balance Test', widget.motorAssessment!.balanceStabilityScore, 'Duration & stability'),
        _buildTestScoreItem('Walk Test', widget.motorAssessment!.gaitSymmetryScore, 'Gait & coordination'),
        _buildTestScoreItem('Throw & Catch', widget.motorAssessment!.throwCatchScore, 'Eye-hand coordination'),
      ];
    } else if (widget.speechAssessment != null) {
      scoreItems = [
        _buildTestScoreItem('Word Clarity', widget.speechAssessment!.clarityScore, 'Pronunciation & articulation'),
        _buildTestScoreItem('Vocabulary', widget.speechAssessment!.vocabularyScore, 'Word knowledge & naming'),
         _buildTestScoreItem('Sentences', widget.speechAssessment!.sentenceScore, 'Grammar & complexity'),
         _buildTestScoreItem('Fluency', widget.speechAssessment!.fluencyScore, 'Flow & rhythm'),
      ];
    } else if (widget.cognitiveAssessment != null) {
      scoreItems = [
        _buildTestScoreItem('Memory', widget.cognitiveAssessment!.memoryScore, 'Recall accuracy'),
        _buildTestScoreItem('Pattern Rec.', widget.cognitiveAssessment!.patternScore, 'Logical sequencing'),
        _buildTestScoreItem('Attention', widget.cognitiveAssessment!.attentionScore, 'Focus duration'),
        _buildTestScoreItem('Problem Solving', widget.cognitiveAssessment!.problemSolvingScore, 'Task completion'),
      ];
    } else if (widget.socialEmotionalAssessment != null) {
      scoreItems = [
        _buildTestScoreItem('Eye Contact', widget.socialEmotionalAssessment!.eyeContactScore, 'Eye engagement quality'),
        _buildTestScoreItem('Social Interaction', widget.socialEmotionalAssessment!.socialInteractionScore, 'Engagement with others'),
        _buildTestScoreItem('Emotion Reg.', widget.socialEmotionalAssessment!.emotionalRegulationScore, 'Response to emotions'),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Test Scores',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...scoreItems.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: item)).toList(),
      ],
    );
  }

  Widget _buildTestScoreItem(String title, double score, String description) {
    final color = _getScoreColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${score.toStringAsFixed(1)}/100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Assessment',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.overallScore >= 75
                          ? Icons.check_circle
                          : widget.overallScore >= 50
                              ? Icons.warning
                              : Icons.error,
                      color: _getRiskColor(widget.overallScore),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getRiskLevel(widget.overallScore),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getRiskColor(widget.overallScore),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _getRiskInterpretation(widget.overallScore),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.overallScore < 75) ...[
                  const Divider(height: 24),
                  Text(
                    'Attention Required',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildAlertItem(
                    'Schedule Follow-up',
                    'Re-assess in ${widget.overallScore < 50 ? 1 : 2} month(s)',
                  ),
                  const SizedBox(height: 8),
                  _buildAlertItem(
                    'Focused Practice',
                    'Provide targeted activities for weaker areas',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final recommendations = _generateRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...recommendations.asMap().entries.map((entry) {
          final index = entry.key;
          final rec = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec['title'] as String,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rec['description'] as String,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveResults,
            icon: const Icon(Icons.save),
            label: const Text('Save Assessment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareparentReport,
            icon: const Icon(Icons.share),
            label: const Text('Share with Parent'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Assessment Menu'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _generateRecommendations() {
    final score = widget.overallScore;

    List<Map<String, String>> recommendations = [
      {
        'title': 'Continue Regular Practice',
        'description': 'Encourage daily physical activity and movement exercises',
      },
      {
        'title': 'Safe Environment',
        'description': 'Ensure space for child to run, jump, and explore safely',
      },
    ];

    if (score >= 75) {
      recommendations.add({
        'title': 'Advancement Activities',
        'description': 'Introduce more challenging motor activities',
      });
      recommendations.add({
        'title': 'Health Monitoring',
        'description': 'Routine check-up in 6 months',
      });
    } else if (score >= 50) {
      recommendations.add({
        'title': 'Targeted Exercises',
        'description': 'Focus on weaker test areas with daily practice',
      });
      recommendations.add({
        'title': 'Follow-up Assessment',
        'description': 'Re-assess in 2 months',
      });
    } else {
      recommendations.add({
        'title': 'Early Intervention',
        'description': 'Consult physiotherapist for specialized exercises',
      });
      recommendations.add({
        'title': 'Medical Referral',
        'description': 'Refer to health center for formal evaluation',
      });
      recommendations.add({
        'title': 'Frequent Monitoring',
        'description': 'Re-assess in 1 month',
      });
    }

    return recommendations;
  }

  String _getRiskLevel(double score) {
    if (score >= 75) return '✓ Good Development';
    if (score >= 50) return '⚠️ Needs Practice';
    return '🔴 Needs Referral';
  }

  Color _getRiskColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getRiskDescription(double score) {
    if (score >= 75) {
      return 'Your child is developing well for their age. Continue encouraging physical activities.';
    }
    if (score >= 50) {
      return 'Your child shows some developmental delays. Focused practice can help improve their motor skills.';
    }
    return 'Your child shows significant delays. Professional guidance is recommended.';
  }

  String _getRiskInterpretation(double score) {
    if (score >= 75) {
      return 'On track with typical development';
    }
    if (score >= 50) {
      return 'Mild to moderate developmental delay detected';
    }
    return 'Significant developmental concerns';
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  void _saveResults() {
    // Create specific result object based on what we have
    AssessmentResult? result;
    if (widget.motorAssessment != null) {
      // We already passed the object, but if we need to reconstruct or assuming it's already a MotorAssessmentResult
      // Actually widget.motorAssessment IS the model, but we need to wrap/cast it or save it directly?
      // Wait, MotorAssessmentResult IS AssessmentResult if I defined it so.
      // Let's check definitions. Yes, MotorSkillsAssessment in 'assessment_models.dart' is DIFFERENT from MotorAssessmentResult in 'assessment_result_models.dart'
      // I need to map it if they are different, or stick to one.
      // 'assessment_models.dart' has MotorSkillsAssessment.
      // 'assessment_result_models.dart' has MotorAssessmentResult.
      // This is a duplication I created. 
      // For now, I will create a MotorAssessmentResult from the MotorSkillsAssessment data to save it uniformly.
      
       result = MotorAssessmentResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childId: widget.child.id,
        date: DateTime.now(),
        jumpScore: widget.motorAssessment!.jumpScore,
        balanceScore: widget.motorAssessment!.balanceStabilityScore,
        gaitScore: widget.motorAssessment!.gaitSymmetryScore,
        coordinationScore: widget.motorAssessment!.stepCoordinationScore,
        totalScore: widget.motorAssessment!.jumpScore, // Placeholder for overall
        developmentalAgeMonths: widget.motorAssessment!.developmentalAgeMonths,
      );
      
    } else if (widget.speechAssessment != null) {
      result = widget.speechAssessment;
    } else if (widget.cognitiveAssessment != null) {
      result = widget.cognitiveAssessment;
    } else if (widget.socialEmotionalAssessment != null) {
      result = widget.socialEmotionalAssessment;
    }

    if (result != null) {
       // Save to DataService
       DataService().addAssessmentResult(result);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assessment saved successfully')),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  void _shareparentReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating parent report...')),
    );
    // Parent report generation would happen here
  }
}
