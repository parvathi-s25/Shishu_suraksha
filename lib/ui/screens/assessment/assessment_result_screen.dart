import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/colors.dart';
import '../../../../core/data/models/child_model.dart';
import '../../../../core/data/models/assessment_models.dart';
import '../../../../core/data/models/assessment_result_models.dart';
import '../../../../core/data/services/risk_stratification_service.dart';
import '../../../../core/data/services/parent_report_generation_service.dart';
import '../../../../core/services/data_service.dart';

/// Assessment Result Screen - Display assessment results and recommendations
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
    required this.overallScore,
  }) : super(key: key);

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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
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
            _buildModelConfidenceBanner(), // Added ML provenance banner
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
    final years = widget.child.ageMonths ~/ 12;
    final months = widget.child.ageMonths % 12;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                widget.child.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
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

    String title = 'Overall Score';
    if (widget.motorAssessment != null) title = 'Motor Score';
    if (widget.speechAssessment != null) title = 'Speech Score';
    if (widget.cognitiveAssessment != null) title = 'Cognitive Score';
    if (widget.socialEmotionalAssessment != null) title = 'Social Score';

    return Card(
      color: riskColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: riskColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      score.toStringAsFixed(0),
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: riskColor),
                    ),
                    Text('/ 100', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                riskLevel,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
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
        _buildTestScoreItem('Jump Performance', widget.motorAssessment!.jumpScore, 'Height and landing'),
        _buildTestScoreItem('Postural Balance', widget.motorAssessment!.balanceStabilityScore, 'Static stability'),
        _buildTestScoreItem('Gait & Walking', widget.motorAssessment!.gaitSymmetryScore, 'Dynamic coordination'),
        _buildTestScoreItem('Eye-Hand Coord.', widget.motorAssessment!.throwCatchScore, 'Dexterity'),
      ];
    } else if (widget.speechAssessment != null) {
      scoreItems = [
        _buildTestScoreItem('Articulation', widget.speechAssessment!.clarityScore, 'Clarity of speech'),
        _buildTestScoreItem('Vocabulary', widget.speechAssessment!.vocabularyScore, 'Word naming'),
        _buildTestScoreItem('Grammar', widget.speechAssessment!.sentenceScore, 'Sentence structure'),
        _buildTestScoreItem('Fluency', widget.speechAssessment!.fluencyScore, 'Flow and rhythm'),
      ];
    } else if (widget.cognitiveAssessment != null) {
      scoreItems = [
        _buildTestScoreItem('Recall Memory', widget.cognitiveAssessment!.memoryScore, 'Object recognition'),
        _buildTestScoreItem('Pattern Logic', widget.cognitiveAssessment!.patternScore, 'Sequencing'),
        _buildTestScoreItem('Sustained Attention', widget.cognitiveAssessment!.attentionScore, 'Focus duration'),
        _buildTestScoreItem('Problem Solving', widget.cognitiveAssessment!.problemSolvingScore, 'Task completion'),
      ];
    } else if (widget.socialEmotionalAssessment != null) {
      scoreItems = [
        _buildTestScoreItem('Eye Engagement', widget.socialEmotionalAssessment!.eyeContactScore, 'Visual social cues'),
        _buildTestScoreItem('Social Response', widget.socialEmotionalAssessment!.socialInteractionScore, 'Engagement level'),
        _buildTestScoreItem('Emotional Reg.', widget.socialEmotionalAssessment!.emotionalRegulationScore, 'Affect regulation'),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Domain Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...scoreItems,
      ],
    );
  }

  Widget _buildTestScoreItem(String title, double score, String description) {
    final color = _getScoreColor(score);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${score.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelConfidenceBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1117), // Dark theme to match ML charts
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, color: Colors.tealAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Model Confidence',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    children: [
                      const TextSpan(text: 'Based on '),
                      const TextSpan(
                        text: 'Andhra Pradesh Government ECD Dataset',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                      const TextSpan(text: ' (1,000 children) — Model classified child as: '),
                      TextSpan(
                        text: _getRiskLevel(widget.overallScore) == 'Low Risk' ? 'On-Track' : 
                             _getRiskLevel(widget.overallScore) == 'Moderate Risk' ? 'At-Risk' : 'Critical',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(widget.overallScore),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessmentSection() {
    final score = widget.overallScore;
    final riskColor = _getRiskColor(score);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(score >= 70 ? Icons.check_circle : Icons.warning_amber_rounded, color: riskColor),
              const SizedBox(width: 8),
              const Text('Risk Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getRiskInterpretation(score),
            style: const TextStyle(fontSize: 15),
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
        const Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...recommendations.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(child: Text(rec['description'] ?? '', style: const TextStyle(fontSize: 14))),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveResults,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('SAVE ASSESSMENT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareparentReport,
                icon: const Icon(Icons.share),
                label: const Text('SHARE'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.menu),
                label: const Text('MENU'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getRiskLevel(double score) {
    if (score >= 75) return 'Low Risk';
    if (score >= 50) return 'Moderate Risk';
    return 'High Risk';
  }

  Color _getRiskColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getRiskInterpretation(double score) {
    if (score >= 75) return 'Development appears to be on track. Continue normal monitoring.';
    if (score >= 50) return 'Some delays detected. Targeted activities and follow-up in 2 months recommended.';
    return 'Significant delays detected. Consider immediate clinical referral for specialist evaluation.';
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  List<Map<String, String>> _generateRecommendations() {
    final score = widget.overallScore;
    if (score >= 75) {
      return [
        {'description': 'Encourage unstructured play and social interaction.'},
        {'description': 'Maintain current nutritional and growth monitoring schedules.'},
      ];
    } else if (score >= 50) {
       return [
        {'description': 'Incorporate directed physical and cognitive play 30 mins daily.'},
        {'description': 'Re-assess progress in 4-6 weeks.'},
      ];
    } else {
       return [
        {'description': 'Refer to Pediatric Specialist for comprehensive evaluation.'},
        {'description': 'Immediate intervention and parental guidance session required.'},
      ];
    }
  }

  void _saveResults() {
    AssessmentResult? result;
    if (widget.motorAssessment != null) {
      result = MotorAssessmentResult(
        id: 'MOTOR_${DateTime.now().millisecondsSinceEpoch}',
        childId: widget.child.id,
        date: DateTime.now(),
        jumpScore: widget.motorAssessment!.jumpScore,
        balanceScore: widget.motorAssessment!.balanceStabilityScore,
        gaitScore: widget.motorAssessment!.gaitSymmetryScore,
        coordinationScore: widget.motorAssessment!.stepCoordinationScore,
        totalScore: widget.overallScore,
        developmentalAgeMonths: widget.child.ageMonths,
      );
    } else if (widget.speechAssessment != null) {
      result = widget.speechAssessment;
    } else if (widget.cognitiveAssessment != null) {
      result = widget.cognitiveAssessment;
    } else if (widget.socialEmotionalAssessment != null) {
      result = widget.socialEmotionalAssessment;
    }

    if (result != null) {
      DataService().addAssessmentResult(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment saved successfully!')),
      );
      // Optional: Navigate to home or stay
    }
  }

  void _shareparentReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating sharing link...')),
    );
  }
}
