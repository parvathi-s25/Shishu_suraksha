
import 'dart:async';
import 'excel_export_service.dart';


import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'excel_export_service.dart';

class AdminService {
  final ExcelExportService _exportService = ExcelExportService();
  final Random _random = Random();

  // Mock Data generation helper
  int _generateRandom(int min, int max) => min + _random.nextInt(max - min);

  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'total_schools': 42,
      'total_children': 1250,
      'high_risk_children': 85,
      'malnutrition_cases': 120,
      'fever_alerts_today': 14,
      'poor_aqi_schools': 3,
      'speech_issues': 28, // Enhanced
      'hearing_issues': 15, // Enhanced
      'pending_referrals': 45, // Enhanced
    };
  }

  Future<List<Map<String, dynamic>>> getHighRiskList() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      {"name": "Aditi Sharma", "school": "MPS Delhi", "risk": "High Heart Rate (140)", "score": 85, "type": "Health"},
      {"name": "Rohan Gupta", "school": "KV Noida", "risk": "Low SpO2 (88%)", "score": 92, "type": "Health"},
      {"name": "Sita Verma", "school": "Govt School #4", "risk": "Severe Malnutrition (BMI 14.2)", "score": 78, "type": "Growth"},
      {"name": "Amit Kumar", "school": "MPS Delhi", "risk": "High Fever (39.5°C)", "score": 88, "type": "Health"},
      {"name": "Priya Singh", "school": "KV Noida", "risk": "Irregular ECG", "score": 82, "type": "Health"},
      // Enhanced Speech & Hearing Cases
      {"name": "Kiran Rao", "school": "Anganwadi #12", "risk": "Speech Delay (No response to name)", "score": 75, "type": "Speech"},
      {"name": "Vihaan Das", "school": "Govt School #4", "risk": "Hearing Loss (Right Ear > 40dB)", "score": 80, "type": "Hearing"},
      {"name": "Ananya Roy", "school": "MPS Delhi", "risk": "Stuttering / Fluency Issue", "score": 65, "type": "Speech"},
    ];
  }

  // New: Analytics Data for Charts
  Future<Map<String, dynamic>> getAnalyticsData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'attendance_weekly': [85, 88, 82, 90, 92, 89, 94], // Last 7 days
      'health_trends': {
        'malnutrition': [125, 122, 120, 118, 120], // Trend for 5 months
        'fever_cases': [10, 15, 8, 12, 14],
      },
      'assessment_completion': {
        'growth': 85,
        'speech': 60,
        'hearing': 45,
        'dental': 30, // Future
      }
    };
  }

  Future<List<Map<String, dynamic>>> getReportData(String reportType) async {
    final highRisk = await getHighRiskList();
    
    if (reportType == "HighRisk") {
      return highRisk.map((e) => {
        "Name": e['name'],
        "School": e['school'],
        "RiskFactor": e['risk'],
        "Score": e['score'],
        "Category": e['type'],
        "RecommendedAction": _getRecommendation(e['type']),
      }).toList();
    } else if (reportType == "SpeechHearing") {
       // New Report Type
       return [
         {"Name": "Kiran Rao", "Age": 4, "SpeechScore": "Low", "Hearing": "Normal", "Action": "Refer to SLP"},
         {"Name": "Vihaan Das", "Age": 5, "SpeechScore": "Normal", "Hearing": "Mild Loss", "Action": "Audiologist Consult"},
         {"Name": "Ananya Roy", "Age": 3, "SpeechScore": "Medium", "Hearing": "Normal", "Action": "Monitor"},
         {"Name": "Rahul M", "Age": 4, "SpeechScore": "High", "Hearing": "Normal", "Action": "None"},
       ];
    } else {
      // Growth
      return [
        {"Name": "Rahul", "Height": 110.0, "Weight": 18.0, "BMI": 14.8, "Status": "Normal", "Date": "15/02/2026"},
        {"Name": "Priya", "Height": 105.0, "Weight": 16.5, "BMI": 15.0, "Status": "Normal", "Date": "16/02/2026"},
      ];
    }
  }

  String _getRecommendation(String? type) {
    switch (type) {
      case 'Speech': return "Refer to Speech Therapist";
      case 'Hearing': return "Refer to ENT Specialist";
      case 'Growth': return "Nutritional Supplementation";
      default: return "Medical Checkup"; 
    }
  }

  Future<String?> exportToExcel(String reportType) async {
    final data = await getReportData(reportType);
    return await _exportService.generateHealthReport("Admin_${reportType}", data);
  }
}

