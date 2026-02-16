
import 'dart:async';
import 'excel_export_service.dart';

class AdminService {
  final ExcelExportService _exportService = ExcelExportService();

  // Mock Data for Admin Dashboard - In real app, this would be an aggregate query
  Future<Map<String, dynamic>> getDashboardStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'total_schools': 42,
      'total_children': 1250,
      'high_risk_children': 85, 
      'malnutrition_cases': 120, 
      'fever_alerts_today': 14,
      'poor_aqi_schools': 3,
    };
  }

  Future<List<Map<String, dynamic>>> getHighRiskList() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      {"name": "Aditi Sharma", "school": "MPS Delhi", "risk": "High Heart Rate (140)", "score": 85},
      {"name": "Rohan Gupta", "school": "KV Noida", "risk": "Low SpO2 (88%)", "score": 92},
      {"name": "Sita Verma", "school": "Govt School #4", "risk": "Severe Malnutrition (BMI 14.2)", "score": 78},
      {"name": "Amit Kumar", "school": "MPS Delhi", "risk": "High Fever (39.5°C)", "score": 88},
      {"name": "Priya Singh", "school": "KV Noida", "risk": "Irregular ECG", "score": 82},
    ];
  }

  // Actual Excel Export Integration
  // Fetch Report Data for UI Display or Export
  Future<List<Map<String, dynamic>>> getReportData(String reportType) async {
    if (reportType == "HighRisk") {
      final data = await getHighRiskList();
      return data.map((e) => {
        "Name": e['name'],
        "Age": 4, // Mock age
        "Heart Rate": 140.0, // Mock
        "SpO2": 95.0,
        "Temp": 37.0,
        "Risk Score": e['score'],
        "Status": e['risk'],
        "School": e['school']
      }).toList();
    } else {
      // Generic growth report mock
      return [
        {"Name": "Rahul", "Height": 110.0, "Weight": 18.0, "BMI": 14.8, "Status": "Normal", "Date": "15/02/2026"},
        {"Name": "Priya", "Height": 105.0, "Weight": 16.5, "BMI": 15.0, "Status": "Normal", "Date": "16/02/2026"},
        {"Name": "Amit", "Height": 112.0, "Weight": 19.0, "BMI": 15.1, "Status": "Normal", "Date": "16/02/2026"},
      ];
    }
  }

  Future<String?> exportToExcel(String reportType) async {
    final data = await getReportData(reportType);
    if (reportType == "HighRisk") {
       return await _exportService.generateHealthReport("Central_Admin", data);
    } else {
       return await _exportService.generateGrowthReport("Central_Admin", data);
    }
  }
}

