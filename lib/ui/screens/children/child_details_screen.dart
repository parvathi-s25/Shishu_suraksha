import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';
import '../../../../core/data/models/child_model.dart';
import '../../../../core/data/models/assessment_result_models.dart';

import '../../screens/monitor/growth_screen.dart';
import '../../../modules/vision/screens/vision_home_screen.dart';
import '../screening/audio/audio_screening_screen.dart';
import '../assessment/assessment_flow_screen.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import '../../../../core/services/data_service.dart';
import '../dashboard/tabs/assessment_report_screen.dart';

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
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showEditDetailsDialog(context),
                icon: const Icon(Icons.edit),
                label: const Text("Edit Details"),
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
                  Flexible(
                    child: Text(
                      _getLocalizedRiskLabel(riskLevel, t),
                      style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
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
            const SizedBox(height: 32),
            _buildAssessmentReport(context, t),
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
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

  Widget _buildAssessmentReport(BuildContext context, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_turned_in, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "General Assessment",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                  Text(
                    "Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          _buildReportItem("Development", "Normal", Colors.green),
          _buildReportItem("Mobility", "Active", Colors.blue),
          _buildReportItem("Cognitive", "Age Appropriate", Colors.green),
          _buildReportItem("Speech", "Monitoring Required", Colors.orange),
          _buildReportItem("Vision", "Normal", Colors.green),
          _buildReportItem("Hearing", "Pass", Colors.green),
          _buildReportItem("Heart Rate", "98 bpm", Colors.pink),
          _buildGrowthItem(context, child), // Added Growth Item
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                 // Simulate opening full report
                  Navigator.push(
                     context, 
                     MaterialPageRoute(builder: (context) => AssessmentReportScreen(child: child))
                  );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
              ),
              child: const Text("View Full Report"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(BuildContext context, ChildModel child) {
    if (child.growthHistory.isEmpty) {
      return _buildReportItem("Growth (BMI)", "No Data", Colors.grey);
    }
    final latest = child.growthHistory.last;
    final bmi = latest.bmi;
    String status = 'Normal';
    Color color = Colors.green;
    
    if (bmi < 14) {
      status = 'Underweight';
      color = Colors.orange;
    } else if (bmi > 18) {
      status = 'Overweight';
      color = Colors.red;
    }

    return InkWell( // Make it clickable to see the chart if needed, or just display text
      onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => GrowthScreen(child: child)),
         );
      },
      child: _buildReportItem("Growth (BMI)", "${bmi.toStringAsFixed(1)} ($status)", color),
    );
  }

  Widget _buildReportItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDetailsDialog(BuildContext context) {
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Growth Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final double? h = double.tryParse(heightController.text);
                final double? w = double.tryParse(weightController.text);
                
                if (h != null && w != null) {
                  final record = GrowthRecord(
                    date: DateTime.now(),
                    height: h,
                    weight: w,
                  );
                  child.growthHistory.add(record);
                  DataService().updateChild(child);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Details Updated")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
