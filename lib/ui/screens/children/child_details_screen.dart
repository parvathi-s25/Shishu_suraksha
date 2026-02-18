import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';
import '../../../../core/data/models/child_model.dart';
import '../../../../core/data/models/assessment_result_models.dart';
import '../../screens/monitor/health_monitoring_screen.dart';
import '../../screens/monitor/growth_screen.dart';
import '../screening/visual/visual_screening_screen.dart';
import '../screening/audio/audio_screening_screen.dart';
import '../assessment/assessment_flow_screen.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import '../../../../core/services/data_service.dart';

class ChildDetailsScreen extends StatelessWidget {
  final ChildModel child;

  const ChildDetailsScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final riskLevel = _getChildRiskLevel(child);
    final riskColor = _getRiskColor(riskLevel);
    final ageMonths = child.ageMonths;
    final years = ageMonths ~/ 12;
    final months = ageMonths % 12;

    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Child Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        child.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.cake, '${t.ageLabel}: $years years $months months'),
                          _buildInfoRow(Icons.person, '${t.gender}: ${child.gender == 'Male' ? t.male : (child.gender == 'Female' ? t.female : t.other)}'),
                          _buildInfoRow(Icons.location_on, child.anganwadi ?? 'Unknown'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Risk Level Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: riskColor, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.report_problem, color: riskColor),
                  const SizedBox(width: 12),
                  Text(
                    '${t.riskScore}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    _getLocalizedRiskLabel(riskLevel, t),
                    style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Health & Development Suite
            Text(
              t.healthDevelopmentSuite,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildSuiteItem(
                  context,
                  icon: Icons.monitor_heart,
                  label: t.heartRateVitals,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HealthMonitoringScreen(child: child)));
                  },
                ),
                _buildSuiteItem(
                  context,
                  icon: Icons.show_chart,
                  label: t.growth,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GrowthScreen(child: child)));
                  },
                ),
                _buildSuiteItem(
                  context,
                  icon: Icons.psychology,
                  label: t.developmental,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AssessmentFlowScreen(child: child)));
                  },
                ),
                _buildSuiteItem(
                  context,
                  icon: Icons.visibility,
                  label: t.visionTest,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualScreeningScreen()));
                  },
                ),
                _buildSuiteItem(
                  context,
                  icon: Icons.hearing,
                  label: t.hearingTest,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioScreeningScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSuiteItem(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedRiskLabel(String riskLevel, AppLocalizations t) {
    if (riskLevel == 'HIGH RISK') return t.highRisk;
    if (riskLevel == 'MEDIUM RISK') return t.mediumRisk;
    if (riskLevel == 'LOW RISK') return t.lowRisk;
    if (riskLevel == 'NO ASSESSMENT') return t.noAssessment;
    return riskLevel;
  }

  String _getChildRiskLevel(ChildModel child) {
    final assessments = DataService().getAssessmentsForChild(child.id);
    
    if (assessments.isEmpty) {
       if (child.id == '3') return 'HIGH RISK';
       if (child.id == '5') return 'MEDIUM RISK';
       return 'NO ASSESSMENT'; 
    }
    
    assessments.sort((a, b) => b.date.compareTo(a.date));
    final latest = assessments.first;
    
    double score = 0;
    if (latest is MotorAssessmentResult) score = latest.totalScore;
    if (latest is SpeechAssessmentResult) score = latest.totalScore;
    if (latest is CognitiveAssessmentResult) score = latest.totalScore;
    
    if (score >= 75) return 'LOW RISK';
    if (score >= 50) return 'MEDIUM RISK';
    return 'HIGH RISK';
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel == 'HIGH RISK') return Colors.red;
    if (riskLevel == 'MEDIUM RISK') return Colors.orange;
    if (riskLevel == 'NO ASSESSMENT') return Colors.grey;
    return Colors.green;
  }
}
